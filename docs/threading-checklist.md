# OMW Threading Work Checklist

> Branch: `feat/omw-threading`
> Reference: [threading-roadmap.md](threading-roadmap.md)
> Last updated: 2026-04-21

Mark items as done: change `[ ]` → `[x]`

---

## 🟢 Quick Wins — No Code Changes Required

- [x] Enable async logging in `worldserver.conf.dist` (`Log.Async.Enable = 1`)
- [x] Update default `Network.Threads` from `1` → `2` in `worldserver.conf.dist`
- [x] Update default `ThreadPool` from `2` → `4` in `worldserver.conf.dist`
- [x] Update `MapUpdate.Threads` from `1` → `4` with improved description in `worldserver.conf.dist`
- [ ] Test quick-win config changes on dev realm (8086)
- [ ] Commit updated `worldserver.conf.dist` defaults

---

## 🔵 Sync DB Call Audit

- [x] `grep -rn "DirectExecute\|\.Query(" src/server/game/World/ src/server/game/Server/WorldSession.cpp` — catalog all hits
- [x] Identify which hits are on the main-thread hot path
  - `World::LoadDBAllowedSecurityLevel()` — sync query, startup only, **not hot path** ✅
  - `World::LoadDBVersion()` — sync query, startup only, **not hot path** ✅
  - `WorldSession::SaveTutorialsData()` — sync query (`CHAR_SEL_HAS_TUTORIALS`), called from `Player::SaveToDB()` (periodic, not every tick)
    - **Low priority** — fires at most once per player save interval (default 15 min)
    - **Improvement:** can be converted to async with cached `hasTutorials` bool on `WorldSession`
- [ ] Convert `SaveTutorialsData` sync query to async (cache `hasTutorials` on session, set during `LoadTutorialsData`)
- [ ] Verify no new sync calls introduced by bot/module code (`src/server/game/` + `modules/`)
- [ ] Test async conversions on dev realm — confirm no logic regressions

---

## 🔵 Phase 1 — Enable & Harden Map Parallelism

### Prerequisite: Race Fixes

- [x] Add `std::shared_mutex` to `BattlegroundMgr::_bgDataStoreLock`
  - File: `src/server/game/Battlegrounds/BattlegroundMgr.h`
  - [x] Wrap all read paths with `std::shared_lock` (`GetBattleground`, `GetBattlegroundThroughClientInstance`, `GetBattlegroundTemplate`, `GetActiveBattlegrounds`, `BuildBattlegroundListPacket`)
  - [x] Wrap all write paths with `std::unique_lock` (`AddBattleground`, `RemoveBattleground`, `AddToBGFreeSlotQueue`, `RemoveFromBGFreeSlotQueue`, `DeleteAllBattlegrounds`, `Update`, `CreateClientVisibleInstanceId`)
- [x] Add `std::shared_mutex` to `GroupMgr::_groupStoreLock`
  - File: `src/server/game/Groups/GroupMgr.h`
  - [x] Wrap read paths (`GetGroupByGUID` → `shared_lock`)
  - [x] Wrap write paths (`AddGroup`, `RemoveGroup` → `unique_lock`)
- [x] Add `std::shared_mutex` to `GuildMgr::_guildStoreLock`
  - File: `src/server/game/Guilds/GuildMgr.h`
  - [x] Wrap read paths (`GetGuildById`, `GetGuildByName`, `GetGuildNameById`, `GetGuildByLeader`, `ResetTimes` → `shared_lock`)
  - [x] Wrap write paths (`AddGuild`, `RemoveGuild` → `unique_lock`)
- [x] Audit `sScriptMgr` hooks called from `Map::Update()` — findings:
  - `OnMapUpdate` (`Map.cpp:509`) — calls `CALL_ENABLED_HOOKS` → iterates `ScriptRegistry<AllMapScript>::EnabledHooks[ALLMAPHOOK_ON_MAP_UPDATE]`
    - **Safe**: `EnabledHooks` and `ScriptPointerList` are read-only after server startup (comment in `ScriptMgr.h:789`). No mutation occurs during runtime.
  - `ForeachMaps<WorldMapScript/InstanceMapScript/BattlegroundMapScript>` — looks up script by `mapId` in a static read-only map loaded at startup
    - **Safe**: same reason — read-only after load
  - `OnCreatureUpdate` → `ExecuteScript<AllCreatureScript>` → iterates `ScriptPointerList` read-only
    - **Safe**: read-only iteration of static registry
  - `OnUnitEnterEvadeMode` (`CreatureAI.cpp:269`) — `CALL_ENABLED_HOOKS(UnitScript, ...)` → read-only registry iteration
    - **Safe**: read-only, called from map worker thread context only on creatures owned by that map
  - **Conclusion**: `ScriptMgr` hook dispatch is **safe under map parallelism** — registries are immutable after startup. Individual script implementations may still access shared state (e.g. `sObjectMgr`, `sGuildMgr`) — those are covered by the shared_mutex work above.
