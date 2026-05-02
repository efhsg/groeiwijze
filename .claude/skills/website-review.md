---
name: website-review
description: UI/UX en toegankelijkheidsreview van de website vanuit healthcare-perspectief
area: validation
provides:
  - website_review
depends_on:
  - rules/colors.md
  - rules/html-css.md
  - rules/accessibility.md
  - rules/content.md
---

# Website Review

Review groeiwijze.nl als statische praktijkwebsite voor stress-sensitieve bezoekers. Focus op UX, rust, scanbaarheid, toegankelijkheid en contenttoon.

## When to Use

- Gebruiker roept `/website-review` aan
- Na substantiële visuele of contentwijzigingen
- Voor publicatie van een pagina of flow

## Inputs

- `page` (optioneel) — specifieke pagina; als leeg, start bij `website/index.html`

## Algorithm

1. Lees `.ai/prompts/website-review-agent-prompt.md` als die bestaat.
2. Lees relevante rules: colors, html-css, accessibility, content.
3. Lees de doelpagina volledig, plus `website/css/style.css` en `website/js/main.js`.
4. Als geen pagina is opgegeven, review `website/index.html` en noteer welke andere pagina's vervolgcontrole nodig hebben.
5. Controleer:
   - Eerste indruk en navigatie
   - Stress-sensitieve toon en hoeveelheid tekst
   - CTA-rust en primaire CTA-aantal
   - Responsive risico's
   - WCAG-basics: headings, focus, skip-link, alt, labels, contrast
   - Consistentie met Duin Harmonie tokens en BEM
6. Geef prioriteit aan concrete verbeteringen met lage regressiekans.

## Output Format

```markdown
## Website Review: {pagina}

**Status:** PASS | PASS WITH COMMENTS | NEEDS CHANGES

## Bevindingen
- `bestand:regel` — beschrijving (severity)

## Aanbevolen volgorde
1. ...
```

## Definition of Done

- Doelpagina, stylesheet en relevante rules gelezen
- Bevindingen zijn concreet en project-specifiek
- Geen nieuwe kleuren, frameworks of build-stappen voorgesteld zonder expliciete reden
- Geen bestanden gewijzigd
