# HARNESS.md - first-run agent configuration

Read `AGENTS.md` and load `.opencode/skills/*/SKILL.md` using your client's
native Agent Skills support. Project rules and executable commands are
shared; `opencode.json` is the reference client configuration.

## 1. Install and check the pinned environment

From the project root, run:

```text
rokit install
lune run scripts/doctor.luau
lune run scripts/check.luau
```

The runner is the single source of truth. It checks pure logic, workflow
behavior, formatting (including tests and scripts), types, and the place
build. For missing tools use `rokit install`, not separate versions.
Studio verification is a separate command.

## 2. Connect the built-in Studio MCP server

Open Assistant -> ... -> Manage MCP Servers and enable Studio as an MCP
server. Prefer Studio's Quick connect for supported clients. Follow the
current [Roblox MCP documentation](https://create.roblox.com/docs/studio/mcp);
the old standalone Rust server is not required.

OpenCode already launches `lune run scripts/studio-mcp.luau`. This portable
relay finds the installed Windows or macOS Studio launcher. Run the client
from the project root with Rokit shims on PATH. No global OpenCode config
is required. Verify with `opencode mcp list`.

For Claude Code, use a project `.mcp.json`:

```json
{
  "mcpServers": {
    "Roblox_Studio": {
      "type": "stdio",
      "command": "lune",
      "args": ["run", "scripts/studio-mcp.luau"]
    }
  }
}
```

For Cursor, use the same entry in `.cursor/mcp.json` (omit `type` if the
client doesn't use it). Other clients should register this stdio command
in their native configuration. If the server starts outside the repo, use
Studio's native launcher instead:

| Platform | Command | Arguments |
| --- | --- | --- |
| Windows | `cmd.exe` | `/c`, `%LOCALAPPDATA%\Roblox\mcp.bat` |
| macOS | `/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP` | none |

Client config shapes differ. Use Quick connect or the client's supported
configuration rather than assuming all clients accept Claude's JSON.
Report the adapter files you create. Keep changes project-scoped and
reload/restart the client after updating its MCP configuration.

## 3. Verify tools and select the intended place

Run `lune run scripts/doctor.luau --studio` to check the installed bridge.
Use `--tools` to save current schemas to ignored `studio-tools.json`.
This check is independent of your agent client's connection: also confirm
tools are exposed in the current agent session.

Call `list_roblox_studios`, choose the intended instance by name/place, and
pass its `studio_id` to subsequent calls. Never choose arbitrarily when
several are open. Inspect current schemas before calling tools. Common
tools include `get_studio_state`, `execute_luau` (Edit/Client/Server),
`start_stop_play`, and `get_console_output`; availability can change.

## 4. Native commands and gameplay verification

Mirror `.opencode/commands/check.md` into your client's native command
format. Its body calls the shared runner; do not duplicate its step list.
Mirror `verify.md` similarly if the client supports slash commands.

For the optional example, connect Rojo or open the freshly built place,
then run `lune run scripts/verify.luau --studio <id>`.
Read `docs/verification.md` for criteria, statuses, negative controls, and
cleanup. Unavailable verification is not a pass. Add game-specific
scenarios as the project grows.
