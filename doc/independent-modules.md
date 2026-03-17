# Independent Module Tracking

This workspace is transitioning away from superproject-pinned module gitlinks.

## Goal

- Keep the main repository and each module repository independently tracked.
- Stop using the superproject to pin module SHAs.
- Preserve the existing `modules/` build layout so CMake and runtime paths do not move.

## New Workflow Artifacts

- Module manifest: `apps/git_tools/modules.manifest`
- Independent sync script: `apps/git_tools/independent-repo-update.sh`
- Migration helper: `apps/git_tools/migrate-modules-off-submodules.sh`

## Migration Strategy

1. Ensure each module under `modules/` is a valid standalone Git repository.
2. Use the migration helper in dry-run mode to see which gitlinks and `.gitmodules` entries will be removed.
3. Re-run with `--apply` when ready.
4. Add ignore rules for module repositories so the superproject stops surfacing them as pinned paths.
5. Commit the superproject changes separately from any module code changes.

## Commands

Dry-run the full migration:

```bash
apps/git_tools/migrate-modules-off-submodules.sh
```

Dry-run a single module:

```bash
apps/git_tools/migrate-modules-off-submodules.sh --module mod-playerbots
```

Apply the migration:

```bash
apps/git_tools/migrate-modules-off-submodules.sh --apply
```

Update independently tracked repos afterward:

```bash
apps/git_tools/independent-repo-update.sh
apps/git_tools/independent-repo-update.sh --module mod-playerbots
```

## Notes

- The migration helper does not commit anything.
- Dirty module working trees are preserved.
- The helper only removes superproject gitlinks and `.gitmodules` entries; module history stays in each module repository.
- Add the suggested `.gitignore` block before treating the migration as complete.