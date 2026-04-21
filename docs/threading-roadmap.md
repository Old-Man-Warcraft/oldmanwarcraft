# AzerothCore / OMW Multithreading Roadmap

> Branch: `feat/omw-threading`
> Last updated: 2026-04-21

---

## 1. Current State: Architecture Snapshot

### 1.1 Thread Inventory

| Thread | Count | Config Key | Role |
|---|---|---|---|
| **World Update Loop** | 1 (main) | — | Calls `World::Update()` every tick — all game logic |
| **Boost Asio I/O pool** | 2 (default) | `ThreadPool` | Network I/O, async log, freeze detector, metrics, RA |
| **Network threads** | 1 (default) | `Network.Threads` | One `WorldSocketThread` per slot; reads/decrypts packets |
| **Map worker threads** | 1 (OMW default) | `MapUpdate.Threads` | `MapUpdater` pool — parallel `Map::Update()` per map |
| **DB async threads** | per-pool | `World/Char/LoginDatabase.*` | `DatabaseWorkerPool` IDX_ASYNC workers |
| **CLI thread** | 1 (optional) | `Console.Enable` | Console command input |
| **SOAP thread** | 1 (optional) | `SOAP.Enabled` | Remote admin |

### 1.2 The Single-Threaded Bottleneck

Every game tick, the **main thread** executes this sequence serially:

```
WorldUpdateLoop()  [Main.cpp:564]
  └─ sWorld->Update(diff)  [World.cpp]
       ├─ sWorldSessionMgr->UpdateSessions(diff)   ← ALL player packet handling
       │    └─ WorldSession::Update()  per session  ← spell casts, movement, loot, chat
       ├─ sMapMgr->Update(diff)                     ← creature AI, combat, respawns
       │    ├─ [if NumThreads > 0] schedule maps to MapUpdater workers
       │    └─ wait() ← main thread blocks until all maps finish
       ├─ sBattlegroundMgr->Update()
       ├─ sOutdoorPvPMgr->Update()
       ├─ sGameEventMgr->Update()
       ├─ sLFGMgr->Update()
       └─ ProcessQueryCallbacks()
```

`UpdateSessions()` is the **largest single-thread hotspot**. With 200+ players it consumes 40–70% of the tick budget because every session processes its `_recvQueue` serially on the main thread.

### 1.3 What Is Already Parallel

| Subsystem | Mechanism | Notes |
|---|---|---|
| **Packet I/O** | `NetworkThread<WorldSocket>` (Asio) | Reading + decryption only; game logic is still main-thread |
| **DB async** | `ProducerConsumerQueue<SQLOperation*>` per pool | Genuinely async; fire-and-forget path is safe |
| **Map updates** | `MapUpdater` + `PCQueue` | Off by default; correct when enabled, but coarse-grained |
| **LFG update** | Scheduled to `MapUpdater` workers | Runs alongside maps when `NumThreads > 0` |
| **MPSC queues** | `MPSCQueue<T>` (lock-free) | Available but underutilised outside DB |
| **Async logging** | Dispatched into `IoContext` | Enabled via `Log.Async.Enable` |

### 1.4 Known Concurrency Hazards

- `ObjectAccessor` — global singleton, `HashMapHolder<Player>` uses a `shared_lock` but many callers don't hold it
- `GroupMgr`, `GuildMgr`, `BattlegroundMgr` — global singletons with no per-map locking; unsafe to call from parallel map threads
- `WorldSession::_recvQueue` — `LockedQueue<WorldPacket*>` (mutex), produced by network threads, consumed by main thread only
- `sScriptMgr` — most hooks are called without any lock; parallel invocations would race
- Arena/Guild/Group formation — documented race conditions in playerbots-rules.md apply equally here

---

## 2. Goals

1. **Phase 1** — Low-risk, high-return: enable and harden existing map parallelism with zero API change
2. **Phase 2** — Session parallelism: drain `WorldSession::_recvQueue` on per-map strands instead of main thread
3. **Phase 3** — Global manager safety: make shared singletons strand-safe or lock-free
4. **Phase 4** — Full map-strand ownership: each map owns its sessions; cross-map ops become async handoffs

Each phase is independently deployable and testable.

---

## 3. Phase 1 — Enable & Harden Map Parallelism

