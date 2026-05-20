---
name: workflow-deployment-and-testing
description: Build, deploy, restart, and test AzerothCore server changes. Use when deploying code or SQL, restarting worldserver/authserver, running tests, or validating deployments.
---

# Skill: workflow-deployment-and-testing

**Owner:** Old Man Warcraft
**Version:** 1.0

## Purpose

End-to-end workflow for building, testing, deploying, and restarting the
AzerothCore server (authserver + worldserver) in both local and production
environments.

## Build

### Full build

```bash
cd /root/azerothcore-wotlk
./acore.sh compiler all
```

Or manually:
```bash
mkdir -p build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/azeroth-server -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DSCRIPTS=static -DMODULES=static
make -j$(nproc)
make install
```

### Build with tests

```bash
cd /root/azerothcore-wotlk
./acore.sh compiler all TEST
```

Or manually:
```bash
cmake .. -DBUILD_TESTING=ON
make -j$(nproc)
```

### Build only worldserver (after code changes)

```bash
cd /root/azerothcore-wotlk
./acore.sh compiler build
```

## Test

### Unit tests
```bash
cd /root/azerothcore-wotlk/build
ctest
# or
./src/test/unit_tests
```

### Code standards
```bash
cd /root/azerothcore-wotlk
python3 apps/codestyle/codestyle-cpp.py
python3 apps/codestyle/codestyle-sql.py
```

### Bash tests
```bash
cd /root/azerothcore-wotlk
./apps/test-framework/run-bash-tests.sh
```

## Docker (local dev)

```bash
# Start
docker compose up -d

# Logs
docker compose logs -f ac-worldserver

# Stop
docker compose down
```

## Production deploy

**Always invoke `production-deploy-review` agent before any production action.**

### Build for production
```bash
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DSCRIPTS=static -DMODULES=static
make -j$(nproc)
make install
```

### Apply SQL updates
1. Check `data/sql/updates/pending_*` for pending SQL
2. Apply world DB updates: `mysql -u acore -p acore_world < file.sql`
3. Apply character DB updates: `mysql -u acore -p acore_characters < file.sql`
4. Apply auth DB updates: `mysql -u acore -p acore_auth < file.sql`

### Restart services
```bash
sudo systemctl restart azerothcore-worldserver
sudo systemctl restart azerothcore-authserver
```

### Verify
```bash
# Check service status
sudo systemctl status azerothcore-worldserver
sudo systemctl status azerothcore-authserver

# Tail logs
tail -f /path/to/Server.log
tail -f /path/to/Errors.log
```

## Rollback

If deploy fails:
1. Stop services
2. Restore previous binaries from backup
3. Apply rollback SQL (prepared by `production-deploy-review` agent)
4. Restore previous config files
5. Start services
6. Verify

## Common issues

| Symptom | Likely cause | Fix |
|---|---|---|
| worldserver won't start | Missing SQL update | Apply pending SQL |
| worldserver crashes on start | Config mismatch | Check .conf.dist vs .conf |
| Module not loading | .so not compiled | Check CMake config, rebuild |
| DB connection refused | MySQL down | `sudo systemctl restart mysql` |
| Port already in use | Stale process | `pkill worldserver` then restart |