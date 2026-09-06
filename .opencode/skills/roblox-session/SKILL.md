---
name: roblox-session
description: Use when starting Roblox work, verifying the toolchain, or diagnosing why Studio, MCP, or Rojo sync isn't responding. Startup checklist for the vibecode stack.
---

# Roblox Session Startup

Run these before any game work. Most "it doesn't work" reports are step 1.

1. **cwd is the repo root.** Project `opencode.json` (formatter, LSP,
   project MCP) only loads from the repo directory.
2. **MCP connected:** `opencode mcp list` shows `✓ Roblox_Studio connected`.
   The global `~/.config/opencode/opencode.jsonc` carries the same block so
   off-repo sessions still get it. If missing: check the bridge
   (`%LOCALAPPDATA%\Roblox\mcp.bat`, `StudioMCP.exe` alive), check Studio
   `Assistant → ⋯ → Manage MCP Servers` (green + client count), then
   restart opencode — config loads once at startup, never hot-reloads.
3. **Rojo serving:** a `rojo serve .` process exists and port `34872` is
   open (`TcpClient` to `127.0.0.1:34872`). If not, start it detached and
   tell the user to press Connect in the Studio Rojo plugin panel.
4. **Tools present:** `rokit install` once per fresh checkout
   (`rojo`, `lune`, `stylua`, `luau-lsp` pinned in `rokit.toml`).
5. **After any config-time change** (`opencode.json`, skills, agents):
   tell the user to quit and restart opencode.
