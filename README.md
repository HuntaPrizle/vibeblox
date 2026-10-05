# VibeBlox - build a Roblox game with an AI agent

A small Luau + Rojo starter with pinned tools, agent instructions, shared
checks, and an optional Studio interaction smoke test. Your source lives
in Git; Studio previews and tests the game.

## Setup

1. Install Roblox Studio, Git, and [Rokit](https://github.com/rojo-rbx/rokit).
2. Clone this repo and run `rokit install` from its root.
3. Initialize a **new game** (skip this when contributing to VibeBlox):

   ```text
   lune run scripts/initialize.luau --name "My Game" --namespace MyGame --concept "Collect coins and unlock new areas"
   ```

   Use a unique persistence namespace. Add `--dry-run` to preview changes.
   Initialization sets the name, save namespace, concept, and Git hook.
   Repeating identical inputs preserves edits; different inputs are refused.
   Fill in the remaining game brief in `AGENTS.md`. Before pushing a new
   game, create its own repository and set `origin` to its URL; the script
   warns about the template remote but does not change it.

4. Run `lune run scripts/doctor.luau` and `lune run scripts/check.luau`.
5. Install the Rojo plugin in Studio. Point your agent at `HARNESS.md` to
   connect the built-in Studio MCP server and load the project skills.

The scripts use the pinned Lune runtime on Windows and macOS. Run commands
and your agent from the project root. CI checks both platforms; Studio is
a local, separate verification step.

## Develop

Run `rojo serve .`, then connect the Studio Rojo plugin to port `34872`.
File saves appear in the connected place. Press Play to try the game.

| Command | Purpose |
| --- | --- |
| `lune run scripts/check.luau` | Full gate: unit/workflow tests, formatting, types, place build |
| `lune run scripts/check.luau --fast` | Commit-hook subset: tests and formatting |
| `lune run scripts/doctor.luau --studio` | Check tools and discover connected Studio instances |
| `lune run scripts/doctor.luau --tools` | Also save the current MCP tool schemas |
| `lune run scripts/verify.luau --studio <id>` | Verify the optional example in the selected Studio instance |

CI and `/check` call the full runner. The hook calls its fast subset.
Generated place files, sourcemaps, schemas, and verification reports are
ignored. `.vibeblox/project.json` records initialization and belongs in Git.

## What's included

- Strict server/client entry points, shared configuration, profile defaults,
  and pure helper tests.
- An **optional, session-only** coin example: server validation, duplicate
  rejection, replicated balance, and a simple HUD. Set
  `Config.SmokeExampleEnabled = true` to try it manually. Verification
  enables it temporarily without changing source files.
- Agent guidance for Rojo, Studio MCP, tests, Git, assets, and persistence.

Persistence settings exist, but loading/saving data, purchases, and a full
game loop are **not implemented**. Static checks do not verify multiplayer,
mobile behavior, or persistence. See [verification scope](docs/verification.md).

## Preserve Studio changes

Read [Studio ownership and recovery](docs/studio-ownership.md) before
editing mapped objects or importing assets. Export supported changes back
to files; terrain and some properties need separate preservation. A clean
Rojo build contains only what the project declares.

## Troubleshooting

- Missing/wrong tools: run `rokit install`, then `scripts/doctor.luau`.
- Missing changes: confirm the Rojo process and plugin connection; inspect
  the proposed sync before applying it to a place with manual changes.
- MCP unavailable: enable it in Studio, check the launcher path, restart
  your client, and run the doctor with `--studio`.
- Commit blocked: run the full gate and fix the named failing step.
- Verification failed: read `.vibeblox/verify.json`. A missing session or
  unsupported tool schema is unavailable and exits nonzero.
- When you implement persistence, enable Studio API access for tests that
  access DataStores. The example makes no cloud calls.

Publish from Studio: File -> Publish. Verify game-specific scenarios and
preserve Studio-owned assets before publishing a generated build.
