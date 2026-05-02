---
name: audit-config
description: Audit Claude-configuratiebestanden op volledigheid, correctheid en consistentie
area: validation
provides:
  - configuration_audit
depends_on:
  - rules/writing-standards.md
  - rules/skill-routing.md
---

# Audit Config

Controleer de Claude-harnassing tegen de werkelijke repository. Maak geen wijzigingen; rapporteer gaps met concrete bestand:regel-verwijzingen.

## When to Use

- Gebruiker roept `/audit-config` aan
- Na wijziging aan `.claude/rules/`, `.claude/skills/`, `.claude/commands/`, `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` of `RULES.md`
- Wanneer commands, skills of routing niet meer consistent lijken

## Inputs

- `scope` (optioneel) — specifiek configuratiegebied om te auditen

## Algorithm

1. Lees `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `RULES.md`, `.claude/config/project.md` en alle `.claude/rules/*.md`.
2. Scan recursief:
   - `.claude/commands/**/*.md`
   - `.claude/skills/**/*.md`
   - `.claude/templates/**/*.md`
   - `.claude/settings*.json`
   - `.ai/features/**/*.md`
   - `.ai/prompts/**/*.md`
   - `website/**/*`
   - Docker/config-bestanden die in projectdocumentatie genoemd worden.
3. Vergelijk:
   - Elke command staat in `.claude/skills/index.md`
   - Elke command verwijst naar een bestaand skill-contract
   - Elke skill in `index.md` bestaat als bestand
   - Elke bestaande skill staat in `index.md`
   - Bestandspatronen en topics zijn gedekt in routing
   - Gedocumenteerde paden en voorbeeldcommands kloppen met de repo
   - `codebase_analysis.md` klopt met de actuele structuur
   - `AGENTS.md` en `GEMINI.md` verwijzen naar `CLAUDE.md` als single source of truth
4. Classificeer issues als Kritiek, Waarschuwing of Info.

## Output Format

```markdown
# Configuration Audit Report

## Samenvatting
- Totaal gevonden issues: X
- Kritiek: X | Waarschuwing: X | Info: X

## Volledigheidsissues
- [ ] Beschrijving — bestand:locatie

## Correctheidsissues
- [ ] Beschrijving — bestand:locatie

## Duplicaten & Conflicten
- [ ] Beschrijving — betrokken bestanden

## AGENTS.md / GEMINI.md Issues
- [ ] Beschrijving

## Skill-routing Issues
- [ ] Beschrijving

## Aanbevelingen
1. Prioriteitsfix: ...
2. ...
```

Sluit af met een klikbare keuze als vervolgactie nodig is.

## Definition of Done

- Alle configuratiebronnen zijn gelezen
- Discovery is recursief waar subdirectories bestaan
- Elk issue heeft categorie, severity en locatie
- Geen bestanden gewijzigd
