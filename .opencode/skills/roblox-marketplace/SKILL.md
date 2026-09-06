---
name: roblox-marketplace
description: Use when finding, choosing, or inserting Roblox marketplace assets (models, meshes, decals/images, audio, video, packages, animations). Search Creator Store and inventories via Studio MCP.
---

# Roblox Marketplace

You can browse and insert marketplace content via the `Roblox_Studio` MCP
tools. No web scraping — use `search_asset` to find, `insert_asset` to place.

Tools (names vary slightly by client — `Roblox_Studio_search_asset` /
`search_asset`, `Roblox_Studio_insert_asset` / `insert_asset`):

- `search_asset`: keyword search across Creator Store + inventories.
- `insert_asset`: insert by numeric `assetId` into the open Studio place.

## Workflow

1. Clarify: what object, what type, where it goes, free-only or paid OK.
2. Search narrow first, then widen:
    - `query: "castle tower"`, `assetType: "Model"`, `scope: "auto"`,
     `maxResults: 5`
   - Exact phrase: `query: "\"gingerbread house\""`
   - Multi-term: `query: "red+car"`
3. Present top 3-5 hits with name, `assetId`, type, source/price, and
   `thumbnailUrl` preview. Never auto-insert paid or cross-owner assets —
   ask first.
4. Insert with explicit name and parent:
    - `assetId: 12345678`, `assetName: "CastleTower"`,
     `assetType: "Model"`, `parentPath: "game.Workspace.Props"`
   - Omit `parentPath` only to drop into `Workspace` root.
5. Verify: `GameTree(path: "Workspace.Props")` or `InspectInstance`,
   plus `screen_capture` if placement/scale matters.
6. Persist: MCP inserts hit the **live place only**. Mirror anything worth
   keeping — record the `assetId` + `parentPath` in `src/` (e.g. a shared
   config or server script that inserts/loads it) or the next Rojo sync
   overwrites it. See `roblox-rojo`, `roblox-mcp`.

## Search scopes

- `auto` (default): universe inventory → owning group → user → Store.
- `creator_store`: public marketplace only. Required for `priceFilter`,
  `minPriceCents`/`maxPriceCents`, `tags`, `facets`,
  `verifiedCreatorsOnly`.
- `user` / `universe`: personal / place inventories.
- `group`: owning group by default; pass `groupId` or `groupName` for a
  specific group. Never combine `groupId`/`groupName` with `scope: "auto"`.

## Asset types

Pass `assetType` explicitly — inventory defaults to `Model`:

- `Model` — props, buildings, procedural sets (default).
- `Mesh`, `MeshPart` — single meshes.
- `Image` — user-uploaded images (most modern "decals" live here, not
  `Decal`). Use `Image` when the user says decal/texture/sprite.
- `Decal`, `Video`, `Audio`, `Animation`, `Package` — filter literally.
  `Package` finds packages (don't keyword-search "package").

Audio: `audioMinDuration` / `audioMaxDuration` (seconds).
Store-only refinements: `priceFilter: "free|paid|all"`,
`verifiedCreatorsOnly: true`, `tags: ["Vehicle"]`,
`facets: ["animated", "realistic"]`.

## Rules

- Inventory hits (`source: "inventory"`) are always insertable. Store hits
  can be restricted — on insert failure, try the next result.
- Cross-owner caution: if result `creatorId` differs from response
  `context.creatorId`, name the source (`creatorName`) and destination
  before calling `insert_asset` and get explicit consent.
- Paid assets: always confirm price in Robux first.
- Thumbnails: each result has `thumbnailUrl` (Thumbnails API JSON with
  `data[0].imageUrl`). Fetch it to visually compare before inserting.
- Keep inserts minimal: one candidate at a time, sensible `parentPath`
  (`Workspace`, `ReplicatedStorage`, `StarterGui`), then anchor/scale in
  the live place before mirroring back to `src/`.
- Game fit: prefer low-part-count models, no scripts inside
  unknown models — inspect children after insert and delete stray
  `Script`/`LocalScript` before Play.
