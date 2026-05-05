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
- Na een substantiële wijziging — defect detectie vóór `/finalize-changes`
- Gebruiker roept `/review-changes` aan (autonomous, CI-vriendelijk) of `/review-changes interactive` (goedkeuringsgated, opent Phase 2)

Sla over voor:

- Branches zonder wijzigingen (harde stop in Phase 0)
- Docs-only diffs (afgehandeld in Edge Cases → alleen formatting + linkintegriteit)

## Inputs

- `mode` (optioneel): `interactive` of `autonomous` (default). Zie `## Mode` voor semantiek.

## Outputs

- Review Summary — bestanden gereviewd, fasenummer, statusverdict (PASS / PASS WITH COMMENTS / NEEDS CHANGES)
- Findings — severity-tagged bevindingen met `bestand:regel` referenties en confidence-tags
- Recommendations — prioriteit-geordende actiepunten
- IDE shortcuts — `code --goto` commando's voor Critical/High bevindingen
- Sluitregel (alleen bij PASS / PASS WITH COMMENTS) — verwijzing naar `/finalize-changes`

## Language

Output de review in het Nederlands tenzij de gebruiker expliciet om Engels vraagt.

## Mode

`mode`: `interactive` of `autonomous` (default).

- **interactive** — toon Phase 0 plan en wacht op goedkeuring; toon sluitende slash-vraag.
- **autonomous** — auto-approve Phase 0 plan; voeg `Voer /finalize-changes uit / Klaar?` toe na de aanbevelingen. Bedoeld voor CI of gescripte reviews.

**Phase 2 toepasbaarheid:** autonomous mode draait alleen Phase 1 — Phase 2 design-refinement vereist de expliciete `Continue review` keuze van de gebruiker en draait dus alleen in interactive mode.

## Memory Safety

Bevindingen moeten gebaseerd zijn op de huidige bestandsinhoud (gelezen op evaluatiemoment), niet alleen op diffs, eerdere runs of aannames. Als een claim niet verifieerbaar is tegen het huidige bestand, tag de bevinding `[NEEDS-VERIFICATION]` of laat hem weg.

## Edge Cases

