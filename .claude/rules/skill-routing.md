# Skill Routing

Laad automatisch de relevante skill op basis van het bestandstype of onderwerp.

## Bestandspatroon routing

| Bestand | Laad |
|---------|------|
| `website/*.html` | `rules/html-css.md` + `rules/accessibility.md` + `rules/content.md` |
| `website/css/*.css` | `rules/html-css.md` + `rules/colors.md` |
| `website/js/*.js` | `rules/html-css.md` |
| `website/*.php` | `rules/security.md` + `rules/html-css.md` + `rules/accessibility.md` + `rules/content.md` als het bestand HTML output bevat |
| `website/assets/img/*` | `rules/accessibility.md` (alt-tekst, optimalisatie) |
| `.ai/features/**/spec.md` | `skills/validate-spec.md` + `rules/workflow.md` |
| `.ai/features/**/todos.md` | `rules/workflow.md` (gezaghebbende hervattingschecklist) |
| `.ai/features/**/*.md` | `rules/workflow.md` (feature directory conventies) |
| `.ai/prompts/**/*.md` | `skills/improve-prompt.md` |
| `.claude/skills/**/*.md` | `skills/optimize-skill.md` (structureel) of `skills/evaluate-skill.md` (semantisch, read-only) + `rules/writing-standards.md` |
| `.claude/rules/*.md` | `rules/writing-standards.md` |
| `.claude/commands/*.md` | `rules/writing-standards.md` (commands zijn dunne wrappers — wijzig hier zelden, contract staat in `skills/`) |
| `.claude/config/*.md` | `rules/writing-standards.md` |
| `.claude/design/**/*.md` | `rules/writing-standards.md` |
| `.claude/plans/**/*.md` | `rules/writing-standards.md` |
| `.claude/templates/*.md` | `rules/writing-standards.md` |
| `.claude/settings*.json` | `rules/writing-standards.md` + `commands/audit-config.md` |
| `.claude/codebase_analysis.md` | `commands/analyze-codebase.md` (regenereren via `/analyze-codebase`) |
| `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` / `RULES.md` | `rules/writing-standards.md` + `commands/audit-config.md` (consistentie-check via `/audit-config`) |
| `docker-compose.yml` / `docker/**/Dockerfile` / `docker/**/*.{conf,sh,json}` | `rules/security.md` + `rules/writing-standards.md` voor documentatie-impact |
| `.env.example` | `rules/security.md` |
| `.gitignore` | `rules/security.md` bij credentials/logs/private paths |
| `*.sh` | `rules/security.md` bij deployment/dev server impact |

## Topic routing

Topic routing is gedefinieerd in `.claude/skills/index.md` — één gezaghebbende bron. Raadpleeg die tabel voor onderwerp-naar-skill mapping.

## Gebruik

1. Bepaal welke bestanden of onderwerpen relevant zijn voor de taak
2. Voor bestanden: gebruik de tabel hierboven. Voor onderwerpen: zie `skills/index.md`
3. Laad alleen wat nodig is — niet alles tegelijk
