# Feature — Stap 2: Review van ontwerp

> **Scope:** voor ad-hoc design documents (`plan.md`, `analysis.md`, losse ontwerpschetsen). Voor formele feature-specs onder `.claude/design/{naam}/spec.md` gebruik `/validate-spec`. Voor code-review gebruik `/review-changes`.

## Review

**Document:** GEN:{{File}}

GEN:{{Review action}}

## Proces

1. **Lees** het ontwerpdocument
2. **Vergelijk** met bestaande patronen in `website/`
3. **Onderzoek** vergelijkbare bestaande pagina's of componenten om alignment te verifiëren
4. **Check** kwaliteitscriteria
5. **Rapporteer** bevindingen en verbeter indien gevraagd

## Kwaliteitscriteria

### Structuur

- [ ] Doel/samenvatting duidelijk beschreven
- [ ] Stappen logisch geordend en genummerd
- [ ] Bestanden overzicht aanwezig (nieuw/gewijzigd in `website/` of `.claude/`)
- [ ] Verificatie sectie met concrete checks (browser-test, accessibility-check)

### Volledigheid

- [ ] Alle requirements uit de feature-opdracht zijn afgedekt
- [ ] Geen ontbrekende stappen tussen input en eindresultaat
- [ ] Edge cases overwogen (lege staat, ontbrekende afbeelding, lange tekst, formulierfout)
- [ ] Plan sluit aan op de stijl en conventies van groeiwijze.nl

### Implementeerbaarheid

- [ ] Stappen zijn concreet ("voeg klasse `card__title--large` toe", niet "stylen")
- [ ] BEM-namen zijn gespecificeerd waar nieuw
- [ ] Tokens worden bij naam genoemd (geen losse hex-waarden)

### Consistentie met de site

- [ ] Volgt bestaande page template structuur
- [ ] Hergebruikt bestaande componenten waar mogelijk
- [ ] Sluit aan bij Duin Harmonie palet — geen nieuwe kleuren zonder rechtvaardiging
- [ ] BEM naamgeving consistent met rest van `style.css`

### Toegankelijkheid en toon

- [ ] Heading hiërarchie blijft kloppen
- [ ] Alt-tekst, focus, contrast geadresseerd
- [ ] Copy past bij content-toon (warm, nuchter, niet-medisch)
- [ ] Geen urgentie-taal of agressieve CTA's

### Mobile

- [ ] Mobiel gedrag expliciet beschreven
- [ ] Touch targets ≥44×44px
- [ ] Geen desktop-only hover-afhankelijkheden

## Output format

```markdown
# Review: [document naam]

## Score
[X/10] — [korte samenvatting]

## Bevindingen

### Goed
- [wat goed is]

### Verbeterpunten
| Issue | Locatie | Suggestie |
|-------|---------|-----------|
| [probleem] | [stap/sectie] | [hoe te verbeteren] |

### Open vragen
- [vragen die beantwoord moeten worden vóór implementatie]

## Verbeterd document

[Alleen indien "Review en verbeter": volledige verbeterde tekst]
```

Sluit af met:

Geen verbeterpunten — door naar implementatie / Aanpassen?

**Wacht op gebruikersinput. Ga NIET door totdat de gebruiker reageert.**
