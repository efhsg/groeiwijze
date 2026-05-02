# Codebase Analysis — groeiwijze.nl

Snel oriëntatiepunt voor nieuwe sessies. Lees dit vóór je broncode induikt.

## Wat is dit project?

Statische marketing-website voor een therapie- en coachingpraktijk in Lansingerland. Gericht op stress-sensitieve bezoekers. Eén ontwikkelaar. Geen framework, geen build-stap, geen database.

## Tech stack

| Laag | Technologie |
|------|-------------|
| HTML | HTML5, semantisch, `lang="nl"` |
| CSS | CSS3 met custom properties (design tokens), BEM naamgeving, mobile-first |
| JS | Vanilla ES6, minimaal (alleen mobiele nav toggle) |
| Fonts | Google Fonts — Libre Franklin (400/500/600/700) |
| Backend | PHP 8+ — alleen contactformulier (PHPMailer via Composer) |
| Server | Nginx (Docker) of Apache (hosting) |
| Dev | browser-sync + Tailscale via `dev-reload.sh` |

## Bestandsstructuur

```
website/                    # Site root — dit wordt gedeployed
├── index.html              # Home
├── over-mij.html           # Over mij / praktijk
├── werkwijze.html          # Hoe werkt een traject?
├── aanbod.html             # Aanbod overzicht (grootste pagina)
├── herstelroute.html       # Specifiek traject
├── tarieven.html           # Tarieven
├── veelgestelde-vragen.html# FAQ
├── visie.html              # Visie van de praktijk
├── verwijzers.html         # Voor verwijzers (huisartsen e.d.)
├── contact.html            # Contactformulier
├── thank-you.html          # Bedankpagina (noindex)
├── privacy.html            # Privacybeleid
├── contact-submit.php      # Formulier backend
├── css/style.css           # Enige stylesheet — bevat design system
├── js/main.js              # Minimale JS (mobile nav toggle)
└── assets/img/             # Afbeeldingen en favicon

.ai/prompts/                # Herbruikbare AI-prompts
.claude/                    # AI-harnassing
docker/                     # Docker config (Nginx, PHP-FPM, Supervisor)
private/                    # SMTP credentials (buiten document root)
_archive/                   # Oude design-iteraties
```

## Design system (style.css)

Alles staat in één stylesheet. Structuur:

1. **Design tokens** — CSS custom properties: kleuren, spacing, typography
2. **Reset & base** — body, box-sizing, links
3. **Typography** — Libre Franklin, clamp() sizing
4. **Layout** — container (max 1100px), narrow container (max 720px)
5. **Components** — header, hero, buttons, cards, sections, footer, forms
6. **Page-specific** — overrides per pagina
7. **Responsive** — breakpoints: 480px, 768px, 769px, 1024px

## Kleurenpalet (Duin Harmonie)

| Token | Hex | Gebruik |
|-------|-----|---------|
| `--color-groen` | `#8DA382` | Primaire brand kleur |
| `--color-groen-dark` | `#6B8560` | Hover states, accenten |
| `--color-zand` | `#A68B77` | Warm accent |
| `--color-blauw` | `#7A91A1` | Koele accent |
| `--color-text` | `#3E4444` | Lopende tekst |
| `--color-muted` | `#5E7585` | Secundaire tekst |
| `--color-bg-warm` | `#F8F6F2` | Warme achtergrond |
| `--color-bg-soft` | `#F4F2EE` | Zachte achtergrond |
| `--color-border` | `#E8E6E2` | Borders |

## Contactformulier (contact-submit.php)

Anti-spam bescherming:
- Honeypot-veld (verborgen inputveld)
- Tijdcheck (min. 3 seconden)
- IP rate limiting (max 5/uur)
- Input sanitization

Backend: PHPMailer via Composer. Credentials in `private/contact-mail.config.php` (buiten document root).

## Pagina-flow

```
index.html (home)
  ├── over-mij.html
  ├── aanbod.html
  │   └── herstelroute.html
  ├── werkwijze.html
  ├── tarieven.html
  ├── veelgestelde-vragen.html
  ├── visie.html
  ├── verwijzers.html
  └── contact.html → contact-submit.php → thank-you.html
```

## Wat hier NIET is

- Geen database
- Geen sessies of authenticatie
- Geen build-systeem (geen webpack, vite, sass)
- Geen test-framework
- Geen JavaScript-framework
- Geen CMS
