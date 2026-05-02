---
name: review-changes
description: Review frontend wijzigingen op correctheid, stijl en projectcompliance
area: validation
provides:
  - code_review
depends_on:
  - rules/colors.md
  - rules/html-css.md
  - rules/accessibility.md
  - rules/content.md
  - rules/security.md
---

# ReviewChanges

Voer een gestructureerde review uit van gewijzigde bestanden tegen de projectregels en best practices.

## Persona

Senior front-end developer voor statische websites. Kent het groeiwijze.nl project: Duin Harmonie kleurenpalet, BEM naamgeving, WCAG 2.1 AA, stress-sensitieve bezoekers, PHP contactformulier met anti-spam.

## When to Use

- Vóór een commit — sweep van correctheid, stijl en projectregels
- Na een substantiële wijziging — defect detectie
- Gebruiker roept `/review-changes` aan (autonomous) of `/review-changes interactive`

## Inputs

- `mode` (optioneel): `interactive` of `autonomous` (default)

## Outputs

- Review Summary — bestanden gereviewd, status (PASS / PASS WITH COMMENTS / NEEDS CHANGES)
- Findings — severity-tagged bevindingen met bestandsreferenties
- Recommendations — prioriteit-geordende actiepunten

## Mode

- **interactive** — toon Phase 0 plan en wacht op goedkeuring; toon sluitende slash-vraag
- **autonomous** — auto-approve Phase 0; geen sluitende slash-vraag; stop na aanbevelingen

## Memory Safety

Bevindingen zijn gebaseerd op de huidige bestandsinhoud (gelezen op evaluatiemoment), niet alleen op diffs. Als een claim niet verifieerbaar is, tag het `[NEEDS-VERIFICATION]`.

## Edge Cases

| Situatie | Aanpak |
|----------|--------|
| Geen gewijzigde bestanden | Meld "Geen wijzigingen" en stop |
| Alleen `.md` / docs gewijzigd | Controleer alleen formatting en linkintegriteit |
| Alleen `contact-submit.php` | Focus op security sub-check |

## Review Phases

### Phase 0: Plan

Presenteer een review plan. Laat de gebruiker de scope bijsturen voordat analyse begint.

### Phase 1: Defect Detection

1. **Kleuren** — Komen alle kleuren uit het Duin Harmonie palet? Worden CSS custom properties gebruikt (`var(--color-name)`)? Geen willekeurige hex-waarden.
2. **HTML & CSS** — BEM naamgeving correct? Page template consistent (DOCTYPE, lang="nl", semantische elementen, heading hierarchie)? Responsive mobile-first met juiste breakpoints?
3. **Accessibility** — WCAG 2.1 AA: contrastverhoudingen, focus-indicators, alt-teksten, form labels, heading hierarchie, skip-link, touch targets (44x44px)?
4. **Content toon** — Nederlands? Warm, nuchter, niet-medisch? Geen verboden woorden (behandeling, patient, urgentie-taal)? Max 1 primaire CTA per pagina?
5. **Security** (alleen bij PHP-wijzigingen) — Honeypot aanwezig? Tijdcheck? IP rate limiting? Input sanitization? Credentials buiten document root?

### Phase 2: Design Refinement

Alleen als Phase 1 PASS is **en** gebruiker kiest `Continue review`. Check naamgeving, structuur en consistentie over pagina's heen.

## Algorithm

### Phase 0 Algorithm

1. Run `git status --porcelain` en `git diff --stat`
2. Bepaal change type (HTML / CSS / JS / PHP / mixed)
3. Filter sub-checks op relevantie
4. Presenteer plan:

   ```
   ## Review Plan

   **Bestanden:** N gewijzigd
   **Type:** {type}
   **Sub-checks:** {lijst}

   Approve plan / Aanpassen / Skip planning?
   ```

   **Interactive mode:** wacht op input. **Autonomous mode:** ga direct door.

### Phase 1 Algorithm

1. Run `git status --porcelain` en `git diff`
2. **VERPLICHT** — Lees elk gewijzigd bestand volledig
3. **VERPLICHT** — Gebruik `Grep` voor cross-file checks (bijv. kleurgebruik, BEM-patronen)
4. **VERPLICHT** — Laad projectregels uit `.claude/rules/`
5. Evalueer elk bestand tegen de van toepassing zijnde sub-checks
6. Categoriseer bevindingen op severity (Critical/High/Medium/Low)
7. **VERPLICHT** — Tag elke bevinding met `[HIGH-CONFIDENCE]` of `[NEEDS-VERIFICATION]`

## Severity Levels

| Level | Criteria | Voorbeeld |
|-------|----------|-----------|
| **Critical** | Toegankelijkheidsbarriëres, security-issues, willekeurige kleuren | Hardcoded hex kleur; ontbrekend form label |
| **High** | BEM-schendingen, gebroken responsive, verboden content-taal | Klassenaam niet in BEM; "behandeling" op pagina |
| **Medium** | Ontbrekende alt-tekst, inconstente heading hierarchie | `<img>` zonder alt; h3 vóór h2 |
| **Low** | Kleine verbeteringen, naamgevingssuggesties | Variabele niet via CSS custom property |

## Output Format

```
## Review Summary

**Bestanden gereviewd:** N | **Status:** PASS | PASS WITH COMMENTS | NEEDS CHANGES

## Findings

### Critical / High / Medium / Low
- `pad/naar/bestand:REGEL` — beschrijving `[HIGH-CONFIDENCE|NEEDS-VERIFICATION]`

## Recommendations

1. ...
```

Bij status **PASS** of **PASS WITH COMMENTS**: sluit af met `Voer /finalize-changes uit om te committen.`

**Interactive mode:** voeg toe op de laatste regel:

```
Finalize / Continue review / Skip?
```

## Definition of Done

- Phase 0 plan gepresenteerd en goedgekeurd (of overgeslagen) vóór Phase 1
- Alle gewijzigde bestanden gereviewd tegen de vijf sub-checks
- Bevindingen refereren een specifiek bestand:regel met confidence tag
- Phase 2 draait alleen als Phase 1 PASS is en gebruiker expliciet koos voor `Continue review`
