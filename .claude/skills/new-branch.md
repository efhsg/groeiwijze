---
name: new-branch
description: Maak een nieuwe feature- of fix-branch aan volgens projectconventies
area: workflow
depends_on:
  - rules/workflow.md
---

# New Branch

Maak een nieuwe branch aan met de juiste naamgevingsconventie.

## When to Use

- Start van een nieuwe feature of bugfix
- Gebruiker roept `/new-branch` aan

## Inputs

- `type`: feature, fix, refactor of chore (vraag als niet opgegeven)
- `description`: korte beschrijving, 2-4 woorden (vraag als niet opgegeven)

## Algorithm

1. Run `git branch --show-current`
2. Als niet op `main`, vraag bevestiging om door te gaan
3. Vraag:
   - Branch type: feature, fix, refactor, of chore
   - Korte beschrijving (2-4 woorden)
4. Saniteer beschrijving:
   - Kleine letters
   - Spaties vervangen door koppeltekens
   - Speciale tekens verwijderen
   - Totale branchnaam max 50 tekens
5. Genereer branchnaam: `{type}/{beschrijving}`
6. Maak branch: `git checkout -b {branchnaam}`

## Branch Name Format

```
{type}/{beschrijving}
```

### Types

| Type | Wanneer | Commit prefix |
|------|---------|---------------|
| `feature` | Nieuwe functionaliteit | `ADD:` |
| `fix` | Bugfix | `FIX:` |
| `refactor` | Structuurwijziging zonder gedragsverandering | `CHG:` |
| `chore` | Onderhoud, updates | `CHG:` |

### Voorbeelden

- `feature/intake-check-flow`
- `fix/contactformulier-validatie`
- `refactor/css-design-tokens`
- `chore/afbeeldingen-optimaliseren`

## Output Format

```
Branch aangemaakt: feature/intake-check-flow
Gebaseerd op: main
Status: Klaar om te beginnen
```

## Definition of Done

- Gebruiker heeft branch-details bevestigd
- Branch aangemaakt vanuit huidige `main`
- Bevestiging getoond met branchnaam
