---
allowed-tools: Read, Edit, Glob, Grep
description: Optimaliseer een Claude skill — modes: interactive (default), auto, all
---

# Optimize Skill

Volg het skill contract in `skills/optimize-skill.md`.

## Task

$ARGUMENTS

Gebruik:
- `/optimize-skill <target>` — interactive mode (default): toon bevindingen, vraag per bevinding
- `/optimize-skill <target> auto` — pas alleen high-confidence fixes toe, sla scope-changing over
- `/optimize-skill <target> all` — pas alle bevindingen toe zonder vragen
