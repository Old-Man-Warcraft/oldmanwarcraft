---
name: workflow-gitlab-bug-reports
description: Handle GitLab bug reports and issues. Use when triaging bugs, linking commits to issues, or writing reproduction steps.
---

# Skill: workflow-gitlab-bug-reports

**Owner:** Old Man Warcraft
**Version:** 1.0

## Purpose

Workflow for managing issues, merge requests, and bug reports on the OMW GitLab
instance (primary origin) and GitHub mirrors.

## GitLab setup

- **Primary origin**: `https://gitlab.thecorehosting.net/root/oldmanwarcraft`
- **MCP access**: Use `gitlab-api` MCP server for programmatic access
- **Issue tracking**: All bugs and feature requests go to GitLab Issues

## Issue lifecycle

### 1. Triage
When a new issue is reported:
- [ ] Verify it's reproducible
- [ ] Assign severity label: `critical`, `major`, `minor`, `trivial`
- [ ] Assign category label: `core`, `module`, `database`, `config`, `ci`
- [ ] Link to related issues or MRs
- [ ] Assign to appropriate milestone

### 2. Investigation
- [ ] Reproduce on local/dev environment
- [ ] Check Server.log and Errors.log for related messages
- [ ] Query database for relevant state
- [ ] Identify root cause (game code, database, configuration, or upstream bug)
- [ ] Document findings in issue comments

### 3. Fix
- [ ] Create feature branch from `master`: `fix/<issue-number>-<short-description>`
- [ ] Implement fix with tests where applicable
- [ ] Include SQL updates if database changes needed
- [ ] Test locally
- [ ] Create Merge Request with `Closes #<issue-number>` in description

### 4. Review
- [ ] Code review by another developer
- [ ] CI passes (compile, tests, code standards)
- [ ] If production-affecting: invoke `production-deploy-review` agent
- [ ] Merge to `master`

### 5. Deploy
- [ ] Follow deployment workflow in `workflow-deployment-and-testing`
- [ ] Verify fix on production
- [ ] Close issue

## Commit message format

```
Type(Scope/Subscope): Short description (max 50 chars)

Longer description if needed (max 72 chars per line).

Closes #<issue-number>
```

- **Types**: feat, fix, refactor, style, docs, test, chore
- **Scopes**: Core (C++), DB (SQL), Scripts, Module/<name>, CI, Tools
- **Examples**:
  - `fix(Core/Spells): Fix damage calculation for Fireball`
  - `fix(DB/SAI): Missing spell to NPC Hogger`
  - `feat(Module/Playerbots): Add new bot strategy for healing`

## Merge request template

```markdown
## Description
Brief description of changes

## Related Issue
Closes #<issue-number>

## Type of change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update
- [ ] CI/CD change

## Testing
- [ ] Tested locally
- [ ] Unit tests pass
- [ ] Code standards pass
- [ ] SQL updates applied correctly

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have commented my code where needed
- [ ] I have added SQL updates if DB changes made
- [ ] I have updated documentation if needed
```

## Upstream bug reports

For bugs that originate in upstream AzerothCore:
1. Verify the bug exists in upstream too (test on clean AC build if possible)
2. Search upstream GitHub Issues for existing report
3. If not found, create issue on `https://github.com/azerothcore/azerothcore-wotlk`
4. Link GitLab issue to GitHub issue
5. If fix is made locally, consider submitting PR upstream

## Module-specific issues

- Check if the module has its own issue tracker on GitHub
- Playerbots: `https://github.com/liyunfan1223/azerothcore-wotlk/issues`
- Other modules: Check module's README or CMakeLists.txt for upstream links

## GitLab MCP tools

Use `gitlab-api` MCP server for:
- Creating/updating issues
- Searching issues
- Creating merge requests
- Commenting on issues/MRs
- Managing labels and milestones