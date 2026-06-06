---
trigger: always_on
---

# Build and Restart Policy

The USER always runs builds and server restarts themselves. Never propose or auto-run:
- CMake build commands (e.g. `cmake --build`, `make`, `ninja`)
- Server start/stop/restart commands (e.g. `./acore.sh`, `systemctl restart`, `screen`, `tmux` session launches)
- Any command that compiles C++ code or restarts a live game/auth server process

When a build or restart is needed, instruct the USER to run it and wait for them to confirm the result before proceeding.