**Effort:** Low | **Risk:** Low-Medium | **Expected gain:** 20–40% tick budget freed on multi-core

### 3.1 What Already Works

`MapUpdater` (`src/server/game/Maps/MapUpdater.cpp`) is a correct thread pool. When `MapUpdate.Threads > 0`, maps update in parallel. The `PCQueue` correctly synchronizes producers/consumers.

### 3.2 What Needs Fixing Before Enabling

**3.2.1 Global singleton calls inside `Map::Update()`**

Several calls inside `Map::Update()` / creature AI / transport update reach global state that is not thread-safe:

```cpp
// These are called from map worker threads and race with each other:
sObjectMgr->GetCreatureTemplate(...)    // read-only after load – safe
sObjectMgr->GetGameObjectTemplate(...)  // read-only after load – safe
sScriptMgr->OnMapUpdate(...)            // NOT safe – calls user scripts with shared state
sBattlegroundMgr->GetBattleground(...)  // NOT safe – map iterates without lock
sGroupMgr->GetGroupByGUID(...)          // NOT safe – no lock on read path
```

**Fix:** Audit every singleton call reachable from `Map::Update()`. For read-only stores loaded at startup (ObjectMgr templates), mark them `const` and document as safe. For mutable state:
- Add `std::shared_mutex` to `BattlegroundMgr::_bgDataStore` and `GroupMgr::_groupStore`
- Use `shared_lock` for reads, `unique_lock` for writes

**3.2.2 `ObjectAccessor::HashMapHolder<Player>` read path**

`WorldSessionMgr::DoForAllOnlinePlayers` already acquires `shared_lock`. But `ObjectAccessor::FindPlayer` callers inside map update do not always hold the lock. Wrap all `FindPlayer` calls that happen during parallel map update in `shared_lock`.

**3.2.3 Default config value**

```ini
# worldserver.conf
MapUpdate.Threads = 4    # OMW default (upstream was 1)
```

Set to roughly `hardware_concurrency / 2`. **Already done** in `worldserver.conf.dist` on this branch.

### 3.3 Implementation Steps

```
[ ] 1. Add shared_mutex to BattlegroundMgr::_bgDataStore
[ ] 2. Add shared_mutex to GroupMgr::_groupStore
[ ] 3. Add shared_mutex to GuildMgr (read path in Map context)
[ ] 4. Audit sScriptMgr hooks called from Map::Update() — wrap in a per-script mutex or document as map-local only
[ ] 5. Enable NumThreads = 4 on dev realm, run stress test (500 bots across multiple maps)
[ ] 6. Verify with TSAN (Thread Sanitizer build) — add -DCMAKE_CXX_FLAGS="-fsanitize=thread" to CMake
[ ] 7. Update worldserver.conf.dist with recommended NumThreads comment
```

### 3.4 Verification

```bash
# Build with ThreadSanitizer
cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS="-fsanitize=thread -g"
make -j$(nproc)

# Run dev realm with bots spreading across multiple maps
# Watch for TSAN race reports in server log
```

---

## 4. Phase 2 — Session Update Parallelism

**Effort:** Medium | **Risk:** Medium | **Expected gain:** 40–60% reduction in main-thread tick time

### 4.1 Problem

`WorldSessionMgr::UpdateSessions()` iterates all sessions sequentially on the main thread:

```cpp
// WorldSessionMgr.cpp:108 — fully serial today
for (SessionMap::iterator itr = _sessions.begin(); ...; itr = next)
{
    WorldSession* pSession = itr->second;
    if (!pSession->Update(diff, updater))  // ← blocks here per session
        ...
}
```

`WorldSession::Update()` drains `_recvQueue` and dispatches opcode handlers. For 500 sessions at 150 packets max each, this is O(N × packet_cost) on one thread.

### 4.2 Approach: Map-Owned Session Updates

Instead of the main thread iterating all sessions, **each session is updated by the map thread that owns the player's current map**. Sessions without an in-world player (loading, auth queue) remain on the main thread.

```
Before:
  Main thread → UpdateSessions() → Session[0..N].Update()

After:
  Main thread → UpdateSessions() → process sessions NOT in world (loading/queue)
  Map thread 0 → Map[0].Update() → Session[playerA, playerB].Update()
  Map thread 1 → Map[1].Update() → Session[playerC, playerD].Update()
  ...
```

