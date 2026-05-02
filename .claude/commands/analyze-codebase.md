---
allowed-tools: Bash(find:*), Bash(ls:*), Bash(wc:*), Bash(grep:*), Bash(head:*), Bash(cat:*), Bash(xargs:*), Bash(basename:*), Read, Glob, Write, Edit
description: Genereer of update .claude/codebase_analysis.md met overzicht van projectstructuur
---

# Codebase Analysis

Volg het skill contract in `skills/analyze-codebase.md`.

## Project Discovery

### Bestandsstructuur
!`find ./website -type f -not -path "*/node_modules/*" | sort`

### Bestandsaantallen

- HTML pagina's: !`find ./website -maxdepth 1 -name "*.html" | wc -l`
- CSS bestanden: !`find ./website/css -name "*.css" 2>/dev/null | wc -l`
- JS bestanden: !`find ./website/js -name "*.js" 2>/dev/null | wc -l`
- PHP bestanden: !`find ./website -name "*.php" | wc -l`
- Afbeeldingen: !`find ./website/assets -type f 2>/dev/null | wc -l`

### Pagina's
!`ls -1 website/*.html 2>/dev/null | xargs -I {} basename {}`

### Stylesheets
!`ls -1 website/css/*.css 2>/dev/null | xargs -I {} basename {}`

### CSS lengte
!`wc -l website/css/*.css 2>/dev/null`

### JS lengte
!`wc -l website/js/*.js 2>/dev/null`

### Color tokens
!`grep -E "^\s*--color-" website/css/style.css | head -20`

### Spacing tokens
!`grep -E "^\s*--space-" website/css/style.css | head -10`

### Docker config
!`cat docker-compose.yml 2>/dev/null | head -30`

### PHP backend
!`grep -l "PHPMailer\|honeypot\|rate_limit" website/*.php 2>/dev/null`

### Bestaande prompts
!`ls -1 .ai/prompts/*.md 2>/dev/null | xargs -I {} basename {}`

---

## Task

$ARGUMENTS
