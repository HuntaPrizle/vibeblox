---
name: roblox-mcp
description: Use when inspecting the live Studio place, debugging Play sessions, or troubleshooting the Roblox Studio MCP connection. What MCP reaches and its hard limits.
---

# Roblox Studio MCP

Stdio bridge: opencode spawns
`cmd.exe /c "%LOCALAPPDATA%\Roblox\mcp.bat"`, which talks to
`StudioMCP.exe`, which talks to Studio. Defined in the repo `opencode.json`
and mirrored in the global `~/.config/opencode/opencode.jsonc`.

## What it reaches

Game tree, script contents, Play-mode console output, running Luau in play
mode. Use it to inspect the live session and diagnose without asking the
user to paste logs.

## Hard limits (do not work around, explain them)

- **Cloud-only Studio features are unreachable.** Team Create Comments,
  for example, live in Roblox's collaboration layer — not in the place
  file, not in MCP, not in Open Cloud. Route those notes through chat or
  `-- TODO:` code comments instead.
- MCP edits the **live place only** and are ephemeral. Mirror anything
  worth keeping back into `src/` or the next Rojo sync overwrites it.
- If the session has no `Roblox_Studio_*` tools at all, the MCP config
  isn't loaded here — see `roblox-session`. Verify from outside with
  `opencode mcp list` plus the Studio panel's client count.