### 4.3 Required Changes

**4.3.1 `Map` tracks its sessions**

```cpp
// Map.h — add:
class Map {
    std::vector<WorldSession*> _ownedSessions;  // sessions whose player is on this map
    std::mutex _ownedSessionsMutex;             // protect add/remove during teleport

    void AddOwnedSession(WorldSession* sess);
    void RemoveOwnedSession(WorldSession* sess);
    void UpdateOwnedSessions(uint32 diff);
};
```

**4.3.2 Player teleport transfers session ownership**

When a player teleports (`Player::TeleportTo`):
1. Source map calls `RemoveOwnedSession(session)` on the map's next-tick deferred list
2. Destination map calls `AddOwnedSession(session)` after the player is placed
3. Transfer is atomic from the perspective of session ownership (no double-update)

**4.3.3 `Map::Update()` calls `UpdateOwnedSessions()`**

```cpp
void Map::Update(uint32 diff, uint32 s_diff)
{
    UpdateOwnedSessions(diff);   // NEW — drain recvQueues of players on this map
    // ... existing update logic ...
}
```

**4.3.4 `WorldSessionMgr::UpdateSessions()` only handles non-world sessions**

Sessions where `GetPlayer() == nullptr || !GetPlayer()->IsInWorld()` stay on main thread. This covers login queue, char selection, loading screen.

### 4.4 Cross-Session Packet Safety

Some opcodes touch other sessions' data (trade, duel, group invite). These need to either:
- Post a deferred task to the target session's map thread via the existing `MapUpdater` queue
- Or use the existing `LockedQueue` on the target `WorldSession` (network threads already do this)

The simplest safe approach: **opcodes that cross session boundaries are queued as tasks on the target map's next-tick deferred list** rather than executed inline.

### 4.5 Implementation Steps

```
[ ] 1. Add _ownedSessions + mutex to Map
[ ] 2. Add AddOwnedSession/RemoveOwnedSession to Map API
[ ] 3. Hook into Player::SetMap / Player::ResetMap to call these
[ ] 4. Add UpdateOwnedSessions() to Map::Update() (before grid update)
[ ] 5. Filter WorldSessionMgr::UpdateSessions() to non-world sessions only
[ ] 6. Identify cross-session opcodes — create deferred-task API for them
[ ] 7. Test: login/logout, teleport between maps, death, instance enter/exit
[ ] 8. Test: trade, duel, group invite (cross-session packets)
```

---

## 5. Phase 3 — Global Manager Thread Safety

**Effort:** Medium-High | **Risk:** Medium | **Expected gain:** Enables Phase 2 without races

This phase is a prerequisite for Phase 2 being fully safe. The global managers accessed from map-owned session updates must be safe for concurrent read (writes remain infrequent).

### 5.1 Managers to Harden

| Manager | Current State | Required Change |
|---|---|---|
| `ObjectMgr` | Read-only after load for templates | Document as safe; add `[[nodiscard]]` to const getters |
| `SpellMgr` | Read-only after load | Same as ObjectMgr |
| `BattlegroundMgr` | Mutable during BG lifecycle | `shared_mutex` on `_bgDataStore` |
| `GroupMgr` | Mutable on group change | `shared_mutex` on group map |
| `GuildMgr` | Mutable on guild change | `shared_mutex` on guild map |
| `LFGMgr` | Already dispatched to worker | Low risk; keep as-is |
| `ScriptMgr` | Hooks are unguarded | Per-hook mutex OR document hooks as map-local |
| `InstanceSaveMgr` | Mutable on instance bind | `shared_mutex` on save map |
| `ConditionMgr` | Read-only after load | Safe |

### 5.2 Pattern to Use

```cpp
// Example: BattlegroundMgr
class BattlegroundMgr {
    mutable std::shared_mutex _lock;
    BattlegroundDataContainer _bgDataStore;  // key: bgTypeId

public:
    Battleground* GetBattleground(uint32 instanceId, BattlegroundTypeId bgTypeId) const
    {
        std::shared_lock lock(_lock);   // many readers OK simultaneously
        // ... existing lookup logic ...
    }

    void AddBattleground(Battleground* bg)
    {
        std::unique_lock lock(_lock);   // exclusive for writes
        // ...
    }
};
```

### 5.3 Implementation Steps

