---
name: new-spec
description: Genereer een nieuwe feature-spec onder .ai/features/{naam}/ op basis van een lichtgewicht sjabloon
area: workflow
depends_on:
  - templates/feature-spec.md
  - rules/workflow.md
---

# New Spec

Genereer een nieuwe `spec.md` onder `.ai/features/{naam}/`. Lichtgewicht — geen linter-gate, geen verplichte secties met regex-validatie.

## Persona

Functioneel analist. Kopieert het sjabloon, vult metadata, laat inhoudsecties leeg voor handmatige invulling. Geen AI-interpretatie — gebruiker schrijft de inhoud zelf.

## When to Use

- Start van een feature die meer is dan een kleine bugfix
- Gebruiker roept `/new-spec {naam}` aan

## Inputs

- `naam` (verplicht) — feature-map-naam. Moet matchen `^[a-z][a-z0-9-]{2,30}$`.

## Preconditions

- `.claude/templates/feature-spec.md` bestaat
- `naam` matcht het patroon hierboven

## Algorithm

### Phase 1 — Validatie

1. Valideer `naam` tegen `^[a-z][a-z0-9-]{2,30}$`. Bij mismatch: stop met uitleg.
2. Check of `.ai/features/{naam}/spec.md` al bestaat. Zo ja: stop, geen overwrite.
3. Lees `.claude/templates/feature-spec.md`. Bij leesfout of lege inhoud: stop.

### Phase 2 — Genereer

1. Maak directory: `mkdir -p .ai/features/{naam}`
2. Kopieer sjabloon naar `.ai/features/{naam}/spec.md`
3. Vervang placeholders:
   - `<feature-name>` → `{naam}` (auteur mag later herformuleren)
   - `<date>` → huidige datum `YYYY-MM-DD`
   - `<jouw-naam>` blijft als placeholder
4. Schrijf bestand

### Phase 3 — Output

```
Spec aangemaakt: .ai/features/{naam}/spec.md
Status: draft

Volgende stap:
- Vul de zeven secties in
- Optioneel: voeg `plan.md` en `insights.md` toe in dezelfde directory
- Draai `/validate-spec` om te controleren op compleetheid
```

## Edge Cases

| Situatie | Gedrag |
|----------|--------|
| `naam` bevat spaties of hoofdletters | Stop; toon vereist formaat |
| `.ai/features/{naam}/spec.md` bestaat al | Stop; geen overwrite |
| Sjabloon ontbreekt | Stop; meld dat sjabloon hersteld moet worden |

## Definition of Done

- `.ai/features/{naam}/spec.md` aangemaakt met datum en `{naam}` ingevuld
- Output bevat pad en volgende stap
- Geen overwrite van bestaande spec

## Verwijzingen

- Sjabloon: `.claude/templates/feature-spec.md`
- Validator: `skills/validate-spec.md`
