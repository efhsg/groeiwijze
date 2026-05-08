---
name: improve-role
description: Analyseer en verbeter rol-persona's in .ai/prompts/roles/ op helderheid, scope en consistentie
area: validation
provides:
  - role_improvement
depends_on: []
---

# Improve Role

Analyseer een rol-persona in `.ai/prompts/roles/` en pas gestructureerde verbeteringen toe terwijl de intentie van de auteur en de Groeiwijze-conventies behouden blijven.

## Persona

Prompt engineer gespecialiseerd in rol-persona's. Begrijpt het verschil tussen een rol als perspectief en een workflow prompt als stappenplan. Houdt rollen compact door gedeelde projectregels aan `.claude/rules/` over te laten.

## When to Use

- Gebruiker wil een bestaande rol in `.ai/prompts/roles/` verbeteren
- Gebruiker heeft een nieuwe rol geschreven en wil die laten reviewen
- Gebruiker roept `/improve-role` aan

## Inputs

- `file`: pad naar het rolbestand. Als dit ontbreekt, toon `.ai/prompts/roles/*.md` en vraag welk bestand verbeterd moet worden.

## Outputs

- Analyserapport met pass/issue/n.v.t.-status per checklist-item
- Voorgestelde wijzigingen met uitleg
- Bewerkt rolbestand na gebruikersgoedkeuring

## Scope: Alleen Rollen

Deze skill is alleen bedoeld voor rolbestanden onder `.ai/prompts/roles/`.

| Aspect | Rol | Workflow prompt |
|--------|-----|-----------------|
| Doel | Activeert een perspectief of persona | Stuurt een meerstapstaak |
| Structuur | Focus, denkmodel, principes | Fases, stop points, outputs |
| Inputvariabelen | Geen | Templatevariabelen zoals `GEN:` of `PRJ:` |
| Lengte | Compact | Mag langer zijn |
| Referentiestijl | Verwijst naar `.claude/rules/` | Mag procedurele details bevatten |

**Geen templatevariabelen.** Rollen gebruiken geen `GEN:`, `PRJ:`, `EXT:` of `SYS:` placeholders. Als een rolbestand zulke variabelen bevat, flag dit. Het bestand is waarschijnlijk een workflow prompt en hoort bij `/improve-prompt`.

## Algorithm

### 1. Lees het rolbestand

**VERPLICHT** — Lees het doelbestand volledig vóór analyse. Als geen bestand is opgegeven, toon `.ai/prompts/roles/*.md` en vraag welk bestand verbeterd moet worden.

### 2. Lees sibling roles

**VERPLICHT** — Glob `.ai/prompts/roles/*.md` en scan naastliggende rollen op overlap, naamconventies en structurele afwijkingen.

### 3. Analyseer tegen de checklist

**VERPLICHT** — Evalueer de rol tegen elk checklist-item. Gebruik per item exact één status: `pass`, `issue` of `n.v.t.`.

### 4. Presenteer bevindingen

Toon een samenvatting van issues, gegroepeerd per categorie. Leg per issue uit wat misgaat en stel een concrete fix voor.

### 5. Vraag goedkeuring

Presenteer de voorgestelde wijzigingen. Eindig met:

```text
Alle wijzigingen doorvoeren / Selectie doorvoeren / Handmatig bewerken?
```

**Wacht op gebruikersinput. Ga niet door totdat geantwoord.**

### 6. Pas wijzigingen toe

Bewerk alleen het rolbestand met goedgekeurde verbeteringen. Behoud de oorspronkelijke intentie, scope en rolgrens.

### 7. Hercontrole

Evalueer het aangepaste bestand opnieuw tegen de volledige checklist. Rapporteer alleen gewijzigde statussen en resterende issues.

## Improvement Checklist

### A. Persona & Scope

| # | Check | Veelvoorkomend probleem |
|---|-------|-------------------------|
| A1 | **Persona-opening aanwezig** | Bestand mist `# Rol` en een contextregel zoals "Je bent een X voor Groeiwijze". Voeg die toe. |
| A2 | **Eén perspectief** | Rol mengt verantwoordelijkheden, bijvoorbeeld reviewer, tester en architect. Splits of versmal. |
| A3 | **Verwijst naar `.claude/rules/`** | Rol dupliceert projectregels. Vervang duplicatie door een korte verwijzing naar de relevante rule. |
| A4 | **Onderscheidend van sibling roles** | Rol overlapt sterk met een andere rol. Verscherp de grens of vraag om consolidatie. |
| A5 | **Geen workflow drift** | Rol bevat fases, stop points of outputtemplates die beter passen in `.ai/prompts/`. Verplaats of verwijder die. Uitzondering: rollen waarvan het kernproduct procedureel is, mogen beperkte procedurele structuur bevatten. |
| A6 | **Geen templatevariabelen** | Rol bevat `GEN:`, `PRJ:`, `EXT:` of `SYS:` placeholders. Vraag of dit eigenlijk een workflow prompt is. |

### B. Structuur & Conventie

