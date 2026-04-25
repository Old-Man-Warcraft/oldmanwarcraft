# OMW Threading Work Checklist

> Branch: `feat/omw-threading`
> Reference: [threading-roadmap.md](threading-roadmap.md)
> Last updated: 2026-04-25

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

- [~] Split `WorldSessionMgr::UpdateSessions()` responsibilities between world thread and map thread
  - **Current state:** in-world sessions are still visited on the world thread for `PROCESS_THREADUNSAFE` packets and session-only maintenance, guarded by `WorldSession::_updateMutex`
  - **Current state:** map threads also call `Map::UpdateOwnedSessions()` for map-safe packet handling
  - **Decision needed:** either keep this dual-owner model and document it as intentional, or finish the original "main thread skips in-world sessions" design
  - **Follow-up if dual-owner stays:** remove head-of-line blocking between world-thread and map-thread packet consumers in `LockedQueue::next(packet, filter)` semantics
  - File: `src/server/game/Server/WorldSessionMgr.cpp`
- [ ] Verify: loading screen, char select, login queue sessions still update correctly on main thread
- [x] Wire `Map::Update()` to call `UpdateOwnedSessions(s_diff)` instead of inline session loop
  - Sub-tick `!t_diff` player `Update()` split out into separate guarded block
  - Full-tick player update loop at line ~464 unchanged (game logic only, no packet processing)

### Cross-Thread Lifecycle Hazards

- [x] Move source-map player removal onto the source map strand for far teleports
  - Updated paths: `src/server/game/Handlers/MovementHandler.cpp`, `src/server/game/Entities/Player/Player.cpp`
  - Added `Map::ExecuteOnStrandAndWait(std::function<void()>)` and routed old-map `RemovePlayerFromMap` / `ResetMap` / `AfterPlayerUnlinkFromMap()` through the owning strand
- [x] Move raid/shared-difficulty forced player shuffles onto the source map strand
  - Updated path: `src/server/game/Handlers/MiscHandler.cpp`
  - Forced temporary ejection/re-entry flow now performs old-map detach work on the source map strand before retargeting the player map
- [~] Guarantee `Map::m_mapRefMgr` mutation only happens on the owning map thread/strand
  - Teleport and shared-difficulty shuffle flows now use the source map strand
  - Remaining work: audit any other `RemovePlayerFromMap` / `ResetMap` / `GetMapRef().unlink()` paths outside these known flows
- [ ] Stress test rapid teleport / instance transfer / difficulty change under load
  - 200+ bots changing maps every 30 seconds for 30 min
  - Group difficulty switch while players are inside ICC/RS-style shared-difficulty maps

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
- [ ] Stress test: login/logout storm (50 concurrent) — requires manual verification
- [ ] Stress test: rapid teleport (bots teleport every 30s for 30 min) — requires manual verification
- [ ] Stress test: 500 sessions, all in-world, verify world-thread maintenance path and map-thread packet path do not contend excessively — requires manual verification
- [ ] Stress test: mixed packet workload with thread-unsafe opcodes at queue head
  - Goal: verify no starvation / queue ordering regressions when world-thread and map-thread consumers share `_recvQueue`
- [x] Teleport session verification — no double updates
  - `Map::UpdateOwnedSessions` updates in-world players on map thread
  - `WorldSessionMgr::UpdateSessions` still handles thread-unsafe packets and maintenance on the world thread under `_updateMutex`
  - During teleport: `RemovePlayerFromMap` sets `m_inWorld = false`, session work falls back to the world-thread path
  - After teleport: `AddPlayerToMap` sets `m_inWorld = true`, map-thread packet handling resumes
  - Mutex-protected `_ownedSessions` list prevents obvious double-add/remove, but source-map strand ownership is still unfinished
- [x] Char-select/login session verification — updates on main thread
  - Before `AddPlayerToMap`: `m_inWorld = false`, session updated by main thread
  - After `AddPlayerToMap`: `m_inWorld = true`, session updated by map thread
  - Session ownership correctly transferred via `SetMap`/`ResetMap` hooks
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
- [x] `ScriptMgr` hooks — audit complete, all hooks safe
  - **Map-local hooks** (called on map thread): OnMapUpdate, OnPlayerEnterMap, OnPlayerLeaveMap, OnDestroyMap, OnCreateMap, OnWeatherUpdate, OnWeatherChange, OnUnitUpdate, OnPlayerUpdate, OnPlayerBeforeUpdate, OnPlayerAfterUpdate, OnPlayerCanUpdateSkill, OnPlayerBeforeUpdateSkill, OnPlayerAfterUpdateMaxHealth, OnPlayerAfterUpdateMaxPower, OnPlayerBeforeUpdateAttackPowerAndDamage, OnPlayerAfterUpdateAttackPowerAndDamage
  - **Global manager hooks** (managers have shared_mutex from Phase 1): OnGroup* (GroupMgr), OnGuild* (GuildMgr), OnPlayerReputationChange/OnPlayerReputationRankChange (ObjectMgr const getters)
  - **Main-thread only hooks**: OnSocketOpen, OnSocketClose, OnNetworkStart, OnNetworkStop, OnMotdChange, OnTicket*, OnAfterDatabaseLoadCreatureTemplates, OnPlayerbotCheckLFGQueue, OnPlayerCanJoinLfg (LFGMgr called from World::Update)
  - **Instance hooks** (InstanceSaveMgr now has mutex): OnDestroyInstance, OnBeforeCreateInstanceScript, OnAfterUpdateEncounterState