```
[ ] 1. Add shared_mutex + shared_lock to BattlegroundMgr read paths
[ ] 2. Add shared_mutex + shared_lock to GroupMgr read paths
[ ] 3. Add shared_mutex + shared_lock to GuildMgr read paths
[ ] 4. Add shared_mutex + shared_lock to InstanceSaveMgr read paths
[ ] 5. Review ObjectAccessor::HashMapHolder — ensure FindPlayer is always lock-protected
[ ] 6. Audit ScriptMgr hooks — categorise each as: map-local / needs lock / already safe
[ ] 7. Run TSAN build again — no new races should appear
```

---

## 6. Phase 4 — Map Strand Ownership (Long-Term Target)

**Effort:** High | **Risk:** High | **Expected gain:** Near-linear scaling with core count

### 6.1 Vision

Each `Map` runs on a dedicated Boost Asio **strand**. A strand serializes all work *for that map* while allowing different maps to run concurrently on the Asio thread pool without any explicit locking.

```
IoContext pool (N threads)
  ├─ strand[Map_0]:  Map::Update → session packets → AI → combat → DB async callbacks
  ├─ strand[Map_1]:  Map::Update → session packets → AI → combat → DB async callbacks
  ├─ strand[Map_2]:  ...
  └─ strand[World]:  BattlegroundMgr, GuildMgr, timers, quest resets (low-frequency)
```

Cross-map operations (teleport, group invite, trade) become `boost::asio::post()` calls to the target strand, eliminating all shared mutable state races.

### 6.2 Key Infrastructure Change

Replace `MapUpdater`'s manual thread pool + `PCQueue` with Asio strands on the shared `IoContext`:

```cpp
// Map.h
class Map {
    boost::asio::strand<boost::asio::io_context::executor_type> _strand;
    // ...
};

// MapMgr.cpp — scheduling
for (auto& [id, map] : i_maps)
{
    boost::asio::post(map->GetStrand(), [map, diff]() {
        map->Update(diff);
    });
}
// No explicit wait() — completion tracked via shared_ptr ref-counting or a latch
```

### 6.3 Cross-Map Operation Protocol

```
Player teleports from Map_A → Map_B:

1. On Map_A strand: queue deferred removal of player
2. post(Map_B->strand, [player]{ Map_B->AddPlayer(player); player->session->SetOwningMap(Map_B); })
3. On next tick, Map_A deferred list runs → player fully removed
```

All cross-session opcodes similarly become `post()` calls to the target map's strand.

### 6.4 Prerequisites

- Phases 1, 2, 3 completed
- All global manager writes either eliminated or strand-dispatched
- All `Map::Update()` completion tracking ported from `MapUpdater::wait()` to Asio latch/promise

### 6.5 Implementation Steps

```
[ ] 1. Add strand member to Map; pass IoContext reference during construction
[ ] 2. Refactor MapMgr::Update() to post per-map work to strands
[ ] 3. Replace MapUpdater::wait() with std::latch or boost::asio::experimental::parallel_group
[ ] 4. Port teleport: use strand-safe deferred removal/addition
[ ] 5. Port cross-session opcodes to strand-posted tasks
[ ] 6. Port DB async callbacks to route to map strand (not arbitrary Asio thread)
[ ] 7. Remove MapUpdater class (replaced by strands)
[ ] 8. Full stress test + TSAN
```

---

## 7. Quick Wins (Do Immediately, No Phase Required)

These changes are safe, isolated, and provide measurable improvement today:

### 7.1 Enable Async Logging

```ini
# worldserver.conf
Log.Async.Enable = 1
```

Logging calls on hot paths (combat, movement) currently block the calling thread. Async mode posts them to the Asio pool. Zero code change needed.

### 7.2 Tune Network Threads

```ini
Network.Threads = 2   # or hardware_concurrency / 4, minimum 2
```

Default of 1 means all incoming packet reads queue behind a single Asio thread. On a server with 200+ players, 2–3 network threads reduce socket read latency significantly.

### 7.3 Tune Asio Thread Pool

```ini
ThreadPool = 4   # default is 2
```

Feeds the freeze detector, async log, metric reporters, and RA connections. Undersized pools stall async DB callbacks.

### 7.4 Tune Map Update Threads

```ini
MapUpdate.Threads = 4   # set to ~nproc/2
```

