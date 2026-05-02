# Bugfix Workflow

## Instructies

Je fixt een bug op groeiwijze.nl. Doel: het beschreven gedrag corrigeren zonder andere observeerbare functionaliteit te veranderen, tenzij de taak expliciet anders aangeeft.

## Bug

GEN:{{Description}}

## Hard Requirements

- Respecteer bestaande patronen in `website/` (HTML/CSS/JS, BEM, Duin Harmonie tokens, page template)
- Maak de kleinste, helderste wijziging die de bug volledig oplost
- Voeg geen frameworks, build-stappen of derde-partij libraries toe
- Behoud bestaand gedrag van pagina's die niet bij de bug betrokken zijn
- Gebruik geen losse hex-waarden — alleen tokens uit `rules/colors.md`
- Houd content-toon intact — warm, nuchter, niet-medisch

## Bugfix fases

### Fase 1 — Diagnose

- Analyseer de bug binnen de scope van de beschrijving
- Identificeer de meest waarschijnlijke oorzaak: welke pagina, welk CSS-blok, welke JS-functie
- Bepaal de minimale fix-stappen, gegroepeerd per bestand
- Als een referentie of dependency ontbreekt: **stop** en vraag om context, raad niet

Presenteer:

```
## Diagnose

{wat is er mis, in welk bestand, vermoedelijke oorzaak}

## Fix-plan

{minimale stappen, betrokken bestanden}

Start fix / Plan aanpassen?
```

**Wacht op gebruikersinput. Ga NIET door totdat de gebruiker reageert.**

### Fase 2 — Fix

- Implementeer de fix volgens het plan uit Fase 1
- Houd wijzigingen cohesief en minimaal — alleen wat de bug oplost
- Toets visueel: vergelijk vóór en na in de browser op 375px en 1024px
- Toets toegankelijkheid bij UI-bugs: focus, contrast, alt-tekst

## Output Rules

- Wijzig alleen bestanden die in het fix-plan staan
- Geef per gewijzigd bestand de volledige finale inhoud, niet diffs
- Geen `console.log()` achterlaten in JavaScript
- Geen experimentele CSS-eigenschappen zonder fallback
- Geen `declare(strict_types=1)` toevoegen aan PHP

## Afsluiting

Na Fase 2, toon samenvatting:

```
## Bugfix samenvatting

**Gewijzigd:** {bestanden}
**Wat de fix doet:** {korte beschrijving}
**Visueel getest:** {viewports}
**Bijwerkingen gecheckt:** {welke pagina's bekeken op regressie}
```

Commit wijzigingen / Review wijzigingen / Aanpassen?

**Wacht op gebruikersinput. Ga NIET door totdat de gebruiker reageert.**