- [x] `ObjectAccessor::HashMapHolder<Player>` — verified, all call sites hold lock
  - `HashMapHolder<T>::Find` uses internal `shared_lock` — thread-safe
  - `ObjectAccessor::GetPlayers()` returns container without lock — callers verified:
    - `SaveAllPlayers` (ObjectAccessor.cpp:264) — holds `shared_lock`
    - `DoForAllOnlinePlayers` (WorldSessionMgr.cpp:427) — holds `shared_lock`
    - `Map::GetPlayers()` calls are map-local (`m_mapRefMgr`) — safe
- [x] Synchronize `BattlegroundMgr::m_QueueUpdateScheduler`
  - Protected scheduler `swap`/`find`/`emplace_back` with `_queueUpdateSchedulerMutex`
  - File: `src/server/game/Battlegrounds/BattlegroundMgr.cpp`
- [x] Replace `WorldSessionMgr::GetAllSessions()` raw container exposure with a thread-safe API path
  - Removed `GetAllSessions()` from `WorldSessionMgr`
  - Switched world-range/session fanout call sites to `DoForAllOnlinePlayers()`
  - Updated callers in `CreatureTextMgr`, `ChatHandler`, `World`, `InstanceSaveMgr`, `CharacterHandler`, and global message helpers
- [x] Replace unlocked bind reference APIs in `InstanceSaveMgr`
  - `PlayerGetBoundInstance()` now returns `std::optional<InstancePlayerBind>`
  - `PlayerGetBoundInstances()` now returns a copy (`BoundInstancesMap`)
  - Added `PlayerSetBoundInstanceExtended()` for the calendar toggle mutation path
- [x] Audit global world/session fanout from map-thread reachable code
  - `CreatureTextMgr::SendChatPacket(... TEXT_RANGE_WORLD ...)` and non-chat world fanout now iterate via `DoForAllOnlinePlayers()`
  - No remaining `GetAllSessions()` calls under `src/server/game/**`
- [x] Build validation for Phase 3 hardening
  - Incremental `game` target build succeeded after the API changes
  - Full workspace build was previously blocked by an unrelated pre-existing `mod-ale` override signature error
  - User later confirmed the build succeeded after follow-up rebuild/cleanup
- [x] TSAN build — zero races (5 min runtime, RelWithDebInfo + -fsanitize=thread, NOJEM=1, mmap_rnd_bits=28)
- [x] Commit Phase 3 — committed as 522fac4c5 (TSAN validation)

---

## 🔴 Phase 4 — Full Asio Strand Ownership (Long-Term)

- [x] Add `Acore::Asio::Strand` member to `Map` + `GetStrand()` accessor
  - File: `src/server/game/Maps/Map.h` — `_strand` member in private section, `GetStrand()` in public
  - `MapMgr::SetIoContext()` / `GetIoContext()` added to `MapMgr.h`
  - `Main.cpp`: `sMapMgr->SetIoContext(*ioContext)` called before `sWorld->SetInitialWorldSettings()`
  - `Map.cpp`: `_strand(*sMapMgr->GetIoContext())` in constructor initialiser list
- [x] Refactor `MapMgr::Update()` — post per-map work to each map's strand with `std::latch` barrier
  - File: `src/server/game/Maps/MapMgr.cpp`
  - When `_ioContext != nullptr`: `boost::asio::post(map->GetStrand(), ...)` for every map; `latch.wait()` replaces `m_updater.wait()`
  - Falls back to existing `MapUpdater` / inline path when `_ioContext == nullptr`
- [x] Port child-instance scheduling in `MapInstanced::Update()` to strand + `std::latch`
  - File: `src/server/game/Maps/MapInstanced.cpp`
  - Same pattern: collect live child maps → post each to its strand → `latch.wait()`
  - Falls back to `MapUpdater` / inline when IoContext unavailable
