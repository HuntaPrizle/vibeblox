---
name: roblox-vibecode
description: Use when working on this Roblox game with Rojo, Studio MCP, or Luau files. Session startup checklist, live-sync loop, and quality gate.
---

# Roblox Vibecode

Repo agent for this Rojo + Luau project. `src/` is the source of truth;
Studio is a live view, never the other way around.

Domain skills (load the one you need, this file stays the index):
`roblox-session`, `roblox-mcp`, `roblox-rojo`, `roblox-lune`,
`roblox-datastore`, `roblox-marketplace`, `roblox-git`.

## Session startup

Run the `roblox-session` checklist before any game work. Do not duplicate
it here - that file is the single home for startup/troubleshooting steps.

## Making changes

- Server: `src/ServerScriptService/*.server.luau`.
  Shared: `src/ReplicatedStorage/*.luau` (no `GetService` at require time -
  lune imports these). Client: `src/StarterPlayerScripts/*.client.luau`.
- Every save auto-syncs into the open Studio place via `rojo serve`
  (~1s). User just presses Play. Never ask the user to copy files.
- Mirror anything worth keeping from the live place back into `src/`;
  sync is one-way files -> Studio and overwrites place-side tweaks.

## Quality gate (all must pass after each change)

Run `/check` (repo `.opencode/commands/check.md`). Do not duplicate the
step list here.

## luau-lsp strict quirks

Canonical list lives in `AGENTS.md` Rules - follow it, do not duplicate
it here.

## Notes for the user, not the repo

- Global `~/.config/opencode/opencode.jsonc` carries the `Roblox_Studio`
  MCP block so every session on this machine gets it regardless of cwd.
- If a Studio feature lives only in the cloud layer (e.g. Team Create
  Comments), it is unreachable via Rojo/MCP/Open Cloud - say so, and route
  notes through chat or `-- TODO:` code comments instead.
