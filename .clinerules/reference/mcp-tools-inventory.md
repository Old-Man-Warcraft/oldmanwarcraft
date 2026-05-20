# MCP Tools Inventory

## Server: mysql-azerothcore-wotlk

Database access for world, characters, and auth databases.

| Tool | Description |
|---|---|
| `query` | Execute parameterized SQL query |

## Server: notion-api

OMW Notion workspace access.

| Tool | Description |
|---|---|
| `search` | Search Notion pages |
| `get_page` | Retrieve page content |
| `get_database` | Query Notion database |

## Server: gitlab-api

GitLab (thecorehosting.net) access.

| Tool | Description |
|---|---|
| `create_issue` | Create a new issue |
| `search_issues` | Search existing issues |
| `create_merge_request` | Create a merge request |
| `comment_on_issue` | Add comment to issue |
| `get_issue` | Retrieve issue details |

## Server: github-api

GitHub upstream reference access.

| Tool | Description |
|---|---|
| `search_issues` | Search upstream issues |
| `get_issue` | Retrieve issue details |
| `create_issue` | Create upstream issue |
| `search_repositories` | Search for repos |

## General rules

1. Route database queries through `mysql-azerothcore-wotlk`
2. Route documentation lookups through `notion-api`
3. Route issue tracking through `gitlab-api` (primary) or `github-api` (upstream)
4. Never hardcode credentials — always use MCP