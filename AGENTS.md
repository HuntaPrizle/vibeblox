# MYGAME - opencode rules

## Stack
Rojo project (`default.project.json`) + Luau strict. Studio MCP `Roblox_Studio` is connected for live place edits.

## Game (fill in per project)
- Concept: one line - what the player does
- Genre / reference: what existing game this feels like
- Core loop: action -> reward -> upgrade -> bigger action
- Pillars (3 max): ...
- NOT doing (v1): ...

## Rules
- Luau `--!strict` everywhere. `GetService()` lazily inside functions, never at require time for testable modules.
- Server rules in `src/ServerScriptService/*.server.luau`, shared config in `src/ReplicatedStorage/*.luau`, client in `src/StarterPlayerScripts/*.client.luau`.
- After each change all of these must pass (tools pinned in `rokit.toml`, run `rokit install` first):
  - `lune run tests/run.luau`
  - `rojo sourcemap default.project.json -o sourcemap.json`
  - `luau-lsp analyze --sourcemap sourcemap.json "--definitions:typedefs/globalTypes.PluginSecurity.d.luau" src/` (quote the `--definitions:...` arg in PowerShell)
  - `stylua --check src/`
  - `rojo build -o game.rbxlx` must succeed.
- Never hallucinate APIs. No `CFrame.fromComponents`.
- luau-lsp strict quirks: `require` must be top-level static (`local m = Service:WaitForChild("X"); local M = require(m)`) so the analyzer resolves it; never index `{ [Union]: T }` tables with literals (use arrays + lookup fn); never compare `.Parent` to nil directly (use an `any`-hop helper); narrowing only sticks on never-reassigned locals - re-lookup into a fresh local + `assert(x ~= nil)` instead of refining a reassigned one; `pcall(f)` where `f` returns nothing yields only a boolean (don't destructure two values); forward-declare locals used before definition (`local f: (Player) -> ()`, then `function f(...)`).
- MCP edits live place only - mirror anything worth keeping back into `src/` so git stays source of truth.
- Test loop: edit -> MCP `run_script_in_play_mode` or Studio Play -> `get_console_output` -> fix.

## Commands
- Build: `rojo build -o game.rbxlx`
- Live-sync (preferred - pushes every save into the open Studio place): `rojo serve .` (port `34872`), then in Studio press Connect in the Rojo plugin panel. Keep it running; every edit lands in the session within ~1s, user just presses Play.
- Publish: Open Cloud `universes/v1/$UNIVERSE/places/$PLACE/versions?versionType=Published` with `universe-places:write`, or File -> Publish in Studio.
