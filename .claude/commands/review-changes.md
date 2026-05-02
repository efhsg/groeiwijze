---
allowed-tools: Bash, Read, Grep, Glob
description: Structured review van wijzigingen — modes: autonomous (default), interactive
---

# Review Changes

Volg het skill contract in `skills/review-changes.md`.

## Context

- Git status: !`git status`
- Gewijzigde bestanden: !`git diff --stat`
- Recente commits: !`git log --oneline -5`

## Task

$ARGUMENTS

Gebruik:
- `/review-changes` — autonomous mode (default): auto-approve plan, Phase 1 sweep
- `/review-changes interactive` — interactive mode: goedkeuring plan, opt-in Phase 2
