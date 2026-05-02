---
name: validate-spec
description: Lichtgewicht handmatige validatie van een feature-spec onder .ai/features/{naam}/spec.md
area: validation
depends_on:
  - templates/feature-spec.md
---

# Validate Spec

Doorloop een feature-spec en controleer op compleetheid. Geen mechanische linter — een gestructureerde checklist die Claude doorloopt.

## Persona

Functioneel reviewer. Leest de spec en controleert of elke sectie zinvol is ingevuld, of edge-cases gedekt zijn, en of acceptatiecriteria toetsbaar zijn.

## When to Use

- Vóór een spec van `draft` naar `accepted` wordt gezet
- Vóór implementatie begint
- Gebruiker roept `/validate-spec {pad}` aan

## Inputs

- `pad` (optioneel) — pad naar `spec.md`. Als weggelaten, toon `.ai/features/*/spec.md` en vraag.

## Algorithm

### Phase 1 — Lees en parse

1. Lees het volledige spec-bestand.
2. Identificeer aanwezige H2-secties.
3. Vergelijk met verplichte secties uit het sjabloon.

### Phase 2 — Check per sectie

| # | Check | Pass criterium |
|---|-------|----------------|
| C1 | **§1 Doel** | Bevat een `**Kernbericht**`-zin én minstens één toelichtingsalinea |
| C2 | **§2 Scope** | Heeft "In scope" én "Niet in scope" subsecties; niet-scope items hebben een `—` waarom-clausule |
| C3 | **§3 Bezoekersflow** | Bevat minstens drie genummerde stappen |
| C4 | **§4 Edge cases** | Bevat minstens drie tabel-rijen |
| C5 | **§5 Acceptatiecriteria** | Bevat minstens drie items met prefix `AC-N` of `AC-{slug}N` en een toetsbaar werkwoord |
| C6 | **§6 Impact** | Bevat een `**Raakt:**` regel die concrete pagina's of bestanden noemt |
| C7 | **§7 Open punten** | Aanwezig (mag leeg zijn als status `accepted` is) |
| C8 | **Geen placeholders** | Geen `<...>` placeholders meer als status `accepted` of `in-review` |

### Toetsbare werkwoorden (C5)

Een AC moet een van deze werkwoorden bevatten om als toetsbaar te tellen:

`toont, blokkeert, weigert, levert, registreert, vermeldt, bevat, faalt, passeert, verschijnt, redirecteert, valideert`

Vermijd "werkt correct" of "is gebruiksvriendelijk" — die zijn niet observeerbaar.

### Phase 3 — Rapport

```
## Spec validatie: {pad}

**Status:** {draft | in-review | accepted}

### Resultaten

| # | Check | Pass | Detail |
|---|-------|------|--------|
| C1 | §1 Doel — kernbericht + toelichting | ✓ / ✗ | {detail} |
| C2 | §2 Scope — in/niet-in-scope | ✓ / ✗ | {detail} |
| C3 | §3 Bezoekersflow — ≥3 stappen | ✓ / ✗ | {detail} |
| C4 | §4 Edge cases — ≥3 rijen | ✓ / ✗ | {detail} |
| C5 | §5 Acceptatiecriteria — ≥3 toetsbaar | ✓ / ✗ | {detail} |
| C6 | §6 Impact — Raakt-regel | ✓ / ✗ | {detail} |
| C7 | §7 Open punten | ✓ / ✗ | {detail} |
| C8 | Geen placeholders | ✓ / ✗ | {detail} |

### Score
{X}/8 checks geslaagd

{Indien alle pass}: Spec is klaar voor implementatie.
{Indien issues}: Pak {N} open items op vóór status verandert.

Aanpassen / Accepteren als-is / Stop?
```

**Wacht op gebruikersinput.**

## Stop Points

**VERPLICHT** — Stop en vraag wanneer:

- Spec-bestand bestaat niet — toon `.ai/features/*/spec.md`, vraag welke
- Spec bevat geen H2-secties (vermoedelijk niet uit het sjabloon) — vraag of het wel een feature-spec is

## Definition of Done

- Spec gelezen en alle 8 checks gerapporteerd met pass/fail + detail
- Score weergegeven (X/8)
- Sluitende slash-vraag gepresenteerd
- Geen wijzigingen aan spec-bestand (alleen rapportage)

## Verwijzingen

- Sjabloon: `.claude/templates/feature-spec.md`
- Generator: `skills/new-spec.md`
