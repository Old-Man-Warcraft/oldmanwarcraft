# MCP tool inventory (OMW / AzerothCore workspace)

Cursor exposes tools under **server** names (e.g. `user-azerothcore`, `plugin-notion-workspace-notion`). Exact names in the IDE may differ slightly; use the MCP panel to confirm. **Full catalog** of JSON descriptors: `~/.cursor/projects/<workspace>/mcps/<server>/tools/`.

**Policy:** Prefer these tools over guessing URLs, DB contents, GitLab state, or site API behavior—subject to production safety and permissions.

---

## 1. `azerothcore` (local SSE — `user-azerothcore`)

### SOAP / server
`soap_check_connection`, `soap_server_info`, `soap_execute_command`, `soap_reload_table`

### Database
`query_database`, `get_table_schema`, `list_tables`

### SmartAI
`get_smart_scripts`, `get_smartai_source`, `explain_smart_script`, `trace_script_chain`, `generate_comment_for_script`, `generate_comments_for_scripts_batch`, `generate_sai_comments`, `list_smart_event_types`, `list_smart_action_types`, `list_smart_target_types`

### Spells / DBC / procs
`search_spells`, `search_spells_dbc`, `get_spell_from_dbc`, `get_spell_name`, `get_spell_name_dbc`, `batch_lookup_spell_names_dbc`, `lookup_spell_names`, `get_spell_dbc_proc_info`, `get_spell_proc`, `get_spell_proc_schema`, `search_spell_procs`, `diagnose_spell_proc`, `explain_proc_flags`, `compare_spell_dbc_vs_proc`, `list_proc_flag_types`, `search_spells_by_proc_flags`, `search_spells_by_family_mask`, `search_spells_by_attribute`, `search_spells_by_aura_type`, `get_dbc_stats`

### Conditions
`get_conditions`, `search_conditions`, `diagnose_conditions`, `explain_condition`, `list_condition_source_types`, `list_condition_types`

### Content templates / search
`search_creatures`, `get_creature_template`, `get_creature_with_scripts`, `search_gameobjects`, `get_gameobject_template`, `search_items`, `get_item_template`, `search_quests`, `get_quest_template`, `diagnose_quest`

### Waypoints
`get_creature_waypoints`, `get_waypoint_path`, `search_waypoint_paths`

### Wiki / source
`search_wiki`, `read_wiki_page`, `search_azerothcore_source`, `read_source_file`

### Meta / advanced
`search_tools`, `list_tool_categories`, `list_tools_in_category`, `execute_investigation`, `list_sandbox_functions`, `visualize_ghost_system`, `visualize_ghost_system_real`

---

## 2. `oldmanwarcraft-api-remote` (`user-oldmanwarcraft-api-remote`)

All tools are prefixed **`omw_`**. Use **`omw_discover_api`** or **`omw_health_check`** when exploring capabilities.

**Groups (representative tools):**

| Area | Examples |
|------|-----------|
| **Server** | `omw_get_server_status`, `omw_get_server_population`, `omw_get_world_boss`, `omw_list_world_bosses`, `omw_get_auction_summary` |
| **Armory** | `omw_search_armory_characters`, `omw_get_armory_character`, `omw_get_armory_character_equipment`, `omw_get_armory_guild`, `omw_search_armory_guilds`, `omw_get_armory_leaderboard` |
| **PvP / votes / RAF** | `omw_get_pvp_leaderboard`, `omw_get_pvp_player_stats`, `omw_claim_vote`, `omw_get_vote_leaderboard`, `omw_get_raf_leaderboard` |
| **Shop** | `omw_list_shop_items`, `omw_get_shop_catalog_item`, `omw_create_shop_item`, `omw_update_shop_order`, `omw_lookup_shop_wow_item`, import/export helpers |
| **Support / content** | `omw_list_support_tickets`, `omw_create_support_ticket`, `omw_list_kb_articles`, `omw_list_news`, `omw_create_bug_report`, `omw_list_server_feedback` |
| **Users / notifications** | `omw_list_users`, `omw_get_user`, `omw_list_notifications`, `omw_mark_notification_read` |
| **SOAP via API** | `omw_execute_soap_command` (policy: use only when aligned with production rules) |
| **Generic** | `omw_api_request`, `omw_get_settings` |

Destructive or customer-facing writes (shop, tickets, articles): confirm with the user and Notion/runbook policy first.

---

## 3. GitLab (`GitLab-MCP` in `mcp.json` — often `user-GitLab-MCP` descriptors)

Large surface: **merge requests** (`list_merge_requests`, `get_merge_request`, `get_merge_request_diffs`, `create_merge_request`, `merge_merge_request`, …), **issues** (`list_issues`, `get_issue`, `create_issue`, …), **pipelines** (`list_pipelines`, `get_pipeline`, `get_pipeline_job_output`, …), **repository** (`get_file_contents`, `create_or_update_file`, `list_commits`, `get_repository_tree`, …), **wiki** (`list_wiki_pages`, `get_wiki_page`, `create_wiki_page`, …), **releases**, **milestones**, **labels**, **draft notes**, etc.

Use for **GitLab origin** work; pair with **GitHub** (if configured) for upstream comparison.

---

## 4. Notion (`plugin-notion-workspace-notion`)

`notion-search`, `notion-fetch`, `notion-create-pages`, `notion-update-page`, `notion-duplicate-page`, `notion-move-pages`, `notion-create-database`, `notion-update-data-source`, `notion-create-view`, `notion-update-view`, `notion-create-comment`, `notion-get-comments`, `notion-get-users`, `notion-get-teams`

**Read-first** for ops truth; **writes** only when the user asked to update documentation.

---

## 5. `fetch` (`user-fetch`)

`fetch` — HTTP GET → markdown (or raw). Use for public URLs (wiki, docs, vendor pages).

---

## 6. `firecrawl-mcp` (`user-firecrawl-mcp`)

`firecrawl_scrape`, `firecrawl_crawl`, `firecrawl_map`, `firecrawl_search`, `firecrawl_extract`, `firecrawl_check_crawl_status`, `firecrawl_agent`, `firecrawl_agent_status`, `firecrawl_browser_*` (create, list, execute, delete)

Use when **fetch** is not enough (JS-heavy sites, site maps, batch crawl).

---

## 7. `deepwiki` / `exa` (remote MCP)

No local tool JSON in this repo path; tools appear in Cursor when connected. Use **deepwiki** for synthesized project/wiki-style answers and **exa** for web search–style retrieval—always cross-check against repo and `azerothcore` / `fetch`.

---

## 8. `sequential-thinking` (`user-sequential-thinking`)

`sequentialthinking` — multi-step reasoning (merges, incidents, complex debugging plans).

---

## 9. `cursor-ide-browser`

Browser automation: `browser_navigate`, `browser_snapshot`, `browser_tabs`, `browser_click`, `browser_type`, `browser_fill`, `browser_scroll`, `browser_take_screenshot`, `browser_network_requests`, `browser_console_messages`, `browser_lock` / `unlock`, profiling tools, etc.

Use for **web UIs** (OMW site, GitLab in browser, Grafana), not for worldserver binaries.

---

## 10. GitHub MCP (optional — Docker)

If enabled in `mcp.json`: issues, PRs, code search, file content—see GitHub MCP tool list in Cursor. Use for **upstream** AzerothCore / module repos.

---

## 11. Plugin GitLab auth (`plugin-gitlab-GitLab`)

`mcp_auth` — complete when the IDE prompts so GitLab tools are available.
