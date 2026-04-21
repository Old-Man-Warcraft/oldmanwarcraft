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
- [~] Build with ThreadSanitizer — **infeasible on current hardware**
  - TSAN `.o` files are ~3-4x larger; full build would require ~50G, only 35G available
  - Build reverted to `RelWithDebInfo` (debug symbols retained for crash analysis)
  - Alternative: run stress test on live dev realm and monitor crash logs
- [~] Run dev realm with 200+ bots — monitor logs for deadlocks/crashes (replacing TSAN)
- [ ] Fix any deadlock/crash reported in logs
- [ ] Re-run stress test — clean run
- [ ] Run stress test: 500 bots across 5 continents (30 min uptime)
- [ ] Run stress test: 100 bots in same instance
- [ ] Run stress test: mass BG population (40v40 sim)
- [ ] Run stress test: server shutdown under load
- [ ] Update `worldserver.conf.dist` — document recommended `NumThreads` value
- [ ] Commit Phase 1

---

## 🟡 Phase 2 — Map-Owned Session Updates

### Infrastructure

- [x] Add `_ownedSessions` (`std::vector<WorldSession*>`) to `Map`
  - File: `src/server/game/Maps/Map.h`
- [x] Add `_ownedSessionsMutex` (`std::mutex`) to `Map`
- [x] Implement `Map::AddOwnedSession(WorldSession*)` — locks mutex, appends to `_ownedSessions`
- [x] Implement `Map::RemoveOwnedSession(WorldSession*)` — locks mutex, erases from `_ownedSessions`
- [x] Implement `Map::UpdateOwnedSessions(uint32 diff)` — snapshots session list under lock, then calls `session->Update(diff, MapSessionFilter)` for each

### Player Lifecycle Hooks

- [x] Hook `Player::SetMap()` → `map->AddOwnedSession(GetSession())` after `m_mapRef.link()`
- [x] Hook `Player::ResetMap()` → `GetMap()->RemoveOwnedSession(GetSession())` before `Unit::ResetMap()`
- [ ] Verify: session is never double-updated during a teleport tick (needs TSAN + stress test)

### Main Thread Filtering

- [x] Modify `WorldSessionMgr::UpdateSessions()` to skip sessions where `player && player->IsInWorld()`
  - Pre-login / char-select / loading sessions still updated on main thread
  - In-world sessions delegated to `Map::UpdateOwnedSessions()` on map worker thread
  - File: `src/server/game/Server/WorldSessionMgr.cpp`
- [ ] Verify: loading screen, char select, login queue sessions still update correctly on main thread
- [x] Wire `Map::Update()` to call `UpdateOwnedSessions(s_diff)` instead of inline session loop
  - Sub-tick `!t_diff` player `Update()` split out into separate guarded block
  - Full-tick player update loop at line ~464 unchanged (game logic only, no packet processing)

### Cross-Session Opcodes

- [ ] Identify opcodes that touch other sessions' data:
  - Trade request/accept/cancel
  - Duel request
  - Group invite
  - Whisper (cross-session send)
  - Auction house interaction
- [x] Implement deferred-task API: `Map::PostNextTick(std::function<void()>)` + `Map::DrainNextTickTasks()`
  - `PostNextTick`: locks `_nextTickTasksMutex`, appends to `_nextTickTasks`
  - `DrainNextTickTasks`: swaps queue under lock, executes all tasks on the map thread
  - Called at top of `Map::Update()` before session and object updates
- [x] Route group invite cross-session send through `PostNextTick` on target map
  - File: `src/server/game/Handlers/GroupHandler.cpp`
  - `invitedPlayer->SendDirectMessage` now deferred via `targetMap->PostNextTick([invitedGuid, packet]())`
  - Fallback to direct send if `FindMap()` returns null (player not in world yet)
- [x] Route trade request initiation through `PostNextTick`
  - File: `src/server/game/Handlers/TradeHandler.cpp` — `HandleInitiateTradeOpcode`
  - `pOther->GetSession()->SendTradeStatus(info)` deferred via `pOther->FindMap()->PostNextTick`
- [x] Route duel request through `PostNextTick`
  - File: `src/server/game/Spells/SpellEffects.cpp` — `SPELL_EFFECT_DUEL`
  - `target->SendDirectMessage(SMSG_DUEL_REQUESTED)` deferred via `target->FindMap()->PostNextTick`
- [x] Route whisper cross-session send through `PostNextTick`
  - File: `src/server/game/Entities/Player/Player.cpp` — `Player::Whisper`
  - `target->SendDirectMessage(CHAT_MSG_WHISPER)` deferred via `target->FindMap()->PostNextTick`
- [ ] Test: group invite across maps
- [ ] Test: trade request across maps
- [ ] Test: duel challenge and accept

### Validation

- [~] TSAN build — skipped (insufficient disk for TSAN build artifacts; cmake set to RelWithDebInfo)
- [x] Server startup test — clean start, no errors, no crashes (`feat/omw-threading` branch)
  - Full `./acore.sh compiler build` successful (11m27s), exit 0
  - Server `active` post-restart, bots initializing normally
- [ ] Stress test: login/logout storm (50 concurrent)
- [ ] Stress test: rapid teleport (bots teleport every 30s for 30 min)
- [ ] Stress test: 500 sessions, all in-world, main thread session loop is now empty
- [x] Commit Phase 2 — committed as `560fa621e`

---

## 🟠 Phase 3 — Global Manager Thread Safety

- [x] `ObjectMgr::GetCreatureTemplate` + `GetItemTemplate` — added `const` + `[[nodiscard]]`
- [x] `SpellMgr::GetSpellInfo` — already `const [[nodiscard]]`, no change needed
- [x] `BattlegroundMgr` — `_bgDataStoreLock` `std::shared_mutex` confirmed present (Phase 1)
- [x] `GroupMgr` — `_groupStoreLock` `std::shared_mutex` confirmed present (Phase 1)
- [x] `GuildMgr` — `_guildStoreLock` `std::shared_mutex` confirmed present (Phase 1)
- [x] `InstanceSaveMgr` — added `_instanceSaveMutex` + `_playerBindMutex` (`std::shared_mutex`)
  - Read paths (`GetInstanceSave`, `PlayerGetBoundInstance`, `PlayerGetBoundInstances`) → `shared_lock`
  - Write paths (`AddInstanceSave`, `DeleteInstanceSaveIfNeeded`, `_ResetSave`, `PlayerBindToInstance`, `PlayerUnbindInstance`, `PlayerUnbindInstanceNotExtended`, `PlayerCreateBoundInstancesMaps`) → `unique_lock`
- [ ] `ScriptMgr` hooks — full audit of thread-safety per hook category
  - [ ] Map-local hooks (safe, document)
  - [ ] Hooks touching global state (add guard or redesign)
- [ ] `ObjectAccessor::HashMapHolder<Player>` — verify all call sites in parallel context hold shared_lock
- [x] TSAN build — zero races (5 min runtime, RelWithDebInfo + -fsanitize=thread, NOJEM=1, mmap_rnd_bits=28)
- [x] Commit Phase 3

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
- 2026-04-21: Phase 2 infrastructure complete: `Map::_ownedSessions` + mutex, `AddOwnedSession`/`RemoveOwnedSession` hooked into `Player::SetMap`/`ResetMap`, `UpdateOwnedSessions` wired into `Map::Update`, `WorldSessionMgr::UpdateSessions` skips in-world sessions
