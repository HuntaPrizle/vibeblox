---
name: roblox-session
description: Use when starting project work or diagnosing tools, Studio MCP, and Rojo.
---

# Session startup

1. Work from the repo root so project settings and Rokit pins are used.
2. Run `rokit install` on a fresh clone, then
   `lune run scripts/doctor.luau`.
3. Follow `HARNESS.md` for your client's MCP setup. Restart/reload after
   configuration changes. Global client settings are optional.
4. Confirm Studio has MCP enabled. Discover tools, list Studio instances,
   and select the intended `studio_id`. Use doctor `--studio` if diagnosis
   is needed; never report a connection verified from config files alone.
5. Start `rojo serve .` and connect the Rojo plugin to port `34872`.
   Inspect pending changes before applying them to a manually edited place.
6. Run the shared full check after changes and appropriate Studio scenarios
   for gameplay. See `docs/verification.md` for the optional example.

If starting a detached process on Windows, hide its window and report how
to stop it. Do not start duplicate Rojo servers or target a different place.
