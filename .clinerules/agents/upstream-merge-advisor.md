---
description: GitLab vs GitHub upstream, modules/* nested repos, conflict strategy
---

# Agent: upstream-merge-advisor

**Owner:** Old Man Warcraft
**Status:** stable
**Mode:** ACT

## Purpose

Guide safe upstream merges from GitHub AzerothCore (and module upstreams) into
the GitLab-based Old Man Warcraft fork. Handles the complexity of nested Git
repositories in `modules/*`.

## Triggers

- "merge upstream", "sync with upstream", "pull from AC"
- Any attempt to rebase or merge from GitHub remotes
- Module-specific upstream update requests

## Inputs required

- Target upstream remote (usually `upstream` = GitHub AzerothCore or module upstream)
- Current branch and any local changes
- List of modules that need syncing (or "all")

## Strategy

### Root repository (core)

1. Fetch upstream: `git fetch upstream`
2. Identify divergence: `git log upstream/master..HEAD --oneline` (commits we have that upstream doesn't)
3. Merge with strategy: `git merge upstream/master` (prefer merge over rebase for production stability)
4. Resolve conflicts favoring upstream game logic; keep OMW customizations documented with `OMW:` comments

### Module repositories (`modules/*`)

Each module may have its own `origin` (GitLab) and `upstream` (GitHub):

1. `cd modules/<name>`
2. `git fetch upstream`
3. Check for local changes: `git status`
4. Merge or rebase, respecting module-specific conventions
5. Check module SQL updates: new files in `data/sql/` must be applied in order

### Post-merge checklist

- [ ] Full recompile (`./acore.sh compiler all`)
- [ ] Apply any new SQL updates from `data/sql/updates/`
- [ ] Apply any new module SQL updates from `modules/*/data/sql/`
- [ ] Check `worldserver.conf.dist` for new config options
- [ ] Smoke test: start server, verify no crashes
- [ ] Watch `Server.log` and `Errors.log` for regressions

## Common pitfalls

- **Submodule vs subtree**: If a module was converted from submodule, use `git subtree` commands
- **Module interdependencies**: Some modules depend on others (e.g., mod-playerbots); sync order matters
- **SQL conflicts**: Upstream may rename/reorder SQL update files; always verify the update chain
- **Config drift**: New upstream config options need corresponding production config updates

## Output

A structured report:
```
--- upstream merge report ---
Branch: master
Upstream: upstream/master
Modules synced: [list]
SQL updates applied: [count]
Compile status: [OK / FAILED]
Runtime status: [OK / FAILED]
Conflicts resolved: [list]
Action items: [list]