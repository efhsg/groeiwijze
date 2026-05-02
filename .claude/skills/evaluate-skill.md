---
name: evaluate-skill
description: Semantische evaluatie van een Claude skill — past het algoritme bij het gestelde doel? Read-only, advies.
area: validation
provides:
  - semantic_evaluation
depends_on: []
---

# Evaluate Skill

Evalueer of het algoritme van een Claude skill daadwerkelijk past bij het gestelde doel. Waar `/optimize-skill` een structurele linter is, stelt deze skill semantische vragen: dekt het algoritme realistische scenario's? Ontbreken domein-evidente stappen? Past de output bij wat het doel impliceert?

**Read-only.** Produceert een diagnostisch rapport, fixt nooit automatisch.

## Persona

Senior reviewer met cross-domein ervaring. Combineert structurele patroonherkenning (tegen peer-skills in dezelfde `area`) met domein-rubrics (workflow heeft X nodig, validatie heeft Y nodig) en open oordeel. Eerlijk over confidence: onderscheidt harde bevindingen (peer-evidence, deterministisch) van zachte (rubric-interpretatie, LLM-only).

## When to Use

- Nadat `/optimize-skill` structureel slaagt — vraag nu "is het ook goed?"
- Vóór een skill in frequent gebruik komt — sondeer op blinde vlekken
- Wanneer een skill matige output produceert en je het *ontwerp* verdacht vindt
- Gebruiker roept `/evaluate-skill <target>` aan

## Inputs

- `target` (verplicht) — skill naam of pad. Zelfde resolutie als `/optimize-skill` Phase 0.

## Outputs

Conversational rapport met drie dimensies, elk gemarkeerd met confidence:

- **Peer-comparison** (high confidence) — typische skeleton voor de `area`, afwijkingen in target
- **Rubric evaluation** (medium confidence) — verdict per rubric-vraag met bewijs
- **LLM-judgment** (low confidence, advies) — open beoordeling van domein-evidente zorgen
- **Summary verdict** — overall semantische uitlijning

Geen bestanden gewijzigd. Geen fix-flow. Gebruiker neemt het rapport mee naar `/optimize-skill` of bewerkt handmatig.

## Algorithm

### Phase 0: Target resolution

Identiek aan `/optimize-skill` Phase 0.

**Aanvullend:** lees target frontmatter. Als ontbrekend OF `area` veld afwezig: STOP — draai eerst `/optimize-skill <target>`.

### Phase 1: Peer discovery

1. Scan `.claude/skills/*.md` frontmatter op peers met dezelfde `area` (target uitgesloten).
2. Lees alle peers volledig — geen sample.
3. Cache peers voor Phase 2.

**Insufficient-corpus stop:** als minder dan 2 peers bestaan in de area, markeer peer-comparison als "insufficient corpus", sla die dimensie over, ga door met rubric + LLM-judgment.

### Phase 2: Drie-dimensionale evaluatie

#### 2.1 Peer-comparison (high confidence)

Bouw "typische skeleton" voor de area:
- Enumereer H2 secties over peers
- Een sectie is "typisch" als aanwezig in ≥50% van peers
- Vergelijk target met typische skeleton

Findings:
- **Missing typical sections** — target mist secties die de meeste peers hebben
- **Unusual sections** — target heeft secties die geen peer heeft

#### 2.2 Domain-rubric (medium confidence)

Pas rubric toe die past bij target's `area`. Verdict per vraag:

- **Clear alignment** — bewijs direct in skill body
- **Partial** — adresseert maar met gaten
- **Unclear** — niet uit body op te maken
- **Misaligned** — skill spreekt het tegen
- **N/a** — niet van toepassing

**Workflow rubric** (`area: workflow`):

| Q | Vraag |
|---|-------|
| W1 | Happy-path coverage — dekt het algoritme de hoofduse-case end-to-end? |
| W2 | Failure modes — worden realistische fouten geadresseerd? |
| W3 | Verification step — is er een check dat output correct is vóór terminatie? |
| W4 | Escape hatch — kan gebruiker stoppen of inspecteren mid-flow? |
| W5 | Input→output producible — gegeven inputs, is de output bereikbaar? |

**Validation rubric** (`area: validation`):

| Q | Vraag |
|---|-------|
| V1 | Pass/fail criterion — wat bepaalt een passing check? |
| V2 | Coverage — duidelijke domein-gaten in checklist? |
| V3 | False-positive handling — wat als een regel ten onrechte triggert? |
| V4 | Applicability signal — hoe beslist skill dat een check n/a is? |
| V5 | Regression guard — voorkomt het introduceren van nieuwe issues? |

#### 2.3 LLM-judgment (low confidence, advies)

Open beoordeling: gegeven het doel van deze skill, en na lezen van algoritme en peers, welke domein-evidente zorgen worden NIET gedekt door peer-comparison of rubric? Noem 1–3 specifieke zorgen met redenering.

### Phase 3: Presentatie

```
## Semantische evaluatie: {skill}

### Goal (geëxtraheerd)
{één zin uit frontmatter description + body context}

### Peer-comparison — {area}, {N} peers
Peers gelezen: {namen}
Typische skeleton (≥50% van peers):
- {sectie} ({X}/{N} peers)

Deviaties in {skill}:
- MISSING TYPICAL: {sectie}
- UNUSUAL: {sectie}

### Rubric — {area}
| # | Vraag | Verdict | Bewijs |

### LLM-judgment (advies, lower confidence)
{2–3 alinea's}

### Summary
Semantische uitlijning: **Strong** / **Partial** / **Gaps** / **Misaligned**

{één-zins overall take}
```

### Phase 4: Follow-up

```
Run /optimize-skill voor structurele bevindingen / Drill into finding {N} / Accept / Edit skill manually?
```

**Wacht op gebruikersinput.**

## Stop Points

**VERPLICHT** — Stop en vraag wanneer:

- Target onresolvable
- Target heeft geen frontmatter OF `area` ontbreekt — verwijs naar `/optimize-skill` eerst
- Area heeft geen rubric — sla rubric-dimensie over, ga door met peer + LLM

## Definition of Done

- Target resolved en gelezen
- Peers ontdekt en gelezen (of "insufficient corpus" gemeld)
- Elke dimensie heeft verdict met expliciete confidence
- Rubric-verdicts citeren concreet bewijs uit target skill
- LLM-judgment gemarkeerd als advies / lower confidence
- Summary verdict geproduceerd
- **Geen bestanden gewijzigd** (read-only invariant)

## Anti-patterns

| Vermijd | Doe in plaats |
|---------|---------------|
| Auto-toepassen van semantische suggesties | Read-only by design — gebruiker beslist |
| Semantisch met structureel mengen | Verwijs naar `/optimize-skill` voor structureel |
| Deterministische zekerheid claimen op LLM-judgment | Markeer expliciet als lower confidence |
| Rubric-verdict zonder bewijs | Citeer altijd tekst (of afwezigheid) uit skill |
| Skill zonder frontmatter / area evalueren | Stop — structureel gat eerst fixen via `/optimize-skill` |
