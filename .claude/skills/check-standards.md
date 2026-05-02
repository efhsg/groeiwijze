---
name: check-standards
description: Snelle pre-flight check op gestaged bestanden tegen projectstandaarden
area: validation
provides:
  - preflight_check
depends_on:
  - rules/colors.md
  - rules/html-css.md
  - rules/accessibility.md
  - rules/content.md
  - rules/security.md
---

# Check Standards

Screen gestaged bestanden snel op evidente projectregel-schendingen. Dit is geen volledige review; gebruik `/review-changes` voor diepere analyse.

## When to Use

- Vlak vóór commit
- Wanneer de gebruiker `/check-standards` aanroept
- Als snelle gate vóór `/finalize-changes`

## Algorithm

1. Run `git diff --cached --name-only`.
2. Stop met "Geen gestaged bestanden" als de lijst leeg is.
3. Lees elk gestaged bestand dat relevant is voor HTML, CSS, JS, PHP of `.claude/` documentatie.
4. Controleer alleen evidente schendingen:
   - CSS: niet-getokeniseerde hex/rgb buiten toegestane tokens, magische spacing, grove BEM-schendingen
   - HTML: `lang="nl"`, precies één `<h1>`, `alt` op elke `<img>`, labels bij form controls, skip-link en `<main>`
   - Content: verboden woorden, urgente CTA-taal, medische claims
   - PHP: honeypot, tijdcheck, rate limiting, server-side validatie, geen inline credentials
   - `.claude/`: writing standards, bestaande paden, klikbare-keuze syntax
5. Rapporteer per bestand `OK` of een korte issue-lijst.

## Output Format

```markdown
## Check Standards

**Gecheckt:** N bestanden
**Issues gevonden:** M

### Bestanden
- `pad`: OK
- `pad:regel` — issue

**Klaar voor commit:** Ja|Nee
```

Als er issues zijn en je eindigt met een gesloten vervolgkeuze:

```markdown
Fix issues / Review volledig / Stop?
```

## Definition of Done

- Alleen gestaged bestanden beoordeeld
- Evidente issues met bestand:regel gerapporteerd
- Geen wijzigingen gemaakt
