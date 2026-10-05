---
description: Run full quality gate (tests, sourcemap, analyze, stylua, build)
agent: build
---

Run `lune run scripts/check.luau` from the project root.
If pinned tools are missing, run `rokit install`, then retry.
Report the failing step and output. Never substitute the fast hook for the full gate.
