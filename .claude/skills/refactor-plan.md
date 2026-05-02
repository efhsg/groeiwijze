---
name: refactor-plan
description: Analyseer de website en maak een refactoringplan zonder wijzigingen
area: validation
provides:
  - refactor_plan
depends_on:
  - rules/colors.md
  - rules/html-css.md
  - rules/accessibility.md
  - rules/content.md
  - codebase_analysis.md
---

# Refactor Plan

Maak een gefaseerd refactoringplan voor HTML/CSS/JS zonder bestanden te wijzigen.

## When to Use

- Gebruiker roept `/refactor-plan` aan
- Voor een grotere opschoonronde
- Wanneer duplicatie, BEM-schendingen of inconsistenties vermoed worden

## Phases

1. **CSS Tokens & Duplicatie** — non-token kleuren, magische waarden, dubbele declaraties
2. **BEM Compliance** — niet-BEM klassen, inconsistente componentnamen
3. **Page Template Consistentie** — headings, meta-tags, `<main>`, skip-link, semantiek
4. **Accessibility Gaps** — alt, labels, focus, reduced motion, touch targets
5. **Content Toon** — verboden woorden, urgentie-taal, CTA-aantal

Als geen fase is opgegeven, analyseer alle fasen.

## Output

Schrijf het plan naar `.claude/refactor_plan.md` met per fase:

- Aantal violations
- Specifieke locaties (`bestand:regel`)
- Severity: Critical, High, Medium, Low
- Effort: S, M, L
- Quick wins
- Aanbevolen volgorde

## Definition of Done

- Relevante rules en code gelezen
- `.claude/refactor_plan.md` geschreven
- Geen websitebestanden gewijzigd
