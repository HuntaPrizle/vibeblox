---
name: roblox-mcp
description: Use when inspecting Studio, debugging Play sessions, or diagnosing the built-in MCP connection.
---

# Roblox Studio MCP

Project configuration uses the portable `scripts/studio-mcp.luau` relay.
No global OpenCode configuration is required. See `HARNESS.md` for native
client adapters and Windows/macOS launchers.

1. Discover tools and inspect their input schemas in the current session.
2. Call `list_roblox_studios`, select the intended instance, and pass its
   `studio_id` to all subsequent calls.
3. Use `get_studio_state` to select an available Edit/Client/Server
   datamodel. Common tools: `execute_luau`, `start_stop_play`,
   `get_console_output`, `search_game_tree`, and `inspect_instance`.
4. Use the doctor with `--studio` to independently check the bridge, or
   `--tools` to save current schemas. A working CLI connection does not
   guarantee the agent client's MCP config loaded.

Live-place edits are not automatically written back to project files.
Preserve them using `docs/studio-ownership.md`. Mapped changes may be
overwritten; unmapped changes may be absent from a fresh build.
For a cloud-only feature, first check the current tools/API documentation;
if unsupported, explain the limitation and keep notes in chat or source.

Run the example verifier only on the intended idle place. Unavailable
verification is never a pass. See `docs/verification.md`.
