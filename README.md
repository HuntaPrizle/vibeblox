# MYGAME

One-line pitch for your game.

> New-game checklist: replace every `MYGAME` (`grep -r MYGAME --include='*.md' --include='*.luau' .`), fill in the Game section of `AGENTS.md`, set `Config.DataStoreName`, then delete this quote block.

## Stack

Rojo project (`default.project.json`) + Luau `--!strict`. Pinned CLI tools
in `rokit.toml` (rojo, lune, stylua, luau-lsp). Live Studio edits via the
Roblox Studio MCP (`opencode.json`); git `src/` stays source of truth.

## Setup

1. Install [Rokit](https://github.com/rojo-rbx/rokit), then:
   `rokit install`
2. Enable the local pre-commit gate (stylua + lune tests):
   `git config core.hooksPath .githooks`
3. Open the place in Roblox Studio with the Rojo plugin installed.
4. `rojo serve .` (port `34872`), then press **Connect** in the Rojo plugin
   panel. Every save syncs into the session in ~1s — just press Play.

## Dev loop

Edit `src/` -> syncs live -> Play in Studio -> check output.
Mirror anything worth keeping from the live place back into `src/`.

- Server: `src/ServerScriptService/*.server.luau`
- Shared (service-free, lune-testable): `src/ReplicatedStorage/*.luau`
- Client: `src/StarterPlayerScripts/*.client.luau`

## Quality gate

In opencode: `/check`. Manually (after `rokit install`):

```powershell
lune run tests/run.luau
rojo sourcemap default.project.json -o sourcemap.json
luau-lsp analyze --sourcemap sourcemap.json "--definitions:typedefs/globalTypes.PluginSecurity.d.luau" src/
stylua --check src/
rojo build -o game.rbxlx
```

All five must pass after each change. Same steps run in CI.

## Publish

File -> Publish in Studio, or Open Cloud
`universes/v1/$UNIVERSE/places/$PLACE/versions?versionType=Published`
with `universe-places:write`.
