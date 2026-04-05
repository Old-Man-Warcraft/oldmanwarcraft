---
name: workflow-deployment-and-testing
description: >-
  Production deployment, verification, log review, and rollback for this Old Man Warcraft
  AzerothCore host. Use when shipping changes, restarting worldserver, or validating live logs.
---

# Deployment and testing workflow (production)

## Context

This environment is **production-only** on this host: there is no local second realm for throwaway testing. Every change should assume **players and shared `acore_world` data** are in scope. Prefer **backups**, **maintenance windows**, and **off-host or containerized experiments** when you need a sandbox.

## Principles

- Backup **world**, **characters**, and **playerbots** databases before invasive SQL or upgrades.
- Order of operations typical: **compile/install** (if C++ changed) → **apply SQL** (if any) → **restart** during agreed window → **monitor logs**.
- Log paths may be `env/dist/logs/` or a bind mount such as `/data/logs/`—confirm the live path before tailing.
- After deploy: scan for `error`, `critical`, `fatal`; confirm custom modules report load success.

## Pre-deployment checklist

### Code

- [ ] Builds clean (or only known warnings)
- [ ] No stray debug logging or test-only toggles
- [ ] Upstream merge conflicts resolved with OMW customizations documented

### Database

- [ ] SQL files follow `YYYY_MM_DD_XX_description.sql` where applicable
- [ ] Impact on **shared** tables understood (creatures, spells, loot, SmartAI, conditions)
- [ ] Fresh `mysqldump` (or equivalent) completed and stored safely

### Configuration

- [ ] `.conf` / env matches dist changes (merge `.conf.dist` updates deliberately)
- [ ] Secrets not committed; production-only values only on the server

### Operational

- [ ] Restart window communicated if players are affected
- [ ] Rollback path defined (DB restore + previous binary or `git revert`)

## Deployment steps (typical bare-metal style)

Adjust service names and paths to match Notion runbooks or your actual systemd/docker layout.

### 1. Back up databases

```bash
mysqldump -uacore -pacore acore_world > backup_world_$(date +%Y%m%d_%H%M%S).sql
mysqldump -uacore -pacore acore_characters > backup_characters_$(date +%Y%m%d_%H%M%S).sql
mysqldump -uacore -pacore acore_playerbots > backup_playerbots_$(date +%Y%m%d_%H%M%S).sql
ls -lh backup_*.sql
```

### 2. Stop worldserver

```bash
service ac-worldserver stop
systemctl status ac-worldserver
```

### 3. Apply SQL (if any)

```bash
mysql -uacore -pacore acore_world < data/sql/updates/db_world/YYYY_MM_DD_XX_description.sql
mysql -uacore -pacore acore_world -e "SELECT COUNT(*) FROM your_table;"
```

### 4. Build and install (if C++ changed)

```bash
cd /root/azerothcore-wotlk/build
cmake .. -DCMAKE_INSTALL_PREFIX=../env/dist
make -j$(nproc)
make install   # if your workflow uses install
```

### 5. Configuration

```bash
# Merge dist into live config as needed
cp conf/dist/modules/some_module.conf.dist env/dist/etc/modules/some_module.conf
# edit, then verify non-empty active settings
```

### 6. Start and verify

```bash
service ac-worldserver start
sleep 5
systemctl status ac-worldserver
tail -n 200 env/dist/logs/Server.log
# or: tail -n 200 /data/logs/Server.log
grep -iE "error|critical|fatal" env/dist/logs/Server.log | tail -30
```

## Rollback

1. Stop worldserver.
2. Restore affected DB from the pre-change dump.
3. Revert code or redeploy previous artifact (`git revert`, previous container image, etc.).
4. Restart; monitor logs; document root cause.

## Post-deploy monitoring

- Same day: errors in logs, crash loops, player reports, queue/LFG/bot hotspots.
- After upstream merges: re-run full compile, apply **all** pending SQL in order, smoke-test key encounters and bot commands.

## Related

- `.cursor/rules/deployment-rules.mdc`
- `.cursor/docs/crash-debugging.md`
- `.cursor/rules/mcp-usage.mdc` and `.cursor/reference/mcp-tools-inventory.md`
- **MCP toolkit**: **Notion** (`notion-search`, `notion-fetch`) for runbooks/paths; **azerothcore** (`soap_check_connection`, `soap_server_info`, `soap_reload_table` when allowed); **oldmanwarcraft-api-remote** (`omw_get_server_status`, `omw_health_check`); **GitLab-MCP** for MRs/releases tied to deploys; **fetch** / **firecrawl** for vendor or AC docs during cutover prep
