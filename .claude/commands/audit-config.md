---
allowed-tools: Bash(ls:*), Bash(cat:*), Bash(grep:*), Read, Grep, Glob
description: Audit alle Claude-configuratiebestanden op volledigheid, correctheid en consistentie
---

# Configuration Audit

Audit alle Claude Code configuratiebestanden voor dit project.

## Bestanden om te auditen

### Hoofdconfiguratie
@CLAUDE.md

### Project Config
@.claude/config/project.md

### Rules
@.claude/rules/colors.md
@.claude/rules/html-css.md
@.claude/rules/content.md
@.claude/rules/accessibility.md
@.claude/rules/security.md
@.claude/rules/skill-routing.md
@.claude/rules/workflow.md
@.claude/rules/response-format.md
@.claude/rules/writing-standards.md

### Skills Index
@.claude/skills/index.md

### Andere AI-configuraties
@AGENTS.md
@GEMINI.md

## Commands lijst
!`ls -1 .claude/commands/*.md 2>/dev/null | xargs -I {} basename {}`

## Skills lijst
!`ls -1 .claude/skills/*.md 2>/dev/null | xargs -I {} basename {}`

## Pagina's
!`ls -1 website/*.html 2>/dev/null | xargs -I {} basename {}`

---

## Audit instructies

Voer een uitgebreide audit uit:

### 1. Volledigheid

- Zijn alle pagina's en componenten gedekt door de rules?
- Zijn alle commands opgenomen in `skills/index.md`?
- Zijn alle skills opgenomen in `skills/index.md`?
- Zijn alle skills in `index.md` ook aanwezig als bestand?
- Zijn alle commands ook gelinkt aan een bestaande skill?
- Ontbreken er patronen of conventies die in de code voorkomen maar niet in de rules?

### 2. Correctheid

- Kloppen gedocumenteerde paden met de werkelijke bestandslocaties?
- Zijn de voorbeeldcommands in `config/project.md` nog correct?
- Zijn er deprecated patronen die nog gedocumenteerd zijn?
- Klopt de `codebase_analysis.md` nog met de werkelijke bestandsstructuur?

### 3. Duplicaten & Conflicten

- Dezelfde regel op meerdere plaatsen met andere formulering?
- Tegenstrijdige instructies tussen `CLAUDE.md` en rule-bestanden?
- Overlappende verantwoordelijkheden tussen skills?

### 4. AGENTS.md & GEMINI.md Uitlijning

- Verwijzen beide naar `CLAUDE.md` als single source of truth?
- Geen aanvullende regels die `CLAUDE.md` tegenspreken?

### 5. Skill-routing Volledigheid

- Zijn alle bestandspatronen in `skill-routing.md` gedekt?
- Zijn alle onderwerpen in topic routing gedekt?
- Ontbreken er routeringsregels voor bestaande skills?

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

Na het rapport: vraag welke issues opgelost moeten worden.

## Task

$ARGUMENTS