- [x] Audit `ObjectAccessor::FindPlayer()` call sites inside `Map::Update()` path
  - `HashMapHolder<Player>::Find()` — already uses `shared_lock` internally ✅ (`ObjectAccessor.cpp:55`)
  - `ObjectAccessor::FindPlayer()` and `FindConnectedPlayer()` — both delegate to `HashMapHolder<Player>::Find()` — **thread safe** ✅
  - `FindConnectedPlayer` call in `Map.cpp:2022` (instance bind) — safe, uses locked Find()
  - ⚠️ `PlayerNameMapHolder::PlayerNameMap` — **completely unguarded** (`ObjectAccessor.cpp:86`) — `FindPlayerByName` is NOT safe for concurrent use
    - Checked: `FindPlayerByName` is **not called** from `Map::Update()` path — risk is deferred to future audit
  - ⚠️ Returned `Player*` pointers from any `FindPlayer` can become dangling if player logs out between lookup and use — callers in map context must guard with `IsInWorld()` check (already the pattern in `Map::Update`)

### Enable & Validate

- [x] Set `MapUpdate.Threads = 4` on dev realm `worldserver.conf` (done in Quick Wins)
- [ ] Build with ThreadSanitizer:
  ```
  cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS="-fsanitize=thread -g"
  ```
- [ ] Run dev realm with 200+ bots across multiple maps — record TSAN output
- [ ] Fix every TSAN-reported race before proceeding
- [ ] Re-run TSAN — zero races reported
- [ ] Run stress test: 500 bots across 5 continents (30 min uptime)
- [ ] Run stress test: 100 bots in same instance
- [ ] Run stress test: mass BG population (40v40 sim)
- [ ] Run stress test: server shutdown under load
- [ ] Update `worldserver.conf.dist` — document recommended `NumThreads` value
- [ ] Commit Phase 1

---

## 🟡 Phase 2 — Map-Owned Session Updates

### Infrastructure

- [ ] Add `_ownedSessions` (`std::vector<WorldSession*>`) to `Map`
  - File: `src/server/game/Maps/Map.h`
- [ ] Add `_ownedSessionsMutex` (`std::mutex`) to `Map`
- [ ] Implement `Map::AddOwnedSession(WorldSession*)` 
- [ ] Implement `Map::RemoveOwnedSession(WorldSession*)`
- [ ] Implement `Map::UpdateOwnedSessions(uint32 diff)` — drains `_recvQueue` for each session

### Player Lifecycle Hooks

- [ ] Hook `Player::SetMap()` → call `newMap->AddOwnedSession(session)`
- [ ] Hook `Player::ResetMap()` / teleport source → call `oldMap->RemoveOwnedSession(session)` on deferred list
- [ ] Verify: session is never double-updated during a teleport tick

### Main Thread Filtering

- [ ] Modify `WorldSessionMgr::UpdateSessions()` to skip sessions where `player->IsInWorld()`
  - File: `src/server/game/Server/WorldSessionMgr.cpp`
- [ ] Verify: loading screen, char select, login queue sessions still update correctly on main thread

### Cross-Session Opcodes

- [ ] Identify opcodes that touch other sessions' data:
  - Trade request/accept/cancel
  - Duel request
  - Group invite
  - Whisper (cross-session send)
  - Auction house interaction
- [ ] Implement deferred-task API: `Map::PostNextTick(std::function<void()>)` using existing `PCQueue` or new list
- [ ] Route each cross-session opcode to target map's next-tick list
- [ ] Test: trade between players on same map
- [ ] Test: trade between players on different maps
- [ ] Test: group invite across maps
- [ ] Test: duel challenge and accept

### Validation

- [ ] TSAN build — zero new races
- [ ] Stress test: login/logout storm (50 concurrent)
- [ ] Stress test: rapid teleport (bots teleport every 30s for 30 min)
- [ ] Stress test: 500 sessions, all in-world, main thread session loop is now empty
- [ ] Commit Phase 2

---

## 🟠 Phase 3 — Global Manager Thread Safety

- [ ] `ObjectMgr` — confirm all template getters are `const` and read-only post-load; add `[[nodiscard]]` annotations
- [ ] `SpellMgr` — same as ObjectMgr
- [ ] `BattlegroundMgr` — shared_mutex on `_bgDataStore` (done in Phase 1, verify complete)
- [ ] `GroupMgr` — shared_mutex on group store (done in Phase 1, verify complete)
- [ ] `GuildMgr` — shared_mutex on guild store (done in Phase 1, verify complete)
- [ ] `InstanceSaveMgr` — add `std::shared_mutex` to save map
  - File: `src/server/game/Instances/InstanceSaveMgr.h`
  - [ ] Wrap read paths with `shared_lock`
  - [ ] Wrap write paths with `unique_lock`
