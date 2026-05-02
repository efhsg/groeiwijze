---
name: optimize-skill
description: Analyseer en optimaliseer een Claude skill (en eventueel command wrapper) tegen de skill-contract checklist
area: validation
provides:
  - skill_optimization
depends_on: []
---

# Optimize Skill

Analyseer een `.claude/skills/*.md` bestand (en de eventueel bijbehorende `.claude/commands/*.md` wrapper) en pas gestructureerde verbeteringen toe per gekozen mode.

## Persona

Claude Skill Architect. Specialist in `.claude/skills/` contracts en `.claude/commands/` wrappers. Weet wanneer een skill overlapt met `.claude/rules/`, wanneer een command wrapper afwijkt van zijn skill, en wanneer een entry ontbreekt in `index.md` of `skill-routing.md`.

## When to Use

- Gebruiker wil een bestaande skill in `.claude/skills/` verbeteren
- Gebruiker heeft een nieuwe skill geschreven en wil die laten reviewen vóór ingebruikname
- Gebruiker roept `/optimize-skill <target> [mode]` aan

## Inputs

- `target` (verplicht) — skill naam (bijv. `refactor`) of expliciet pad. Als weggelaten, toon `.claude/skills/*.md` en vraag.
- `mode` (optioneel, default `interactive`):
  - `interactive` — toon bevindingen, vraag per bevinding met buttons, pas goedgekeurde toe
  - `auto` — pas alleen high-confidence fixes toe; sla scope-veranderende edits over
  - `all` — pas alle bevindingen toe zonder vragen

## Outputs

- Analyserapport per checklist-item (pass / issue / n/a)
- Toegepaste wijzigingen (per mode)
- Geüpdatete `.claude/skills/index.md` en `.claude/rules/skill-routing.md` waar entries ontbreken

## References

Lees vóór beginnen:

- `.claude/skills/improve-prompt.md` — generieke checklist A1–D4
- `.claude/skills/custom-buttons.md` — button-syntax voor stop points
- `.claude/skills/index.md` — skill registry
- `.claude/rules/skill-routing.md` — routing entries

## Algorithm

### Phase 0: Target resolution

1. Parse `$ARGUMENTS`: eerste token = `target`, tweede token = `mode` (default `interactive`).
2. Resolve `target`:
   - **Bare name — skill first:** probeer `.claude/skills/<name>.md`. Indien gevonden, gebruik.
   - **Bare name — reverse lookup:** probeer `.claude/commands/<name>.md`. Lees body, extraheer `skills/<Y>.md` referentie.
   - **Expliciet pad:** gebruik as-is.
3. Discover command wrapper(s):
   - **Direct match:** `.claude/commands/<name>.md`
   - **Fallback grep:** zoek `.claude/commands/*.md` op `skills/<name>.md`
4. Valideer mode is een van `interactive`, `auto`, `all`.

### Phase 1: Context load

Lees volledig:

1. TARGET skill bestand
2. TARGET command wrapper (indien aanwezig)
3. `improve-prompt.md`, `custom-buttons.md`, `index.md`, `skill-routing.md`

### Phase 2: Evaluation

#### 2.1 Generic checklist

Pas `improve-prompt.md` checklist A1–D4 toe op skill body. Status per item: **pass / issue / n/a**.

#### 2.2 Skill-specific checklist

| # | Check | Common Issue |
|---|-------|--------------|
| S1 | **Frontmatter compleet** | Ontbrekende `name`, `description`, `area`, `provides`, of `depends_on`. `name` moet matchen met bestandsnaam. |
| S2 | **Contract secties aanwezig** | Alle skills: `Persona`, `When to Use`, `Definition of Done`. Workflow/creation/validation skills: ook `Inputs`, `Outputs`, `Algorithm`. |
| S3 | **Geen duplicatie met rules** | Skill herhaalt inhoud uit `.claude/rules/`. Vervang door referentie. |
| S4 | **Vermeld in index.md** | Skill ontbreekt in `.claude/skills/index.md` onder de juiste categorie |
| S5 | **Routing entry indien file-pattern-toepasselijk** | Als skill een concrete pad-glob noemt: moet entry hebben in `.claude/rules/skill-routing.md` → File Pattern Routing |
| S6 | **Command wrapper integriteit** | Vereist: `allowed-tools` past bij taak; `description` matcht skill purpose; body verwijst naar skill pad; `$ARGUMENTS` doorgegeven |
| S7 | **Stop points hebben buttons** | Stop/keuze-punten in skill body missen custom-buttons syntax |
| S8 | **DoD is testbaar** | Definition of Done is vaag ("werkt correct"). Elk item moet verifieerbaar zijn |

#### 2.3 Classificatie per mode

- **High-confidence** (toegepast in `auto`):
  - Typos, formatting fixes
  - Ontbrekende frontmatter velden met evidente waarden
  - Gebroken interne links
  - Ontbrekende `index.md` of routing entry waar categorie ondubbelzinnig is
  - Ontbrekende wait-instructie na bestaande button regel

- **Scope-changing** (overgeslagen in `auto`):
  - Herschrijven van Persona, When to Use, of andere contract secties
  - Toevoegen of verwijderen van algorithm fasen
  - Uitbreiden van Inputs/Outputs met nieuwe velden

### Phase 3: Findings presentation

#### Mode: interactive

```
## Skill analysis: {name}

### Summary
{1-2 zinnen over algemene kwaliteit}

### Findings
| # | Status | Finding | Proposal |
|---|--------|---------|----------|

### Score
{X}/{total} checks passed

Apply all / Select subset / Manual edit?
```

**Wacht op gebruikersinput. Ga niet door totdat geantwoord.**

#### Mode: auto

Geen approval. Pas high-confidence fixes toe. Sla scope-changing over.

```
## Auto mode — applied

### Applied ({N})
- {finding} — {wat veranderde}

### Skipped (scope-changing, {M})
- {finding} — reden

Re-run in interactive of all mode voor overige items.
```

#### Mode: all

Pas alle bevindingen toe.

```
## All mode — applied
{lijst}

Review changes / Revert / Accept?
```

**Wacht op gebruikersinput.**

### Phase 4: Re-check

Re-evalueer geüpdatete bestanden tegen de volledige checklist. Rapporteer status deltas.

## Stop Points

**VERPLICHT** — Stop en vraag wanneer:

- Skill bestand bestaat niet
- Ambigue target
- Voorgestelde wijziging zou skill hernoemen (bestandsnaam of `name`-frontmatter)
- Voorgestelde wijziging zou een Inputs/Outputs contract veld verwijderen
- Conflict tussen skill content en `.claude/rules/`
- Mode is `all` ÉN target heeft uncommitted git changes — waarschuw eerst

## Definition of Done

- Alle toepasselijke checklist items (A1–D4 + S1–S8) hebben status (pass / issue / n/a)
- Wijzigingen toegepast per mode
- `index.md` en `skill-routing.md` geüpdatet waar nodig
- Re-check toont geen regressies
- Frontmatter conventies exact bewaard

## Anti-patterns

| Vermijd | Doe in plaats |
|---------|---------------|
| Skill stilletjes hernoemen | Stop en vraag — hernamen breken routing, index, command wrapper |
| Contract secties verwijderen | Stop en vraag — deze definiëren de skill-interface |
| Inhoud uit `.claude/rules/` dupliceren | Verwijs naar de rule, herhaal niet |
| `auto` mode rewrites | Classificeer rewrites als scope-changing; sla over in `auto` |
| Command wrapper overslaan als die bestaat | Wrapper drift is reëel; altijd in scope nemen |
