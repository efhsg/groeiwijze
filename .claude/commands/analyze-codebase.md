---
allowed-tools: Bash(find:*), Bash(ls:*), Bash(wc:*), Bash(grep:*), Bash(head:*), Bash(cat:*), Bash(xargs:*), Bash(basename:*), Read, Glob
description: Genereer of update .claude/codebase_analysis.md met overzicht van projectstructuur
---

# Codebase Analysis

Genereer een verse `codebase_analysis.md` op basis van de huidige werkelijkheid van de website.

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

## Analysis Instructions

Genereer een nieuwe `codebase_analysis.md` met:

### 1. Project Overview
- Type: statische HTML/CSS/JS site met PHP contactformulier
- Doelgroep en toon
- Stack details uit het discovery-resultaat

### 2. Tech stack tabel
Met daadwerkelijke versies/packages waar zichtbaar.

### 3. Bestandsstructuur boom
Op basis van `find` output, gegroepeerd per directory.

### 4. Pagina-flow diagram
ASCII-diagram met alle gedetecteerde pagina's en hun verbindingen (navigatie).

### 5. Design system
- Lijst alle gevonden color tokens
- Lijst alle gevonden spacing tokens
- Breakpoints (uit CSS)
- Font families (uit CSS)

### 6. Contactformulier backend
- Anti-spam beschermingen die zichtbaar zijn in PHP
- Externe afhankelijkheden (PHPMailer, etc.)

### 7. Wat hier NIET is
- Database, framework, build system, etc.

Schrijf het resultaat naar `.claude/codebase_analysis.md` (overschrijft bestaande).

## Task

$ARGUMENTS
