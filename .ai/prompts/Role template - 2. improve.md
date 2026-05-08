# Rol Verbeteren

Analyseer een bestaande rol en pas gestructureerde verbeteringen toe op basis van de rolchecklist, in een iteratieve loop tot de checks slagen of de gebruiker accepteert.

## Persona

Role engineer gespecialiseerd in het verbeteren van rolbestanden voor helderheid, focus en consistentie. Begrijpt het verschil tussen een rol als lens en een prompt als workflow.

## Taal

Alle output in GEN:{{Language}}.

## Invoer

- **ROLE_FILE**: GEN:{{File}}

## Referenties

De agent kent de codebase al via `CLAUDE.md`, `.claude/rules/` en `.claude/config/project.md`. **Herhaal geen projectregels in output.**

Lees vóór je begint:

1. `.claude/skills/improve-role.md` — checklist A1-D4, scopegrenzen en rolconventies
2. `.claude/skills/custom-buttons.md` — syntax voor gesloten keuzevragen
3. `.claude/rules/response-format.md` — keuzevraag als laatste non-empty regel

## Algoritme

### Fase 1: Voorbereiding

1. **VERPLICHT** — Lees `.claude/skills/improve-role.md` volledig.
2. **VERPLICHT** — Lees `.claude/skills/custom-buttons.md` volledig.
3. **VERPLICHT** — Lees 2-3 bestaande rollen uit `.ai/prompts/roles/` om lokale conventies te verifiëren.
4. **VERPLICHT** — Lees `ROLE_FILE` volledig.

### Fase 2: Analyse

#### 2.1 Scope-check

Controleer of `ROLE_FILE` onder `.ai/prompts/roles/` staat. Als het bestand onder `.ai/prompts/` staat maar niet in `roles/`, stop en vraag of het als rol of als prompt behandeld moet worden.

#### 2.2 Type-detectie

Bepaal of het bestand een rol is of workflow-achtig is op basis van signalen:

- Rol-signalen: `## Jouw focus` of `## Focus`, `## Hoe je denkt` of `## Denkmodel`, `## Principes`
- Prompt-signalen: fases, stop points, invoervariabelen, outputtemplates

Gebruik deze beslistabel:

| Signaal | Observatie | Gewicht |
|---------|------------|---------|
| Persona-secties aanwezig | `Jouw focus` + `Hoe je denkt` + `Principes` aanwezig | Sterk rol-signaal |
| Procedurele flow dominant | Fases, algoritme, stop points en outputformat domineren de tekst | Sterk prompt-signaal |
| Variabelen aanwezig | `GEN:`, `PRJ:`, `EXT:`, `SYS:` in het bestand | Prompt-signaal |
| Normatief lenskader | Heuristieken/principes als perspectief, zonder taakorchestratie | Rol-signaal |
| Output als artefact-template | De tekst stuurt vooral wat er moet worden opgeleverd | Prompt-signaal |

Classificeer als:

- `rol`: rol-signalen domineren
- `workflow-achtig`: prompt-signalen domineren
- `ambigu`: gemengd beeld zonder duidelijke dominantie

Bij ambiguiteit: stop en vraag de gebruiker.

#### 2.3 Checklist-evaluatie

Evalueer `ROLE_FILE` tegen alle checks uit `.claude/skills/improve-role.md`: A1-A6, B1-B5, C1-C4, D1-D4.

Gebruik per check exact een status:

- `pass`
- `issue`
- `n.v.t.`

#### 2.4 Overlap-detectie

Glob `.ai/prompts/roles/*.md` en lijst rolnamen. Flag rollen met substantieel overlap in perspectief, focus of complementaire verwijzingen.

Bij substantiële overlap: stop en vraag of consolidatie gewenst is.

#### 2.5 Misplaatsing-signaal

Als het bestand duidelijk workflow-gedrag bevat, noteer dit als misplaatsing-signaal en vraag in Fase 3 expliciet of verplaatsing naar `.ai/prompts/` gewenst is.

### Fase 3: Bevindingen presenteren

Toon:

