---
name: roblox-rojo
description: Use for file-to-Studio sync, mapping, builds, and preserving Studio changes.
---

# Rojo

`default.project.json` maps server, shared, client, and Workspace files in
`src/`. Live-sync: `rojo serve .`, then connect the Studio plugin to port
`34872`. Keep one server per project; confirm the plugin targets it.

Files are the default source of truth. Studio edits are not automatically
preserved in Git. Follow `docs/studio-ownership.md` for script capture,
XML model export, checkpoints, and recovery. Do not assume every live-place
edit is overwritten or included in a fresh build: ownership depends on
the mapping and supported properties.

The pinned Rojo version's reverse-sync features are not enabled by this
template. Do not switch sync strategies silently.

Build with `rojo build -o game.rbxlx`; sourcemaps feed the typechecker.
Both outputs are ignored. The canonical runner performs these steps.
A generated build contains only declared source; save Studio-owned
terrain/assets/settings separately and document release steps.
