# VibeBlox — make a Roblox game with an AI helper

VibeBlox is a starter project with all the boring setup already done
(tools, checks, the Studio connection). You describe the game, your AI
helper builds it with you. You don't need to be a programmer — just follow
the steps below in order. Lines that look like `this` are commands to
copy-paste into a terminal opened in your project folder.

> Starting a new game? Search the whole project for `MYGAME` and replace
> it with your game's name, fill in the "Game" section of `AGENTS.md`
> (that file teaches your AI helper what you're making), set
> `DataStoreName` in `src/ReplicatedStorage/Config.luau` to something
> unique like `"YourGameName_Save_v1"` — then delete this box.

## Set up your computer (once ever)

1. Install **Roblox Studio** (free).
2. Install **Rokit** (free, from
   [rokit](https://github.com/rojo-rbx/rokit)), open a terminal in your
   project folder, and run:
   `rokit install`
   This installs the exact tool versions the project needs. Nothing else
   to pick or configure.
3. In Studio, install the **Rojo plugin**.
4. Recommended: run `git config core.hooksPath .githooks` once. This turns
   on automatic quick checks before each save-point (commit).
5. If you use an AI helper (opencode, Claude Code, Cursor, …): point it at
   `HARNESS.md` in its first session and it will set itself up
   (Studio connection, skills, checks).

## Everyday use

1. In your project folder, run `rojo serve .` and leave it running.
2. Open the project in Studio, press **Connect** in the Rojo plugin panel,
   then press **Play**.
3. Tell your AI helper what to build. It edits files, Studio updates live
   within about a second.

One rule: your real game files live in the `src/` folder. Don't edit
copies of them inside Studio — Studio is just a live preview, `src/` is
the real thing. If you change something directly in Studio that you want
to keep, tell your helper to copy it back into `src/`.

## If something breaks

- **My changes don't show up in Studio** → Is `rojo serve .` still
  running? Does the plugin still say connected? If not, start the server
  again and press **Connect**.
- **The AI helper can't reach Studio** → In Studio, open
  `Assistant → ⋯ → Manage MCP Servers` and look for a green light plus a
  client count. Then restart the helper (it only reads its settings once,
  at startup). Details: `HARNESS.md`.
- **A save-point (commit) was blocked with red text** → That's the
  automatic check doing its job. Ask your helper to run `/check` and fix
  what it reports.
- **Saving doesn't work while testing alone** → In Studio: Game Settings
  → Security → turn on "Enable Studio Access to API Services".

## Sharing your game

In Studio: File → Publish. That's it.

<details>
<summary>For developers: the quality gate</summary>

After `rokit install`, all five must pass after each change (same steps
run in CI; `/check` runs them in opencode):

```powershell
lune run tests/run.luau
rojo sourcemap default.project.json -o sourcemap.json
luau-lsp analyze --sourcemap sourcemap.json "--definitions:typedefs/globalTypes.PluginSecurity.d.luau" src/
stylua --check src/
rojo build -o game.rbxlx
```

</details>
