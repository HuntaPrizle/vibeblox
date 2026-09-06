---
name: roblox-datastore
description: Use when changing saved player data, bumping the save version, debugging lost progress, or inspecting DataStore contents. Save conventions for this game.
---

# DataStore

- Store: `Config.DataStoreName` (e.g. `MYGAME_Save_v1`). Key: `Player_<UserId>`.
- Payload: flat `{ [string]: number }` plus `v = SaveVersion`. Numbers
  only, currency fields floored on write. Serde lives in the shared
  `SaveData` module (service-free, Lune-tested) — never inline new save
  fields in the server script.
- Flow: load on join (async, fresh profile shown first, validated swap-in),
  autosave every `Config.AutosaveSeconds`, save on leave, save-all on
  `BindToClose`. All store calls are `pcall` + retries; on total failure
  the game plays session-only with one warning, nothing breaks.
- **Persistence requires Studio `Game Settings → Security → Enable Studio
  Access to API Services`** for Play-Solo saves. If the client's `Saved`
  timestamp never appears, that toggle is the first suspect.
- Inspect live data with the free **DataDelve** or **DataScope** plugins
  (sleitnick's DataStore Editor is paid — don't recommend it as free).
- **Versioning:** changing the payload shape means bumping
  `Config.SaveVersion`. Old/wrong-version data is rejected and the player
  starts fresh — say so explicitly when proposing shape changes.
