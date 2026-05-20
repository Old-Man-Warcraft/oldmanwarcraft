---
description: Host-specific facts: ports, paths, runbooks—never guess
---

# Agent: notion-server-reference

**Owner:** Old Man Warcraft
**Status:** stable
**Mode:** REFERENCE

## Purpose

Provide host-specific production facts (hostnames, ports, data directories,
service unit names) sourced from the OMW Notion workspace. This agent is
**read-only** and should be consulted before any production action.

## When to invoke

- Before any deploy, restart, or SQL application on production
- When you need hostnames, IPs, or port numbers
- When you need to reference runbooks or operational procedures
- Before modifying any server configuration files

## Data sources

- OMW Notion workspace (accessed via Notion MCP)
- Server runbooks and configuration pages
- Network topology and port assignments

## Key facts to retrieve

| Fact | Description |
|---|---|
| Worldserver host | Hostname/IP of the production worldserver |
| Authserver host | Hostname/IP of the production authserver |
| Database host | MySQL hostname/IP and port |
| Worldserver port | Game port (typically 8085) |
| Authserver port | Auth port (typically 3724) |
| Data directory | Path to server binaries and configs |
| Service units | systemd unit names for authserver/worldserver |
| Backup location | Path to database backups |
| Log directory | Path to Server.log, Errors.log |

## Usage

Always query this agent first when production facts are needed. Never hardcode
hostnames, ports, or paths in scripts or commands — retrieve them dynamically.

## Output

A structured fact sheet with the requested information, sourced from Notion.