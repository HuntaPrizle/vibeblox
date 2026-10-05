# MYGAME - agent rules

## Stack
Rojo project (`default.project.json`) + Luau strict. Studio MCP `Roblox_Studio` can be connected for live place inspection and verification; confirm it each session.

## Game (fill in per project)
- Concept: one line - what the player does
- Genre / reference: what existing game this feels like
- Core loop: action -> reward -> upgrade -> bigger action
- Pillars (3 max): ...
- NOT doing (v1): ...

## Rules
- Luau `--!strict` everywhere. `GetService()` lazily inside functions, never at require time for testable modules.
- Server rules in `src/ServerScriptService/*.server.luau`, shared config in `src/ReplicatedStorage/*.luau`, client in `src/StarterPlayerScripts/*.client.luau`.
- After each change run `lune run scripts/check.luau`. This is the canonical full gate used by CI; tools are pinned in `rokit.toml` (`rokit install`). The hook runs its fast subset.
- Never hallucinate APIs. No `CFrame.fromComponents`.
- luau-lsp strict quirks: `require` must be top-level static (`local m = Service:WaitForChild("X"); local M = require(m)`) so the analyzer resolves it; never index `{ [Union]: T }` tables with literals (use arrays + lookup fn); never compare `.Parent` to nil directly (use an `any`-hop helper); narrowing only sticks on never-reassigned locals - re-lookup into a fresh local + `assert(x ~= nil)` instead of refining a reassigned one; `pcall(f)` where `f` returns nothing yields only a boolean (don't destructure two values); forward-declare locals used before definition (`local f: (Player) -> ()`, then `function f(...)`).
- Preserve Studio changes according to `docs/studio-ownership.md` before syncing or rebuilding.
- Discover current MCP tools and their schemas. Call `list_roblox_studios`, select the intended instance, and pass its `studio_id` to subsequent calls. Use `start_stop_play`, `execute_luau` with an explicit datamodel, and `get_console_output`; do not assume legacy tools exist.
- Test loop: edit -> full gate -> `lune run scripts/verify.luau --studio <id>` for the optional example, or game-specific Studio scenarios -> fix. Unavailable verification is not a pass.
- The starter has persistence settings and profile defaults, not a save implementation. See `docs/verification.md` for what the example actually tests.

## Commands
- Initialize a new game: `lune run scripts/initialize.luau --name "My Game" --namespace MyGame --concept "What the player does"`.
- Diagnose tools: `lune run scripts/doctor.luau`; add `--studio` for a live connection check or `--tools` to save current schemas.
- Check: `lune run scripts/check.luau`; fast subset: add `--fast`.
- Build: `rojo build -o game.rbxlx`
- Live-sync (preferred - pushes every save into the open Studio place): `rojo serve .` (port `34872`), then in Studio press Connect in the Rojo plugin panel. Keep it running; every edit lands in the session within ~1s, user just presses Play.
- Publish: Open Cloud `universes/v1/$UNIVERSE/places/$PLACE/versions?versionType=Published` with `universe-places:write`, or File -> Publish in Studio.
