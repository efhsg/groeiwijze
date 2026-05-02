# AGENTS.md

Dit project gebruikt `CLAUDE.md` als single source of truth voor alle AI-agents.

## Instructies

1. **Lees eerst [`CLAUDE.md`](CLAUDE.md)** — bevat role, project overview, behavioral guidelines en definition of done
2. **Lees `.claude/rules/`** voordat je code wijzigt — zie de rules-tabel in CLAUDE.md
3. **Lees `.claude/config/project.md`** voor bestandsstructuur, versioning en dev server
4. **Scan `.claude/skills/index.md`** als je onderwerp gerelateerd is aan intake-flow of site-structuur

## Rules (doorverwijzing)

| Bestand | Onderwerp |
|---------|-----------|
| `.claude/rules/colors.md` | Duin Harmonie kleurenpalet, CSS variabelen |
| `.claude/rules/html-css.md` | BEM, responsive, page template, typography |
| `.claude/rules/content.md` | Toon, taal, copy-richtlijnen |
| `.claude/rules/accessibility.md` | WCAG 2.1 AA minimale eisen |
| `.claude/rules/security.md` | PHP contactformulier, input validatie, credentials |
| `.claude/rules/skill-routing.md` | Automatisch de juiste skill laden op bestandspatroon of onderwerp |
| `.claude/rules/workflow.md` | Commit conventies, design directory, review checklist |
| `.claude/rules/response-format.md` | Gesloten vragen als klikbare buttons (custom-buttons syntax) |
| `.claude/rules/writing-standards.md` | Documentatie schrijfstijl voor rules en skills |

## Prioriteit

`rules/` > `CLAUDE.md` > `skills/`

## Samenvatting project

- Statische marketing-website (HTML5, CSS3, vanilla JS) met PHP form handler. Geen build system
- Website bestanden staan in `website/`
- Doelgroep: stress-sensitieve mensen die therapie/coaching zoeken
- Toon: warm, nuchter, niet-medisch
- Lokale dev server: `python3 -m http.server 8000` vanuit `website/`
