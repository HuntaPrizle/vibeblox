# VibeBlox - make a Roblox game with an AI agent

All the boring setup is done. Follow the steps once, then just tell your
AI agent what to build.

> New game? First point this clone at your own repo (`git remote remove
> origin`, then add yours - pushes go there, not back here). Replace every
> `MYGAME` with your game's name, fill in the "Game" section of `AGENTS.md`,
> set `DataStoreName` in `src/ReplicatedStorage/Config.luau` - then delete
> this box.

## Setup (once)

1. Install **Roblox Studio** and **Rokit**
   ([rokit](https://github.com/rojo-rbx/rokit)).
2. In your project folder, run:
   `rokit install`
   `git config core.hooksPath .githooks`
3. In Studio, install the **Rojo plugin**.
4. Point your AI agent at `HARNESS.md` in its first session - it sets
   itself up (Studio connection, skills, checks).

## Play

1. Run `rojo serve .`, leave it running.
2. In Studio: **Connect** -> **Play**. Saves appear live, in about a second.

`src/` holds your real files - Studio is just the preview. If you change
something directly in Studio, have the agent copy it back into `src/`.

## Stuck?

- Changes missing -> restart `rojo serve .`, press **Connect** again.
- Agent can't reach Studio -> Studio `Assistant -> ... -> Manage MCP
  Servers` should show green + a client count; then restart the agent.
- Commit blocked with red text -> ask the agent to run `/check`.
- Solo-test saving broken -> Studio Game Settings -> Security -> enable
  "Studio Access to API Services".

## Share

Studio: File -> Publish.

<details>
<summary>For developers: the quality gate</summary>

After `rokit install`, all five must pass after each change (same steps
run in CI; `/check` runs them in opencode):

```powershell
lune run tests/run.luau
rojo sourcemap default.project.json -o sourcemap.json
luau-lsp analyze --sourcemap sourcemap.json "--definitions:typedefs/globalTypes.PluginSecurity.d.luau" src/
stylua --check src/ tests/
rojo build -o game.rbxlx
```

</details>
