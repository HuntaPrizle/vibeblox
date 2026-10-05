---
description: Verify the optional interaction example in a connected Studio session
agent: build
---

Run `lune run scripts/doctor.luau --studio` and identify the intended Studio instance.
Run `lune run scripts/verify.luau --studio <id>` from the project root.
Read `.vibeblox/verify.json`; report passed, failed, or unavailable accurately.
Do not claim gameplay works from static checks. See `docs/verification.md` for scope and cleanup.
