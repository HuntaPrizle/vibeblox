# Studio ownership and recovery

Mapped files are the source of truth. Do not enable experimental reverse
syncing without reviewing support and conflict behavior for pinned Rojo.

| Content | Owner | Preserve it by |
| --- | --- | --- |
| Mapped scripts/shared config | Git files in `src/` | Applying edits to source and rerunning checks |
| Supported parts/models under mapped Workspace | Files after export | Saving XML `.rbxmx` models or supported properties in `.model.json` |
| Creator Store assets | Explicit declaration or saved place | Exporting the inspected model and recording asset ID/license provenance |
| Terrain, unsupported properties, place settings | Studio until deliberately exported/configured | Saving a place checkpoint and documenting release steps |
| Generated `game.rbxlx` | Build output | Rebuilding declared sources; it is not a backup of the live place |

Rojo cannot live-sync every property. Read its
[sync limitations](https://rojo.space/docs/v7/sync-details/) before moving
terrain, CSG, meshes, or settings into this workflow. A saved Studio asset
is not automatically included in a fresh build.

## Capture a Studio edit

1. Save a separate local place checkpoint before reconnecting Rojo or
   making a large change. Keep it outside the source tree; the repo ignores
   place files and binary models. Commit the source checkpoint too.
2. For a script, copy its source to the corresponding mapped file and
   review the Git diff. Do not leave the live script as its only copy.
3. For a supported model, select it and use Save to File to save XML
   `.rbxmx` under a declared directory, such as
   `src/Workspace/Props/Castle.rbxmx`. Remove unwanted scripts before Play.
   Record asset ID, origin, and usage rights.
4. Check names/mapping so the export replaces the intended object instead
   of duplicating it. Review the Rojo sync changes.
5. Run the full gate. Open a fresh build in a separate Studio instance and
   confirm the content survives without the original place.

XML models are built but not type-analyzed like loose `.luau` files. Keep
gameplay scripts as source files where possible. Verify exported builds
with unsupported properties separately; live-sync may not reproduce them.

## Recover from a bad sync

Stop `rojo serve` before further changes. Open the saved checkpoint in a
separate Studio instance. Review the Git diff/history and restore only
affected files, preserving unrelated edits. Export Studio-only work from
the checkpoint, rerun checks, and inspect the next sync. Avoid blanket
Git resets or overwriting the sole copy of a place.

Publishing the live place and a fresh Rojo build can produce different
content when Studio-owned assets remain. Choose the release artifact
deliberately and document remaining manual steps.
