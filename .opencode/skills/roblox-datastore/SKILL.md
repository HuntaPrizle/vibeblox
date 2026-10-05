---
name: roblox-datastore
description: Use when implementing or changing persistence, save migrations, or debugging lost progress.
---

# Persistence

This starter currently implements profile defaults and settings only.
There is no SaveData module, load/autosave lifecycle, or persistence test.

When adding persistence:

- Use `Config.DataStoreName` and versioned payloads. Give each game a unique
  namespace with initialization; don't share the template namespace.
- Separate pure validation/serialization from service calls and Lune-test
  it. Validate loaded data before changing the active profile.
- Define migrations explicitly. Do not silently reject old data and reset
  progress when bumping a version.
- Handle load/save failures, retries, leave, and shutdown. Never overwrite
  existing data with defaults after a failed load. Use concurrency/session
  protection appropriate to the game's needs.
- Studio tests accessing DataStores require Studio API access. Use separate
  test stores and explicitly document cloud mutations.
- Add Studio scenarios for persistence; the starter smoke test checks only
  a session-only reward and HUD, with no cloud access.

Describe remaining work accurately; do not present these recommendations
as already implemented behavior.
