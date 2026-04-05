---
description: "Use when editing files under modules/, adding module features, changing module SQL, or debugging module-specific behavior. Covers module boundaries, git history pitfalls, and safe module workflows."
name: "AzerothCore Module Instructions"
applyTo: "modules/**"
---
# Module Guidelines

- Treat each directory under `modules/` as potentially independent from the main repository for history, status, and diff inspection.
- Preserve module-local structure and conventions before applying core-wide patterns; check the module's `README.md` and `CMakeLists.txt` when present.
- Keep module changes targeted. Do not refactor across unrelated modules as part of feature or bug-fix work.
- For module SQL, prefer canonical paths under the module's `data/sql/` tree and avoid optional or uninstall helpers unless explicitly requested.
- If a module change requires core integration, keep the module-specific behavior in the module and touch core code only when the integration point truly belongs there.

See [modules/how_to_make_a_module.md](../../modules/how_to_make_a_module.md), [CLAUDE.md](../../CLAUDE.md), and [.github/copilot-instructions.md](../copilot-instructions.md).