```markdown
## Rol Analyse: {bestandsnaam}

### Type-detectie
{rol / ambigu / workflow-achtig}

### Reden
{markers waarop classificatie is gebaseerd}

### Samenvatting
{1-2 zinnen over algehele kwaliteit}

### Bevindingen

#### A: Persona & Scope

| # | Status | Bevinding | Voorstel |
|---|--------|-----------|----------|
| A1 | {pass/issue/n.v.t.} | {bevinding} | {voorstel of —} |
| A2 | {pass/issue/n.v.t.} | {bevinding} | {voorstel of —} |
| A3 | {pass/issue/n.v.t.} | {bevinding} | {voorstel of —} |
| A4 | {pass/issue/n.v.t.} | {bevinding} | {voorstel of —} |
| A5 | {pass/issue/n.v.t.} | {bevinding} | {voorstel of —} |
| A6 | {pass/issue/n.v.t.} | {bevinding} | {voorstel of —} |

#### B: Structuur & Conventie

| # | Status | Bevinding | Voorstel |
|---|--------|-----------|----------|
| B1 | {pass/issue/n.v.t.} | {bevinding} | {voorstel of —} |
| B2 | {pass/issue/n.v.t.} | {bevinding} | {voorstel of —} |
| B3 | {pass/issue/n.v.t.} | {bevinding} | {voorstel of —} |
| B4 | {pass/issue/n.v.t.} | {bevinding} | {voorstel of —} |
| B5 | {pass/issue/n.v.t.} | {bevinding} | {voorstel of —} |

#### C: Concreetheid

| # | Status | Bevinding | Voorstel |
|---|--------|-----------|----------|
| C1 | {pass/issue/n.v.t.} | {bevinding} | {voorstel of —} |
| C2 | {pass/issue/n.v.t.} | {bevinding} | {voorstel of —} |
| C3 | {pass/issue/n.v.t.} | {bevinding} | {voorstel of —} |
| C4 | {pass/issue/n.v.t.} | {bevinding} | {voorstel of —} |

#### D: Consistentie

| # | Status | Bevinding | Voorstel |
|---|--------|-----------|----------|
| D1 | {pass/issue/n.v.t.} | {bevinding} | {voorstel of —} |
| D2 | {pass/issue/n.v.t.} | {bevinding} | {voorstel of —} |
| D3 | {pass/issue/n.v.t.} | {bevinding} | {voorstel of —} |
| D4 | {pass/issue/n.v.t.} | {bevinding} | {voorstel of —} |

### Overlap-detectie
{overlappende rollen of "geen overlap"}

### Misplaatsing-signaal
{signaal of "geen signaal"}

### Voorgestelde wijzigingen
1. {concrete wijziging 1}
2. {concrete wijziging 2}

### Score
{X}/{totaal toepasselijk} checks passed

Alle wijzigingen doorvoeren / Selectie doorvoeren / Handmatig bewerken?
```

**Wacht op gebruikersinput. Ga NIET door totdat de gebruiker reageert.**

### Fase 4: Wijzigingen doorvoeren

1. Pas alleen goedgekeurde wijzigingen toe op `ROLE_FILE`.
2. **VERPLICHT** — Behoud intentie en scope van de oorspronkelijke rol.
3. **VERPLICHT** — Introduceer geen templatevariabelen (`GEN:`, `PRJ:`, `EXT:`, `SYS:`) in de rol.
4. **VERPLICHT** — Dupliceer geen projectregels uit `.claude/rules/`.
5. **VERPLICHT** — Behoud bestaande bestandsnaamconventie in `.ai/prompts/roles/` (Title Case met spaties en `.md`).

### Fase 5: Hercontrole

1. Evalueer de verbeterde rol opnieuw tegen A1-D4.
2. Toon alleen checks met gewijzigde status.

Toon:

```markdown
## Hercontrole: {bestandsnaam}

### Gewijzigde items

| # | Was | Nu | Toelichting |
|---|-----|----|-------------|
| {id} | issue | pass | {wat is opgelost} |

### Score
{X}/{totaal toepasselijk} checks passed (was: {Y}/{totaal toepasselijk})

### Totaalmatrix

| Status | Aantal |
|--------|--------|
| pass | {aantal pass} |
| issue | {aantal issue} |
| n.v.t. | {aantal n.v.t.} |

{Als alle checks pass of n.v.t.}: Alle checks passed - rol is klaar.
{Als nog issues}: Nog {N} openstaande issues.

Accepteren / Nog een ronde / Handmatig bewerken?
```

**Wacht op gebruikersinput. Ga NIET door totdat de gebruiker reageert.**

### Fase 6: Iteratie

1. Verwerk feedback van de gebruiker.
2. Pas wijzigingen toe op `ROLE_FILE`.
3. Herhaal Fase 5.
4. Stop wanneer de gebruiker accepteert of er geen open issues meer zijn.

## Stop Points

**VERPLICHT** — Stop en vraag de gebruiker bij:

- Type-detectie is ambigu (rol versus workflow prompt)
- `ROLE_FILE` staat buiten `.ai/prompts/roles/`
- Substantiële overlap met andere rol
- Misplaatsing-signaal: bestand lijkt beter te passen in `.ai/prompts/`
- Wijziging die fundamentele scope of intentie verandert
- Conflict tussen rol en `.claude/rules/`
- Voorstel dat projectregels dupliceert of overschrijft

Gebruik in elk stop point een keuzevraag als laatste non-empty regel.

## Terminatie

De taak is klaar wanneer:

- Het bestand volledig is gelezen
- Type-detectie is afgerond
- Alle checklist-items A1-D4 zijn geëvalueerd
- Hercontrole bevat een totaalmatrix (pass/issue/n.v.t.)
- Overlap-detectie is uitgevoerd
- Misplaatsing-signaal is beoordeeld
- Gebruiker wijzigingen heeft goedgekeurd of er geen issues zijn
- Het verbeterde bestand is opgeslagen naar `ROLE_FILE`

## Anti-patterns

| Vermijd | Doe in plaats daarvan |
|---------|----------------------|
| Checklist deels uitvoeren | Evalueer alle A-, B-, C- en D-checks |
| Overlap-detectie overslaan | Glob `.ai/prompts/roles/*.md` en vergelijk perspectief |
| Aannames over gebruikersvoorkeuren | Stop en vraag |
| Rol behandelen als workflow prompt zonder check | Doe eerst type-detectie |
| Projectregels in de rol herschrijven | Verwijs naar `.claude/rules/*` |
| Tekst na button-regel plaatsen | Button-regel is altijd de laatste non-empty regel |