**OMW branch already sets this to 4.** The parallel map infrastructure is solid for maps that don't share players (instances, BGs, arenas). Some cross-map interaction races exist (documented in §3.2); validate via TSAN before production.

### 7.5 Replace Remaining Sync DB Calls on Main Thread

Search for `DirectExecute` and `Query` called from `World::Update()` hot paths:

```bash
grep -rn "DirectExecute\|\.Query(" src/server/game/World/ src/server/game/Server/WorldSession.cpp
```

Each one stalls the main thread for the round-trip DB latency (1–10ms each). Convert to `AsyncQuery` + callback pattern.

---

## 8. Testing Strategy

### 8.1 Thread Sanitizer Build

```bash
mkdir build-tsan && cd build-tsan
cmake .. -DCMAKE_BUILD_TYPE=Debug \
         -DCMAKE_CXX_FLAGS="-fsanitize=thread -g" \
         -DCMAKE_EXE_LINKER_FLAGS="-fsanitize=thread"
make -j$(nproc) && make install
```

Run worldserver with TSAN binary and 100+ bots on multiple maps. Any race will be reported to stderr with full stack trace.

### 8.2 Stress Test Protocol

For each phase, test the following scenarios on the **dev realm (8086)** before production:

| Scenario | Why |
|---|---|
| 500 bots spread across 5 continents | Tests parallel continent map updates |
| 100 bots in same instance | Tests instance map locking |
| Mass BG population (40v40) | Tests BattlegroundMgr read contention |
| Rapid teleport (bots teleport every 30s) | Tests session ownership transfer |
| Guild mass invite/kick | Tests GuildMgr write locking |
| Group formation under load | Tests GroupMgr write locking |
| Server shutdown under load | Tests deactivation path of MapUpdater |

### 8.3 Metrics to Watch

Use the existing Metric system to track before/after:

```
world_update_time        — total main-thread tick time (target: < 50ms)
map_update_time_diff     — per-map update cost (tagged by map_id)
world_update_sessions_time — session update cost (target: < 20ms at 500 players)
db_queue_login/char/world — async DB backlog (should not grow unboundedly)
```

---

## 9. File Reference

| File | Role in Threading |
|---|---|
| `src/server/apps/worldserver/Main.cpp` | `WorldUpdateLoop()` — the main game tick |
| `src/server/game/Maps/MapUpdater.cpp/.h` | Phase 1 map thread pool |
| `src/server/game/Maps/MapMgr.cpp` | `MapMgr::Update()` — dispatches to MapUpdater |
| `src/server/game/Maps/Map.cpp` | `Map::Update()` — per-map work (Phase 2 target) |
| `src/server/game/Server/WorldSessionMgr.cpp` | `UpdateSessions()` — Phase 2 target |
| `src/server/game/Server/WorldSession.cpp` | `WorldSession::Update()` — packet drain loop |
| `src/server/game/World/World.cpp` | `World::Update()` — orchestrates everything |
| `src/common/Threading/MapUpdater.h` | Thread pool headers |
| `src/common/Threading/PCQueue.h` | Producer-consumer queue (mutex + condvar) |
| `src/common/Threading/MPSCQueue.h` | Lock-free MPSC queue (Vyukov) |
| `src/common/Threading/LockedQueue.h` | Session recv queue |
| `src/common/Asio/IoContext.h` | Asio IoContext wrapper |
| `src/common/Asio/Strand.h` | Asio strand (Phase 4) |
| `src/server/database/Database/DatabaseWorkerPool.h` | Async DB pool |

---

## 10. Priority Order

```
Priority 1 (this sprint):
  ├─ §7.1  Enable async logging
  ├─ §7.2  Tune Network.Threads
  ├─ §7.3  Tune ThreadPool
  └─ §7.5  Audit + replace sync DB calls in hot paths

Priority 2 (next sprint):
  ├─ §3.2  Fix global singleton races under map parallelism
  ├─ §3.3  Enable NumThreads = 4 on dev with TSAN validation
  └─ §3.7  Update worldserver.conf.dist defaults

Priority 3 (following sprint):
  ├─ §5    Harden global managers (shared_mutex)
  └─ §4    Map-owned session updates

Priority 4 (long-term):
  └─ §6    Full Asio strand ownership per map
```
