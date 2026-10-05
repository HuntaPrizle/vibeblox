# Studio verification

`lune run scripts/check.luau` verifies pure logic, workflow tests, formatting,
types, and a place build. `lune run scripts/verify.luau` is a separate live
check using Roblox's built-in stdio MCP server. It does not need a
third-party MCP plugin.

## Run the smoke test

1. Run the full gate. Open `game.rbxlx` in Studio, or connect Rojo to a place
   containing the project's current files.
2. Enable Studio MCP and run `lune run scripts/doctor.luau --studio`.
3. Select the intended instance and run:

   ```text
   lune run scripts/verify.luau --studio <id>
   ```

   The ID is optional only when exactly one instance is connected. Existing
   playtests are refused. Six starter scripts/modules must match disk
   before the verifier modifies the selected place.

4. Read `.vibeblox/verify.json`: discovery, source checks, assertion results,
   baseline/current logs, and cleanup errors.

## Acceptance criteria

- The server starts with a fresh session balance of zero.
- The example client initializes its HUD and remote interaction.
- A valid coin ID sent from outside the permitted range awards nothing.
- Malformed and unknown requests award nothing.
- An in-range request awards exactly one coin on the server.
- The client receives that balance and the HUD displays it.
- Repeating the request does not award another coin.
- No new error-level entries are found in collected runtime logs.

The test drives the remote from the client directly. It does not verify
button input, touch layout, multiplayer, respawn, network abuse resistance,
or persistence. The example balance is session-only. Add separate
scenarios before making corresponding claims.

Unknown required arguments, state/discovery formats, or assertion result
envelopes fail closed. If Studio changes them, inspect `doctor --tools`
and update the adapter and fixtures instead of guessing success.

## Reports and negative control

| Status | Meaning |
| --- | --- |
| `passed` | Assertions completed, logs collected, cleanup succeeded |
| `failed` | A started test, log collection, or cleanup failed |
| `unavailable` | No suitable connection, idle place, source match, or supported tool contract |

Only `passed` exits zero. Lune 0.10.5 maps nonzero script exits to CLI exit 1;
use report `status` to distinguish failure from unavailability. Each
invocation overwrites the report; do not reuse an older passing report.

Run `lune run scripts/verify.luau --studio <id> --negative-control` to send
an incorrect client request during the claim phase. The balance assertion
must fail, exit nonzero, and still clean up. This tests detection of a
broken interaction without rewriting game scripts. Automated transport
and orchestration fixtures also test failures without Studio; they do not
replace a live run.

## Cleanup and recovery

Verification temporarily sets `Workspace.VibeBloxVerify` in Edit mode,
starts Play, anchors/teleports the test character, and sends requests.
Runtime objects disappear when Play stops. It attempts to stop Play and
remove the Edit flag on success and failure. It does not rewrite scripts,
upload assets, or use DataStores.

If forcibly terminated or disconnected during cleanup, stop Play and
remove the `VibeBloxVerify` attribute from Workspace before saving or
publishing. A pre-existing flag is refused. Keep a local place checkpoint
before first trying verification on an existing place and avoid concurrent
Studio edits during a run.
