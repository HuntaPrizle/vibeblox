---
description: Run full quality gate (tests, sourcemap, analyze, stylua, build)
agent: build
---

Run the full quality gate in order, stopping on first failure:

1. `rokit install`
2. `lune run tests/run.luau`
3. `rojo sourcemap default.project.json -o sourcemap.json`
4. `luau-lsp analyze --sourcemap sourcemap.json "--definitions:typedefs/globalTypes.PluginSecurity.d.luau" src/`
5. `stylua --check src/ tests/`
6. `rojo build -o game.rbxlx`

Report which step failed with its output. Do not skip steps.
