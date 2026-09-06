---
name: roblox-rojo
description: Use when syncing code to Studio, when edits don't appear in the open place, or when building game.rbxlx. Rojo live-sync, builds, and the one-way sync rule.
---

# Rojo

Project file `default.project.json` maps `src/ServerScriptService`,
`src/ReplicatedStorage`, `src/StarterPlayerScripts`, `src/Workspace`
(`servePort 34872`).

## Live-sync (the normal loop)

- `rojo serve .` runs detached on the dev machine; every save lands in the
  open Studio place within ~1s. The user only presses Play.
- One-time per Studio install: install the Rojo plugin (rojo-rbx) and press
  Connect (defaults to `localhost:34872`).
- If edits stop appearing: check the serve process, check the port, check
  the plugin still shows connected. Restart the server with
  `rojo serve .` — never ask the user to copy files.

## One-way rule

Sync flows files → Studio. Place-side tweaks get overwritten on the next
sync. If the user changed something directly in Studio worth keeping, port
it into `src/` immediately and say so.

## Artifacts

- `rojo build -o game.rbxlx` — snapshot artifact for opening/publishing.
- `rojo sourcemap default.project.json -o sourcemap.json` — feeds the
  typechecker. Both are gitignored build outputs, never commit them.
