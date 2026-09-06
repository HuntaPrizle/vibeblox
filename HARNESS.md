# HARNESS.md - first-run self-configuration

If you are an AI coding harness opening this repo for the first time, use
this file to configure yourself from the repo's universal sources. The
repo is harness-agnostic; `opencode.json` is just the reference
implementation. Create your native equivalents, verify, report.

## 0. Read first (all harnesses)

- `AGENTS.md` - project rules, quality gate, commands. Obey it.
- `.opencode/skills/*/SKILL.md` - standard Agent Skills format (`name` +
  `description` frontmatter). Load them as skills natively; do not convert.

## 1. Wire the Studio MCP bridge

Source of truth: `opencode.json` -> `mcp.Roblox_Studio`. The bridge is a
stdio server; only the wrapper differs per harness.

**opencode** - native, already committed. Verify: `opencode mcp list`.

**Claude Code** - create `.mcp.json` at repo root (project scope, commit
it so the team shares it):

```json
{
  "mcpServers": {
    "Roblox_Studio": {
      "type": "stdio",
      "command": "cmd.exe",
      "args": ["/c", "${LOCALAPPDATA}\\Roblox\\mcp.bat"]
    }
  }
}
```

(`type: stdio` is required by Claude Code; `${VAR}` expands at
connection time.) Verify: `claude mcp list`.

**Cursor / Claude Desktop / others** - same entry in the standard
`mcpServers` shape (`command` + `args`, no `type` needed):

```json
{
  "mcpServers": {
    "Roblox_Studio": {
      "command": "cmd.exe",
      "args": ["/c", "%LOCALAPPDATA%\\Roblox\\mcp.bat"]
    }
  }
}
```

(`cmd.exe` expands `%VAR%` itself.) Then follow your harness's normal
restart/reload step - MCP configs load once at startup, never hot-reload.

## 2. Create the `/check` command

Source of truth: `.opencode/commands/check.md`. Mirror its body into your
harness's native command file (e.g. Claude Code:
`.claude/commands/check.md` with the same `description` frontmatter).
Keep the step list identical - one gate, every harness.

## 3. Verify the environment

```powershell
rokit install
lune run tests/run.luau
rojo sourcemap default.project.json -o sourcemap.json
luau-lsp analyze --sourcemap sourcemap.json "--definitions:typedefs/globalTypes.PluginSecurity.d.luau" src/
stylua --check src/
rojo build -o game.rbxlx
```

All five must pass. If a tool is missing, `rokit install` is the fix -
never install the tools by other means (versions are pinned in
`rokit.toml`).

## 4. Report, don't commit harness files silently

Tell the user which native files you created (e.g. `.mcp.json`,
`.claude/commands/`). Commit project-scope files only when asked.
Formatting/LSP for editors is already universal via
`.vscode/settings.json` - do not duplicate it per harness.
