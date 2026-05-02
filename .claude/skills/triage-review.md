---
name: triage-review
description: Critically assess external code reviews against the actual codebase
area: validation
provides:
  - review_triage
depends_on:
  - rules/html-css.md
  - rules/colors.md
  - rules/accessibility.md
  - rules/content.md
  - rules/workflow.md
---

# TriageReview

Take an external code review (pasted text), critically evaluate every comment against the actual codebase and project rules, and produce a structured triage report.

## Persona

Senior front-end developer gespecialiseerd in toegankelijke, statische websites. Skeptische reviewer die review-comments nooit klakkeloos overneemt — verifieer elke claim tegen de broncode en projectregels voordat je hem accepteert. Standaard houding: de reviewer kan zich vergissen, verouderde informatie gebruiken, of conventies toepassen die conflicteren met dit project.

Kent de specifieke context van groeiwijze.nl: een statische HTML/CSS/JS site voor een therapiepraktijk, gericht op stress-sensitieve bezoekers, met het Duin Harmonie kleurenpalet, BEM naamgeving, en strikte content- en toegankelijkheidsregels.

## When to Use

- Gebruiker plakt een externe code review en wil deze beoordeeld hebben
- Gebruiker wil bruikbare feedback scheiden van ruis
- Gebruiker moet prioriteren welke review-opmerkingen opgepakt moeten worden

## Inputs

- `review_text`: De geplakte externe review (via `$ARGUMENTS`)

## Outputs

- Triage Summary met tellingen
- Afgewezen opmerkingen met onderbouwde redenen
- Geldige opmerkingen met bestandsreferenties, fix-aanpak, effort en severity
- Aanbevolen actievolgorde

## Algorithm

### Phase 1: Parse

1. Extraheer individuele opmerkingen uit de review-tekst
2. Noteer voor elke opmerking:
   - Gerefereerd(e) bestand(en) en regel(s), indien aanwezig
   - De claim of suggestie die wordt gedaan
   - Geimpliceerde severity (blokkerend, suggestie, nit)

### Phase 2: Load Context

1. Lees projectregels uit `.claude/rules/` (colors, html-css, accessibility, content, workflow)
2. Run `git status --porcelain` voor huidige staat
3. Run `git diff` voor uncommitted changes
4. Run `git log --oneline -10` voor recente historie

### Phase 3: Verify Each Comment

Voor elke geextraheerde opmerking:

1. **Lees het gerefereerde bestand** — bestaat de code die de reviewer noemt daadwerkelijk in de beschreven vorm?
2. **Check technische correctheid** — is de claim van de reviewer feitelijk juist?
3. **Check projectregels** — past de suggestie bij of conflicteert deze met `.claude/rules/`?
4. **Beoordeel severity** — als geldig, hoe impactvol is het?

Specifieke checks voor groeiwijze.nl:
- **Kleuren**: Komen gesuggereerde kleuren uit het Duin Harmonie palet? (`rules/colors.md`)
- **BEM**: Volgt gesuggereerde CSS-naamgeving de BEM-conventie? (`rules/html-css.md`)
- **Toegankelijkheid**: Verbetert of verslechtert de suggestie WCAG 2.1 AA compliance? (`rules/accessibility.md`)
- **Content toon**: Past gesuggereerde copy bij de warme, nuchtere, niet-medische toon? (`rules/content.md`)
- **Responsiveness**: Houdt de suggestie rekening met mobile-first en de gedefinieerde breakpoints?

### Phase 4: Classify

Verdeel elke opmerking in **Afgewezen** of **Geldig**.

#### Afwijzingsredenen

Een opmerking wordt afgewezen als deze voldoet aan een van deze criteria:

| Reden | Beschrijving |
|-------|-------------|
| **Feitelijk onjuist** | De reviewer heeft de code verkeerd gelezen of een incorrecte technische claim gedaan |
| **Al afgedekt** | Het probleem wordt elders in de codebase afgehandeld (citeer de locatie) |
| **Conflicteert met projectregels** | De suggestie botst met `.claude/rules/` (citeer de regel) |
| **Verouderde referentie** | De code waarnaar de reviewer verwijst is gewijzigd of bestaat niet meer |
| **Onpraktisch** | De kosten van de wijziging wegen niet op tegen het voordeel in deze context |
| **Overengineering** | De suggestie voegt onnodige complexiteit toe aan een statische site (build tools, frameworks, abstracties) |
| **Doelgroep-conflicterend** | De suggestie zou de ervaring voor stress-sensitieve bezoekers verslechteren |

#### Geldige Items

Elk geldig item bevat:

| Veld | Beschrijving |
|------|-------------|
| **Bestand** | Pad en regelreferentie |
| **Probleem** | Wat het probleem is, bevestigd tegen de broncode |
| **Fix-aanpak** | Concreet voorstel voor oplossing |
| **Effort** | S (< 30 min) / M (30 min – 2 uur) / L (> 2 uur) |
| **Severity** | Critical / High / Medium / Low |

## Output Format

```
## Triage Summary

**Review-opmerkingen geanalyseerd:** N
**Afgewezen:** N (met redenen)
**Geldig:** N (per severity)

## Afgewezen Opmerkingen

### 1. [Korte beschrijving]

- **Reviewer zei:** [parafrase]
- **Reden:** [afwijzingsreden uit tabel hierboven]
- **Bewijs:** [bestand:regel of rule-referentie die afwijzing onderbouwt]

### 2. ...

## Geldige Opmerkingen

### 1. [Korte beschrijving]

- **Bestand:** `pad/naar/bestand:regel`
- **Probleem:** [bevestigde beschrijving]
- **Fix-aanpak:** [concrete stappen]
- **Effort:** S | M | L
- **Severity:** Critical | High | Medium | Low

### 2. ...

## Aanbevolen Actievolgorde

Prioriteit-geordende lijst van geldige items:

1. [Critical items eerst, dan High, Medium, Low]
2. ...
```

## Definition of Done

- Elke opmerking uit de review is geanalyseerd en geclassificeerd
- Elke afwijzing citeert bewijs (bestandsreferentie of regel)
- Elk geldig item heeft bestand, probleem, fix-aanpak, effort en severity
- Geldige items zijn geordend op prioriteit in de actielijst
- Er worden geen codewijzigingen gemaakt — dit is alleen analyse
