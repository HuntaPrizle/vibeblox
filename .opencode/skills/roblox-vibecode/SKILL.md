---
name: roblox-vibecode
description: Use when changing this Luau project through files, Rojo, or Studio MCP.
---

# Roblox workflow

Start with `roblox-session`. Follow `AGENTS.md` for architecture and strict
typing. Domain skills: `roblox-mcp`, `roblox-rojo`, `roblox-lune`,
`roblox-datastore`, `roblox-marketplace`, and `roblox-git`.

- Edit mapped scripts in `src/`; Rojo syncs file saves to the connected
  place. Preserve Studio edits using `docs/studio-ownership.md`.
- Run `lune run scripts/check.luau` or `/check` after changes. The runner
  owns the step list; the commit hook is only its fast subset.
- Verify gameplay with Studio assertions and logs. The optional example
  uses `lune run scripts/verify.luau --studio <id>` or `/verify`.
- Report passed/failed/unavailable from the current verification report.
  Static checks and mock MCP fixtures do not prove a live game works.
- Persistence settings and profile defaults are scaffolding, not a save
  implementation. Do not claim absent modules or systems are implemented.
