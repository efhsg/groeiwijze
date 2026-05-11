---
allowed-tools: Bash(find:*), Bash(ls:*), Bash(cat:*), Bash(grep:*), Bash(rg:*), Read, Grep, Glob
description: Audit alle Claude-configuratiebestanden op volledigheid, correctheid en consistentie
label: Config auditen
---

# Configuration Audit

Volg het skill contract in `skills/audit-config.md`.

Audit alle Claude Code configuratiebestanden voor dit project.

## Bestanden om te auditen

### Hoofdconfiguratie
@CLAUDE.md

### Project Config
@.claude/config/project.md

### Rules
@.claude/rules/colors.md
@.claude/rules/html-css.md
@.claude/rules/content.md
@.claude/rules/accessibility.md
@.claude/rules/security.md
@.claude/rules/skill-routing.md
@.claude/rules/workflow.md
@.claude/rules/response-format.md
@.claude/rules/writing-standards.md

### Skills Index
@.claude/skills/index.md

### Andere AI-configuraties
@AGENTS.md
@GEMINI.md
@RULES.md
@.claude/settings.json
@.claude/settings.local.json

## Commands lijst
!`ls -1 .claude/commands/*.md 2>/dev/null | xargs -I {} basename {}`

## Skills lijst
!`find .claude/skills -type f -name "*.md" 2>/dev/null | sort`

## Pagina's
!`ls -1 website/*.html 2>/dev/null | xargs -I {} basename {}`

## Task

$ARGUMENTS
