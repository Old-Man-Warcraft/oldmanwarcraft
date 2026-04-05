# Production log check

Tail and scan recent worldserver logs for errors. Use **Notion MCP** (`notion-search` / `notion-fetch`) if the log path is unclear. Optional: **azerothcore** `soap_check_connection` / `soap_server_info`, **oldmanwarcraft-api-remote** `omw_get_server_status` / `omw_health_check` for extra context.

Use the **actual log path** from Notion or this host (`env/dist/logs/Server.log`, `Errors.log`, or `/data/logs/` if mounted).

1. Show last 150 lines of `Server.log` and `Errors.log`.
2. `grep -iE 'error|critical|fatal|exception|segmentation'` on those files (last 500 matches or reasonable limit).
3. Summarize patterns and whether a restart or follow-up is suggested.

Do not restart services unless the user asks.
