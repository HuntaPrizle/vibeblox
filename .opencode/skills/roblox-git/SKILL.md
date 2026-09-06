---
name: roblox-git
description: Use when committing, reviewing history, or connecting this repo to GitHub. Git conventions for the Roblox project.
---

# Git

- Before every commit inspect `git status`, `git diff --stat`, and
  `git log --oneline -3`. Stage only intended files (`git add -A` only on
  a clean, reviewed tree).
- Never commit secrets, `game.rbxlx`, or `sourcemap.json` (all ignored).
  `typedefs/` (697KB Roblox definitions) IS committed — the typecheck
  needs it on fresh checkouts.
- Message style: `feat:`, `fix:`, `test:`, `chore:` + imperative summary.
  Identity is repo-local (`hunta`); don't touch global git config.
- No push/PR flow yet — the repo has no remote. When the user wants
  GitHub: create the repo, add the remote, push `main`, then use `gh` for
  PRs. Don't commit, push, or open PRs unasked.
