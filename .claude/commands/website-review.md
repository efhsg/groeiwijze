---
allowed-tools: Read, Bash, Grep, Glob
description: Uitgebreide UI/UX en toegankelijkheidsreview van de website vanuit healthcare-perspectief
---

# Website Review

Volg het skill contract in `skills/website-review.md`.

Volg de review-instructies in `.ai/prompts/website-review-agent-prompt.md`.

## Context

- Bestanden beschikbaar: !`ls website/*.html website/css/*.css website/js/*.js 2>/dev/null`
- Pagina's: !`ls -1 website/*.html | xargs -I {} basename {}`

## Projectspecifieke context

Dit is een **statische HTML/CSS/JS site** voor een therapiepraktijk. Houd rekening met:

- Doelgroep: stress-sensitieve bezoekers — rustig, veilig, uitnodigend
- Stack: geen frameworks, geen build-systeem — alle aanbevelingen moeten werken met plain HTML/CSS/JS
- Kleurenpalet: Duin Harmonie (zie `.claude/rules/colors.md`) — stel geen nieuwe kleuren voor zonder overleg
- Toegankelijkheid: WCAG 2.1 AA minimum — zie `.claude/rules/accessibility.md`
- Contenttoon: warm, nuchter, niet-medisch — zie `.claude/rules/content.md`

## Task

$ARGUMENTS

Als geen specifieke pagina opgegeven, review dan `website/index.html` als startpunt en geef aan welke andere pagina's aandacht nodig hebben.