| Situatie | Aanpak |
|----------|--------|
| Geen gewijzigde bestanden | Meld "Geen wijzigingen om te reviewen" en stop |
| Alleen `.md` / docs gewijzigd | Sla sub-checks 1–4 over; controleer alleen formatting en linkintegriteit |
| Alleen `contact-submit.php` | Focus op security sub-check (#5) |
| Bestand te groot om volledig te lezen | Lees in chunks; tag gerelateerde bevindingen als `[NEEDS-VERIFICATION]` |

## Review Phases

### Phase 0: Plan

Presenteer een review plan voordat je analyseert. Laat de gebruiker de scope bijsturen voordat analyse begint.

### Phase 1: Defect Detection

Draait eerst. Los Critical en High issues op vóór Phase 2; Medium en Low mogen blijven staan en landen in PASS WITH COMMENTS.

1. **Kleuren** — Komen alle kleuren uit het Duin Harmonie palet? Worden CSS custom properties gebruikt (`var(--color-name)`)? Geen willekeurige hex-waarden.
2. **HTML & CSS** — BEM naamgeving correct? Page template consistent (DOCTYPE, lang="nl", semantische elementen, heading hierarchie)? Responsive mobile-first met juiste breakpoints?
3. **Accessibility** — WCAG 2.1 AA: contrastverhoudingen, focus-indicators, alt-teksten, form labels, heading hierarchie, skip-link, touch targets (44x44px)?
4. **Content toon** — Nederlands? Warm, nuchter, niet-medisch? Geen verboden woorden (behandeling, patient, urgentie-taal)? Max 1 primaire CTA per pagina?
5. **Security** (alleen bij PHP-wijzigingen) — Honeypot aanwezig? Tijdcheck? IP rate limiting? Input sanitization? Credentials buiten document root?

### Phase 2: Design Refinement

Draait alleen wanneer Phase 1 schoon is **en** de gebruiker expliciet voor `Continue review` koos. Pas SOLID, DRY, YAGNI toe; check naamgeving en structuur over pagina's heen. Stop wanneer het doel bereikt is.

## Algorithm

### Phase 0 Algorithm

1. **Pre-flight check** — verifieer dat `git status` schoon draait (geen merge-conflicten, geldige HEAD). Bij breuk: stop en rapporteer.
2. Run `git status --porcelain` en `git diff --stat` om scope te bepalen
3. Detecteer change type (HTML / CSS / JS / PHP / docs / mixed) uit paden en extensies
4. Filter Phase 1 sub-checks (#1–#5) op relevantie voor dit type
5. Presenteer plan:

   ```
   ## Review Plan

   **Bestanden:** N gewijzigd (X toegevoegd, Y aangepast, Z verwijderd)
   **Type:** {type}
   **Sub-checks:** {toepasbare lijst}
   **Prioriteit:** {bv. "Security eerst — contact-submit.php gewijzigd"}

   Approve plan / Aanpassen / Skip planning?
   ```

   **Wacht op input. Ga niet door tot beantwoord.**

   Autonomous mode keurt deze gate auto goed en gaat door zonder te wachten.

6. Bij `Aanpassen`: integreer feedback, presenteer opnieuw. Bij `Skip planning`: ga door met alle sub-checks.

### Phase 1 Algorithm

1. Run `git status --porcelain` en `git diff` (of `git diff --staged`)
2. **VERPLICHT** — Lees elk gewijzigd bestand volledig (niet alleen de diff)
3. **VERPLICHT** — Gebruik `Grep` voor cross-file checks: kleurgebruik elders, BEM-patroon-afwijkingen, gebroken referenties, dubbele utility classes
4. **VERPLICHT** — Laad projectregels uit `.claude/rules/`
5. Evalueer elk bestand tegen de van toepassing zijnde Phase 1 sub-checks
6. Categoriseer bevindingen op severity (Critical/High/Medium/Low)
7. **VERPLICHT** — Tag elke bevinding met `[HIGH-CONFIDENCE]` (volledige inhoud gelezen) of `[NEEDS-VERIFICATION]` (zie `## Memory Safety` voor wanneer deze tag geldt)
8. Rapporteer bevindingen — stop hier als Critical of High issues bestaan

**Schaling:** voor >20 gewijzigde bestanden, groepeer per module (HTML pagina's, CSS, PHP, JS, assets) en lever een sub-summary per groep vóór de overall summary.

### Phase 2 Algorithm

Trigger: Phase 1 rapporteerde PASS / PASS WITH COMMENTS **en** gebruiker koos `Continue review` boven `Finalize`.

1. **VERPLICHT** — Herlees gewijzigde bestanden met design-lens
2. Pas SOLID/DRY/YAGNI toe; check naamgeving en parameter-volgorde-consistentie
3. Rapporteer verfijningen als Low severity

## Severity Levels

| Level | Criteria | Actie | Voorbeeld |
|-------|----------|-------|-----------|
| **Critical** | Toegankelijkheidsbarrières, security-issues, willekeurige kleuren | Moet gefixt vóór commit | Hardcoded hex kleur; ontbrekend form label; PHP zonder honeypot |
| **High** | BEM-schendingen, gebroken responsive, verboden content-taal | Zou gefixt moeten vóór commit | Klassenaam niet in BEM; "behandeling" op pagina; geen mobile breakpoint |
| **Medium** | Ontbrekende alt-tekst, inconsistente heading hierarchie | Aanbevolen te fixen | `<img>` zonder alt; h3 vóór h2 |
| **Low** | Kleine verbeteringen, naamgevingssuggesties | Overwegen | Variabele niet via CSS custom property; ontbrekende code-comment |

## Output Format

```
## Review Summary

**Bestanden gereviewd:** N | **Phase:** 1 of 2 | **Status:** PASS / PASS WITH COMMENTS / NEEDS CHANGES

## Findings

### Critical / High / Medium / Low
- `pad/naar/bestand:REGEL` — beschrijving `[HIGH-CONFIDENCE|NEEDS-VERIFICATION]`

## Recommendations

1. ...

## IDE Shortcuts

Voor Critical en High bevindingen:

- `code --goto pad/naar/bestand:regel`
```

Bij status **PASS** of **PASS WITH COMMENTS**: sluit af met de regel `Voer /finalize-changes uit om de commit voor te bereiden.`.

**Interactive mode:** voeg een lege regel en deze slash-syntax-vraag toe op de laatste regel (geen tekst erna), wacht dan op input:

```
Finalize / Continue review / Skip?
```

**Autonomous mode:** voeg een lege regel en deze slash-syntax-vraag toe op de laatste regel (geen tekst erna):

```
Voer /finalize-changes uit / Klaar?
```

## Stop Points

Harde stops (beide modes) — stop en rapporteer, ga niet door:

- Pre-flight check faalt (git ongezond, merge-conflicten, ongeldige HEAD)
- Geen gewijzigde bestanden gedetecteerd

User-input gates:

- Phase 0 plan (alleen interactive; autonomous gaat auto door) — `Approve plan / Aanpassen / Skip planning?`
- Sluitende beslissing bij PASS / PASS WITH COMMENTS:
  - Interactive — `Finalize / Continue review / Skip?`
  - Autonomous — `Voer /finalize-changes uit / Klaar?`

## Definition of Done

- Phase 0 plan gepresenteerd en goedgekeurd (of overgeslagen) vóór Phase 1
- Alle van toepassing zijnde bestanden gereviewd tegen de Phase 1 checklist
- Bevindingen refereren een specifiek bestand:regel en zijn getagd met confidence
- Phase 2 draait alleen wanneer Phase 1 schoon is **en** gebruiker expliciet `Continue review` koos
- Output volgt het format hierboven