| # | Check | Veelvoorkomend probleem |
|---|-------|-------------------------|
| B1 | **Focussectie aanwezig** | `## Jouw focus` of `## Focus` ontbreekt. Voeg 3-5 specifieke focuspunten toe. |
| B2 | **Denkmodeltabel aanwezig** | `## Hoe je denkt` of `## Denkmodel` ontbreekt. Voeg een tabel met 3-5 domeinvragen toe. |
| B3 | **`## Principes` als blockquotes** | Principes ontbreken of staan als bullets. Gebruik `>` blockquotes, één principe per quote. |
| B4 | **Sectievolgorde volgt conventie** | Secties staan in afwijkende volgorde. Gebruik: persona-opening, focus, denkmodel, principes, optionele randgevallen. |
| B5 | **Geen onnodige accolades** | Proza staat in code-achtige `{...}`-blokken. Verwijder die. |

### C. Concreetheid

| # | Check | Veelvoorkomend probleem |
|---|-------|-------------------------|
| C1 | **Focuspunten zijn specifiek** | Bullets zijn te algemeen, zoals "kwaliteit" of "duidelijkheid". Voeg een concrete toelichting toe. |
| C2 | **Denkmodel gebruikt Groeiwijze-voorbeelden** | Voorbeelden zijn generiek. Gebruik passende voorbeelden uit de site, intake-flow, contenttoon of bezoekerscontext. |
| C3 | **Principes zijn toetsbare heuristieken** | Principes zijn slogans. Herschrijf ze als concrete beslisregels. |
| C4 | **Referenties bestaan echt** | Verwijzingen naar `.claude/rules/*`, `.claude/skills/*` of `.claude/codebase_analysis.md` bestaan niet. Verifieer paden. |

### D. Consistentie

| # | Check | Veelvoorkomend probleem |
|---|-------|-------------------------|
| D1 | **Taal is consistent** | Body mixt Nederlands en Engels zonder reden. Gebruik Nederlands; code-termen mogen Engels blijven. |
| D2 | **Terminologie sluit aan op `CLAUDE.md`** | Rol gebruikt afwijkende domeintermen. Stem af op de canonieke termen uit `CLAUDE.md` en `.claude/config/project.md`. |
| D3 | **Heading levels zijn consistent** | Topsecties gebruiken `###` in plaats van `##`. Standaardiseer topsecties naar `##`. |
| D4 | **Gesloten keuze gebruikt custom-buttons syntax** | Als de rol eindigt met een keuzevraag, moet die voldoen aan `.claude/skills/custom-buttons.md`. |

## Output Format

```markdown
## Rol Analyse: {bestandsnaam}

### Samenvatting
{1-2 zinnen over fit-for-purpose}

### Bevindingen

#### {Categorie A/B/C/D}: {naam}

| # | Status | Bevinding | Voorstel |
|---|--------|-----------|----------|
| {id} | issue | {issue} | {voorgestelde fix} |
| {id} | pass | {doorstaan} | — |

### Overlap
{geen overlap of lijst met overlappende rollen}

### Voorgestelde wijzigingen

1. {Concrete wijziging 1}
2. {Concrete wijziging 2}

### Score
{X}/{totaal toepasselijk} checks passed

Alle wijzigingen doorvoeren / Selectie doorvoeren / Handmatig bewerken?
```

## Stop Points

**VERPLICHT** — Stop en vraag de gebruiker wanneer:

- Doelbestand ontbreekt. Toon `.ai/prompts/roles/*.md` en vraag welk bestand verbeterd moet worden.
- Doelbestand staat buiten `.ai/prompts/roles/`. Bevestig scope en suggereer `/improve-prompt` bij workflow prompts.
- Bestand bevat templatevariabelen zoals `GEN:`, `PRJ:`, `EXT:` of `SYS:`.
- Substantiële overlap met een sibling role is gevonden.
- Stap 5 is bereikt en de gebruiker heeft nog niet gekozen.
- Een voorgestelde wijziging verwijdert een sectie waar een andere rol via `## Zie ook` naar verwijst.
- Een voorgestelde wijziging verandert de fundamentele scope of intentie van de rol.

Gebruik bij stop points een custom-buttons-regel als laatste non-empty regel.

## Definition of Done

- Rolbestand is volledig gelezen
- Sibling roles in `.ai/prompts/roles/` zijn gescand op overlap
- Elk toepasselijk checklist-item heeft een status
- Voorgestelde wijzigingen zijn gepresenteerd vóór toepassing
- Gebruiker heeft wijzigingen goedgekeurd vóór bewerking
- Geen templatevariabelen geïntroduceerd
- Rol verwijst naar `.claude/rules/` voor gedeelde regels en dupliceert ze niet
- Verbeterd bestand is geschreven na goedkeuring
- Hercontrole toont geen nieuwe regressies

## Zie ook

- `.claude/skills/improve-prompt.md` — equivalente skill voor workflow prompts onder `.ai/prompts/`
- `.claude/skills/custom-buttons.md` — syntax voor keuzevragen
- `.ai/prompts/roles/` — bestaande rolcorpus voor structuurconventies
