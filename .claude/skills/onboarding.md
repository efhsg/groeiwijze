# Onboarding

Snelle start voor nieuwe sessies.

## Project Overview

**groeiwijze.nl** is een statische marketing-website voor een therapie- en coachingpraktijk in Lansingerland.

**Tech Stack:**
- HTML5 + CSS3 + Vanilla JS (geen build system)
- PHP 8+ (alleen contactformulier, PHPMailer)
- Geen database, geen framework, geen test runner

**Doelgroep:** Stress-sensitieve mensen — warm, nuchter, niet-medisch

## Bestandsstructuur

```
website/          # Site root
├── *.html        # Pagina's (index, over-mij, werkwijze, tarieven, ...)
├── css/style.css # Enige stylesheet — design system + alle stijlen
├── js/main.js    # Minimaal JS (mobiele nav toggle)
├── contact-submit.php  # Formulier backend
└── assets/img/   # Afbeeldingen en favicon
.ai/prompts/      # Herbruikbare AI-prompts
.ai/features/     # Feature-specs (.ai/features/{naam}/spec.md)
.claude/          # AI-harnassing
```

## Key Files

| Doel | Bestand |
|------|---------|
| AI-instructies | `CLAUDE.md` |
| Kleurenpalet | `.claude/rules/colors.md` |
| HTML/CSS conventies | `.claude/rules/html-css.md` |
| Content toon | `.claude/rules/content.md` |
| Toegankelijkheid | `.claude/rules/accessibility.md` |
| Security (PHP) | `.claude/rules/security.md` |
| Skills overzicht | `.claude/skills/index.md` |

## Development Server

```bash
# Simpel (geen PHP):
cd website/ && python3 -m http.server 8000

# Met live reload (Docker + Tailscale):
bash dev-reload.sh
```

## Beschikbare Slash Commands

| Command | Doel |
|---------|------|
| `/review-changes` | Structured review voor commit |
| `/finalize-changes` | Review checklist + commitbericht |
| `/improve-prompt` | Verbeter een prompt in `.ai/prompts/` |
| `/triage-review` | Externe review kritisch beoordelen |
| `/onboarding` | Dit overzicht |

## Next Steps

1. Check git status: `git status`
2. Lees de relevante rule voor je taak uit `.claude/rules/`
3. Zie `.claude/skills/index.md` voor topic routing