- [ ] `ScriptMgr` hooks — full audit of thread-safety per hook category
  - [ ] Map-local hooks (safe, document)
  - [ ] Hooks touching global state (add guard or redesign)
- [ ] `ObjectAccessor::HashMapHolder<Player>` — verify all call sites in parallel context hold shared_lock
- [ ] TSAN build — zero races
- [ ] Commit Phase 3

---

## 🔴 Phase 4 — Full Asio Strand Ownership (Long-Term)

- [ ] Add `boost::asio::strand<...>` member to `Map`
  - File: `src/server/game/Maps/Map.h`
  - Pass `IoContext` reference during `Map` construction
- [ ] Refactor `MapMgr::Update()` — post per-map work to each map's strand instead of `MapUpdater` queue
  - File: `src/server/game/Maps/MapMgr.cpp`
- [ ] Replace `MapUpdater::wait()` with `std::latch` or `boost::asio::experimental::parallel_group`
- [ ] Port teleport to strand-safe deferred add/remove
- [ ] Port all cross-session opcode dispatch to `boost::asio::post(targetMap->strand, ...)`
- [ ] Port DB async callbacks to route result back to the map strand that issued the query
- [ ] Remove `MapUpdater` class (fully replaced by strands)
- [ ] Remove `PCQueue` dependency from `MapUpdater` (class deleted)
- [ ] TSAN build — zero races
- [ ] Stress test: full protocol (all scenarios from Phases 1–2)
- [ ] Commit Phase 4

---

## 📊 Metrics Baseline (Record Before Starting)

Run these before any changes and record values here:

| Metric | Baseline | After P1 | After P2 | After P3 | After P4 |
|---|---|---|---|---|---|
| `world_update_time` avg (ms) | | | | | |
| `world_update_sessions_time` avg (ms) | | | | | |
| `map_update_time_diff` avg per map (ms) | | | | | |
| `db_queue_world` max backlog | | | | | |
| Server tick rate at 500 bots (ticks/s) | | | | | |

---

## 🧪 Stress Test Commands Reference

```bash
# TSAN Build
cmake .. -DCMAKE_BUILD_TYPE=Debug \
         -DCMAKE_CXX_FLAGS="-fsanitize=thread -g" \
         -DCMAKE_EXE_LINKER_FLAGS="-fsanitize=thread"
make -j$(nproc) && make install

# Check for sync DB warnings on world thread (look in server log)
grep "WarnSyncQuery\|sync query" logs/Server.log

# Watch metric output (if Grafana/InfluxDB connected)
# Or check Metric.Enable = 1 in conf and tail the metric log
```

---

## 📝 Notes / Discoveries

> Add findings here as work progresses. One bullet per discovery.

- 2026-04-21: Initial roadmap and checklist created on branch `feat/omw-threading`
- 2026-04-21: Quick-win conf changes applied to `worldserver.conf.dist` — `Log.Async.Enable=1`, `Network.Threads=2`, `ThreadPool=4`, `MapUpdate.Threads=4`
- 2026-04-21: Sync DB audit complete for `World.cpp` + `WorldSession.cpp` hot paths — only hot-path sync call is `SaveTutorialsData` (CHAR_SEL_HAS_TUTORIALS), low priority (fires ~every 15 min per player)
- 2026-04-21: OMW branch already had `MapUpdate.Threads=1` (not 0 like upstream) — map parallelism was already enabled; bumped to 4
- 2026-04-21: `CONFIG_NUMTHREADS` in code maps to conf key `MapUpdate.Threads` (not `NumThreads` as upstream docs suggest)
- 2026-04-21: ScriptMgr hook registries (`ScriptPointerList`, `EnabledHooks`) are read-only after startup — safe under map parallelism, no locking needed
- 2026-04-21: `HashMapHolder<Player>::Find()` already uses `shared_lock` internally — `FindPlayer`/`FindConnectedPlayer` are thread-safe
- 2026-04-21: `PlayerNameMapHolder::PlayerNameMap` is completely unguarded — `FindPlayerByName` is NOT thread-safe. Not called from `Map::Update()` today, but needs a mutex if Phase 2 session parallelism exposes it
- 2026-04-21: Phase 1 prerequisite race fixes complete: `BattlegroundMgr`, `GroupMgr`, `GuildMgr` all guarded with `shared_mutex`
