# Feature — Stap 1: Ontwerp

## Feature

GEN:{{Description}}

## Output

Een ontwerp dat aansluit bij groeiwijze.nl conventies (zie `.claude/rules/`) en de Duin Harmonie design tokens.

## Richtlijnen

1. Ik geef je een feature-opdracht voor de website.
2. Analyseer wat er nodig is. Lees relevante bestaande pagina's en CSS.
3. Stel verhelderende vragen als iets onduidelijk is — bijvoorbeeld:
   - Welke pagina(s) raakt deze wijziging?
   - Past dit bij de stress-sensitieve doelgroep?
   - Zijn er bestaande componenten die hergebruikt kunnen worden?
4. Presenteer je analyse en ontwerpvoorstel:

```
## Analyse

{kernvraag, wat verandert er voor de bezoeker, welke pagina's raakt dit}

## Voorgestelde aanpak

{stappen, te wijzigen bestanden, hergebruik bestaande componenten/tokens}

## Open vragen

{onzekerheden, edge cases, of expliciet "geen open vragen"}

Start implementatie / Plan aanpassen?
```

**Wacht op gebruikersinput. Ga NIET door totdat de gebruiker reageert.**

## Aandachtspunten

- Houd het visueel consistent met bestaande pagina's (zelfde tokens, BEM, layout)
- Toets aan content-toon: warm, nuchter, niet-medisch (zie `rules/content.md`)
- Toets aan toegankelijkheid: WCAG 2.1 AA (zie `rules/accessibility.md`)
- Mobile-first denken — controleer hoe het zich gedraagt op 375px
