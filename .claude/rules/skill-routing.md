# Skill Routing

Laad automatisch de relevante skill op basis van het bestandstype of onderwerp.

## Bestandspatroon routing

| Bestand | Laad |
|---------|------|
| `website/*.html` | `rules/html-css.md` + `rules/accessibility.md` + `rules/content.md` |
| `website/css/*.css` | `rules/html-css.md` + `rules/colors.md` |
| `website/js/*.js` | `rules/html-css.md` |
| `website/*.php` | `rules/security.md` |
| `website/assets/img/*` | `rules/accessibility.md` (alt-tekst, optimalisatie) |
| `.ai/features/**/*.md` | `rules/workflow.md` (feature directory conventies) |
| `.ai/prompts/*.md` | `skills/improve-prompt.md` |
| `.claude/skills/**/*.md` | `skills/optimize-skill.md` + `rules/writing-standards.md` |
| `.claude/rules/*.md` | `rules/writing-standards.md` |

## Topic routing

Topic routing is gedefinieerd in `.claude/skills/index.md` — één gezaghebbende bron. Raadpleeg die tabel voor onderwerp-naar-skill mapping.

## Gebruik

1. Bepaal welke bestanden of onderwerpen relevant zijn voor de taak
2. Voor bestanden: gebruik de tabel hierboven. Voor onderwerpen: zie `skills/index.md`
3. Laad alleen wat nodig is — niet alles tegelijk
