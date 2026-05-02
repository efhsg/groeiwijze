---
name: improve-prompt
description: Analyseer en verbeter prompt-bestanden in .ai/prompts/ op duidelijkheid, volledigheid en betrouwbaarheid
area: validation
provides:
  - prompt_improvement
depends_on: []
---

# Improve Prompt

Analyseer een prompt-bestand en pas gestructureerde verbeteringen toe terwijl de intentie van de auteur bewaard blijft.

## When to Use

- Gebruiker wil een bestaande prompt in `.ai/prompts/` verbeteren
- Gebruiker heeft een nieuwe prompt geschreven en wil die laten reviewen
- Gebruiker roept `/improve-prompt` aan

## Inputs

- `file`: Pad naar het prompt-bestand (verplicht). Als niet opgegeven, toon `.ai/prompts/*.md` en vraag.

## Outputs

- Analyserapport met pass/issue status per checklist-item
- Voorgestelde wijzigingen met uitleg
- Bewerkt bestand (na gebruikersgoedkeuring)

## Algorithm

### 1. Lees het prompt-bestand

**VERPLICHT** — Lees het doelbestand volledig vóór enige analyse. Als geen bestand is opgegeven, toon `.ai/prompts/*.md` en vraag welke.

### 2. Analyseer tegen de verbeterchecklist

**VERPLICHT** — Evalueer de prompt tegen elk item. Status per check: `pass` / `issue` / `n/a`.

### 3. Presenteer bevindingen

Toon een samenvatting van gevonden issues, gegroepeerd per categorie. Leg per issue uit wat er mis is en stel een fix voor.

### 4. Vraag om goedkeuring

Presenteer de lijst met voorgestelde wijzigingen. Sluit af met:

```
Apply all / Select subset / Manual edit?
```

**Wacht op gebruikersinput. Ga niet door totdat geantwoord.**

### 5. Pas wijzigingen toe

Bewerk het bestand met goedgekeurde verbeteringen.

## Verbeterchecklist

### A. Structuur & Duidelijkheid

| # | Check | Veelvoorkomend probleem |
|---|-------|------------------------|
| A1 | **Eén verantwoordelijkheid per fase** | Prompt probeert meerdere taken tegelijk te doen zonder duidelijke scheiding |
| A2 | **Verplichte stappen zijn gemarkeerd** | Stappen die Claude overslaat missen nadruk — markeer met **VERPLICHT** |
| A3 | **Stop-punten zijn expliciet** | Geen STOP-instructie waar gewacht moet worden — voeg "Wacht op gebruikersinput. Ga niet door totdat geantwoord." toe |
| A4 | **Actieopties zijn concreet** | Vage opties zoals "Ga verder". Gebruik slash-syntax als laatste regel: `Approve / Aanpassen?` |
| A5 | **Prioriteitsvolgorde is gedefinieerd** | Meerdere items zonder volgorde — voeg expliciete sortering toe |
| A6 | **Eindconditie is helder** | Geen gedefinieerde eindtoestand — voeg explicite stopconditie toe |

### B. Robuustheid

| # | Check | Veelvoorkomend probleem |
|---|-------|------------------------|
| B1 | **Geen dubbele inhoud** | Dezelfde instructie verschijnt meerdere keren — consolideer |
| B2 | **Bestandsreferenties zijn robuust** | Prompt verwijst naar bestanden die mogelijk niet bestaan — voeg "als aanwezig" toe |
| B3 | **Geheugen voor lange sessies** | Geen instructies voor context-compressie — voeg toe: werk bestanden bij vóór compressie, herleest bij hervatting |
| B4 | **Hervattingscapaciteit** | Geen manier om te hervatten na onderbreking — voeg status-bestand toe |

### C. Claude-gedrag

| # | Check | Veelvoorkomend probleem |
|---|-------|------------------------|
| C1 | **Code wordt gelezen vóór beoordeling** | Claude wordt gevraagd code te beoordelen zonder bronbestanden te lezen |
| C2 | **Uitvoerformaat is gespecificeerd** | Claude produceert ongestructureerde output — voeg sjabloon toe |
| C3 | **Analyse heeft criteria** | Claude wordt gevraagd te evalueren zonder rubric — voeg verdictalternatieven toe |

### D. Consistentie

| # | Check | Veelvoorkomend probleem |
|---|-------|------------------------|
| D1 | **Sectienaamgeving is consistent** | Secties gebruiken verschillende patronen — uitlijnen met bestaande prompts |
| D2 | **Taalinstructie aanwezig** | Prompt specificeert geen outputtaal — voeg toe als relevant |
| D3 | **Persona is gedefinieerd** | Geen duidelijke rol of persona — voeg toe |

## Output Format

```
## Prompt Analyse: {bestandsnaam}

### Samenvatting
{1-2 zinnen over algemene kwaliteit}

### Bevindingen

#### {Categorie A/B/C/D}: {Naam}

| # | Status | Bevinding | Voorstel |
|---|--------|-----------|---------|
| {id} | issue | {issue} | {voorgestelde fix} |
| {id} | pass | {doorstaan} | — |

### Voorgestelde Wijzigingen

1. {Concrete wijziging 1}
2. {Concrete wijziging 2}
...
```

## Stop Points

**VERPLICHT** — Stop en vraag de gebruiker wanneer:

- Doelbestand bestaat niet — toon `.ai/prompts/*.md`, vraag welke
- Stap 4 goedkeuringspoort — gebruiker heeft nog niet gekozen; pas geen bewerkingen toe
- Voorgestelde wijziging verwijdert of hernoemt een sjabloonsectie fundamenteel — bevestig met gebruiker

## Definition of Done

- Prompt-bestand volledig gelezen en geanalyseerd tegen de checklist
- Elk toepasselijk item heeft een status (pass / issue)
- Voorgestelde wijzigingen gepresenteerd vóór toepassing
- Gebruiker heeft goedkeuring gegeven vóór bewerkingen
- Verbeterd bestand geschreven alleen na goedkeuring
