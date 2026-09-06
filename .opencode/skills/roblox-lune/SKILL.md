---
name: roblox-lune
description: Use when writing or running Lune tests, or when making shared Luau modules testable. Plain-data rule, tests/run.luau suite, and Lune gotchas.
---

# Lune

`lune run tests/run.luau` - assert-style checks over shared modules (pure
logic only). Zero framework: `check(name, cond)` prints
`ok:` lines and calls `error()` on failure, so a failing suite exits
non-zero. Keep that contract. Grow the count, never shrink it.

## Plain-data rule (load-bearing)

Shared modules under `src/ReplicatedStorage` must use **no Roblox engine
types or services** (`Color3`, `game`, ...). Store plain data (RGB triplets,
numbers, strings) and convert to engine types at the use site
(server/client). Rationale, verified the hard way:

- Lune has no Roblox globals, and its `require` **sandboxes globals per
  module** - a stub set in the test file is invisible inside the required
  module. There is no workaround; keep shared modules import-clean.
- Relative requires (`require("../src/ReplicatedStorage/Config")`) resolve
  by file path under Lune but would not in Studio - so shared modules must
  require **nothing**; pass dependencies (e.g. a `ConfigLike` table) as
  function arguments instead.

## Scope notes

- `tests/` is outside the Rojo tree: never syncs to Studio, never analyzed
  by `luau-lsp` (no DataModel context). Still format it with StyLua.
- When adding game tuning, add a Lune check first - the suite has already
  caught a wrong hand-computed expectation once.