- [x] Replace `MapUpdater::wait()` with `std::latch` (done above in strand path)
  - `MapUpdater` class retained as fallback for `_ioContext == nullptr` case
- [~] Port teleport to strand-safe deferred add/remove
  - File: `src/server/game/Handlers/MovementHandler.cpp` — `HandleMoveWorldportAck()`
  - ✅ Cross-map teleport destination add is posted to `newMap->GetStrand()` via `std::latch`; same-map runs inline to avoid deadlock
  - ✅ `Map::AddOwnedSession` made idempotent (dedup guard) to prevent double-add from `SetMap` + `AddPlayerToMap` both calling it
  - ❌ Source-map removal still happens directly on world-thread call paths (`HandleMoveWorldportAck`, `Player::TeleportTo`, shared-difficulty shuffle in `MiscHandler.cpp`)
  - **Remaining work:** move source-map removal/unlink to `oldMap->GetStrand()` and make all map-player list mutation strand-owned
- [x] Port all cross-session opcode dispatch to `boost::asio::post(targetMap->GetStrand(), ...)`
  - `src/server/game/Handlers/GroupHandler.cpp` — group invite
  - `src/server/game/Handlers/TradeHandler.cpp` — trade initiation
  - `src/server/game/Spells/SpellEffects.cpp` — duel request
  - `src/server/game/Entities/Player/Player.cpp` — whisper
- [x] Port DB async callbacks to route result back to the map strand that issued the query
  - `WorldSession::ProcessQueryCallbacks()` is called from `WorldSession::Update()` which Phase 2 already moved to the map worker thread — callbacks land on the correct strand automatically
  - `World::ProcessQueryCallbacks()` handles World-level queries on main thread — intentional, no change needed
- [ ] Replace direct world/session fanout APIs used from map-thread reachable code
  - Remove raw `GetAllSessions()` iteration from map-thread reachable paths
  - Convert world-range text/broadcast helpers to thread-safe snapshots or world-thread dispatch
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
- 2026-04-21: Added `std::shared_mutex` protection to `PlayerNameMapHolder::PlayerNameMap` and made rename updates atomic via `UpdatePlayerNameMapReference()`. This closes a Phase 2 follow-up race for handlers that do `FindPlayerByName()` on map worker threads (chat, group, guild, arena, calendar).
- 2026-04-21: Phase 1 prerequisite race fixes complete: `BattlegroundMgr`, `GroupMgr`, `GuildMgr` all guarded with `shared_mutex`
- 2026-04-21: Phase 2 infrastructure complete: `Map::_ownedSessions` + mutex, `AddOwnedSession`/`RemoveOwnedSession` hooked into `Player::SetMap`/`ResetMap`, `UpdateOwnedSessions` wired into `Map::Update`; later review showed `WorldSessionMgr::UpdateSessions` still intentionally visits in-world sessions for thread-unsafe packets and maintenance
- 2026-04-21: Phase 4 partial — strand infrastructure complete. `Acore::Asio::Strand _strand` added to `Map`; `MapMgr::SetIoContext()` / `GetIoContext()` added; `Main.cpp` passes IoContext before world init; `MapMgr::Update()` and `MapInstanced::Update()` now post to per-map strands with `std::latch` completion barrier when IoContext is set (falls back to MapUpdater otherwise). All four cross-session opcode sends ported to `boost::asio::post(strand)`. Remaining: teleport strand-safety, DB callback routing to map strand, MapUpdater removal.
- 2026-04-25: Review found Phase 4 teleport work is only half-finished — destination map add is strand-owned, but source map removal still mutates `m_mapRefMgr` from world-thread paths (`MovementHandler`, `Player::TeleportTo`, `MiscHandler`)
- 2026-04-25: `BattlegroundMgr::ScheduleQueueUpdate()` still pushes into `m_QueueUpdateScheduler` without synchronization; code comment already marks it as needing atomic protection
- 2026-04-25: `WorldSessionMgr::GetAllSessions()` returns the raw session container by reference; `CreatureTextMgr` world-range broadcast paths iterate it from map-thread reachable code, creating a real cross-thread container access risk
- 2026-04-25: `InstanceSaveMgr::PlayerGetBoundInstance()` / `PlayerGetBoundInstances()` return unlocked pointers/references into lock-protected storage; safe enough for single-threaded call flows, unsafe as map-thread ownership expands
- 2026-04-25: Current dual world-thread/map-thread session update split is functionally plausible because of `WorldSession::_updateMutex`, but it adds contention and can cause head-of-line blocking when the front packet belongs to the other execution place
