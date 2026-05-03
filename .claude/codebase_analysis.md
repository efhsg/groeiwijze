# Codebase Analysis — groeiwijze.nl

Snel orientatiepunt voor nieuwe sessies. Lees dit voordat je broncode of configuratie wijzigt.

## Project Overview

Groeiwijze.nl is een statische marketingwebsite voor een therapie- en coachingpraktijk in Lansingerland. De site is gericht op stress-sensitieve bezoekers die begeleiding zoeken na emotioneel uitputtende relaties en bij herstel van regie.

De toon is warm, nuchter en niet-medisch. De site gebruikt geen framework, geen CMS, geen database en geen front-end build-stap. Het enige dynamische deel is het PHP-contactformulier.

## Tech Stack

| Laag | Technologie | Actuele observatie |
|------|-------------|--------------------|
| HTML | HTML5 | 12 pagina's, `lang="nl"`, skip-link en `<main id="main">` op alle pagina's |
| CSS | CSS3 | 1 stylesheet, 1127 regels, custom properties, BEM, mobile-first |
| JavaScript | Vanilla ES6 | 1 bestand, 37 regels, alleen mobiele navigatie toggle |
| Fonts | Google Fonts | Libre Franklin 400/500/600/700 |
| Backend | PHP | 1 form handler in `website/contact-submit.php` |
| Mail | PHPMailer | Docker installeert via `docker/groeiwijze/composer.json`; hosting verwacht `../vendor/autoload.php` |
| Docker | PHP 8.2 FPM + Nginx + Supervisor | `docker-compose.yml` publiceert container op `8001:80` |
| Dev preview | browser-sync + Tailscale | `dev-reload.sh` serveert statisch; PHP werkt daar niet |

## Bestandsstructuur

```text
website/
├── index.html
├── aanbod.html
├── visie.html
├── over-mij.html
├── werkwijze.html
├── herstelroute.html
├── tarieven.html
├── verwijzers.html
├── veelgestelde-vragen.html
├── contact.html
├── thank-you.html
├── privacy.html
├── contact-submit.php
├── css/
│   └── style.css
├── js/
│   └── main.js
└── assets/img/
    ├── favicon.svg
    ├── favicon_bu.svg
    ├── logo2.svg
    ├── logo2_bu.svg
    └── nicky.png

.claude/
├── commands/               # Slash-command wrappers
├── config/project.md
├── design/live-reload-setup.md
├── plans/
├── rules/                  # Gezaghebbende projectregels
├── settings.json           # Gedeelde Claude Code permissies
├── settings.local.json     # Lokale overrides, gitignored
├── skills/                 # Skill-contracten + registry
└── templates/feature-spec.md

.ai/
├── features/               # Feature specs
└── prompts/
    └── roles/              # Rolprompt-fragmenten

docker/groeiwijze/
├── Dockerfile
├── composer.json
├── contact-submit.php
├── entrypoint.sh
├── generate-config.sh
├── nginx.conf
└── supervisord.conf
```

## Bestandsaantallen

| Type | Aantal |
|------|--------|
| HTML-pagina's | 12 |
| CSS-bestanden | 1 |
| JS-bestanden | 1 |
| PHP-bestanden in `website/` | 1 |
| Afbeeldingen/assets | 5 |
| Claude commands | 18 |
| Claude skills | 21 plus `skills/index.md` |
| Feature specs | 3 |
| Prompt-bestanden | 9 top-level + 9 rolprompts |

## Pagina-flow

```text
index.html
├── over-mij.html
├── aanbod.html
│   └── herstelroute.html
├── werkwijze.html
├── tarieven.html
├── veelgestelde-vragen.html
├── visie.html
├── verwijzers.html
└── contact.html
    └── contact-submit.php
        └── thank-you.html
```

Alle HTML-pagina's delen dezelfde globale navigatie, footer, stylesheet `css/style.css?v=5`, skip-link en `<main id="main">`.

## Design System

Alles staat in `website/css/style.css`.

### CSS structuur

1. Design tokens
2. Reset & base
3. Focus indicators en skip-link
4. Typography
5. Layout
6. Header en navigatie
7. Hero en contentcomponenten
8. Buttons, cards, forms, footer
9. Utilities
10. Responsive en reduced motion

### Color tokens

| Token | Waarde | Gebruik |
|-------|--------|---------|
| `--color-groen` | `#8da382` | Primaire brandkleur |
| `--color-groen-dark` | `#6b8560` | Hover states, focus, accenten |
| `--color-zand` | `#a68b77` | Warm accent |
| `--color-blauw` | `#7a91a1` | Koel accent |
| `--color-text` | `#3e4444` | Lopende tekst |
| `--color-muted` | `#5e7585` | Secundaire tekst |
| `--color-white` | `#ffffff` | Witte achtergrond/tekst |
| `--color-bg-warm` | `#f8f6f2` | Warme achtergrond |
| `--color-bg-soft` | `#f4f2ee` | Zachte achtergrond |
| `--color-border` | `#e8e6e2` | Subtiele borders |
| `--color-border-strong` | `#dcd9d3` | Sterkere neutrale border |
| `--color-error` | `#c53030` | Formulierfouten |
| `--color-error-bg` | `#fff5f5` | Achtergrond bij formulierfouten |

### Spacing tokens

| Token | Waarde |
|-------|--------|
| `--space-xs` | `0.5rem` |
| `--space-sm` | `1rem` |
| `--space-md` | `1.5rem` |
| `--space-lg` | `2rem` |
| `--space-xl` | `3rem` |
| `--space-xxl` | `5rem` |

### Typography

- Font family: `Libre Franklin`, met system fallback
- Basisgrootte: `1.0625rem`
- Responsieve headings via `clamp()`
- Line height: `1.7` voor body, `1.2` voor headings

### Breakpoints

| Breakpoint | Gebruik |
|------------|---------|
| `480px` | Kleine mobiele correcties |
| `768px` | Mobiele layouts en contentspacing |
| `769px` | Desktop grid start |
| `1024px` | Navigatie-omslag en tabletcorrecties |

### Componentblokken

Belangrijkste CSS-blokken:

- Frame: `.skip-link`, `.header`, `.logo`, `.nav`, `.nav-toggle`, `.footer`
- Layout: `.container`, `.section`, `.hero`, `.profile`
- Content: `.card`, `.feature-list`, `.quote-list`, `.phases`, `.read-more`, `.pricing-table`
- Formulieren: `.form__group`, `.form__label`, `.form__input`, `.form__textarea`, `.form__error`
- Utilities: `.lead`, `.text-center`, `.text-muted`, `.mt-*`, `.mb-*`, `.sr-only`

## JavaScript

`website/js/main.js` bevat alleen navigatiegedrag:

- opent/sluit `.nav` via `.nav--open`
- synchroniseert `aria-expanded`
- sluit menu bij klik op een navigatielink
- sluit menu bij klik buiten navigatie

Er zijn geen externe JS dependencies.

## Contactformulier Backend

Het formulier in `website/contact.html` verzendt naar `website/contact-submit.php` via POST.

### Zichtbare beschermingen

| Bescherming | Implementatie |
|-------------|---------------|
| Honeypot | verborgen veld `website`; ingevuld betekent stille redirect |
| Tijdcheck | hidden `form_started_at`; minimaal 3 seconden |
| Rate limiting | hash van IP + salt, maximaal 5 submissions per uur |
| Server-side validatie | naam, e-mail, telefoon en bericht worden server-side gecontroleerd |
| Sanitization | `sanitizeInput()`, `filter_var()`, header-injection check |
| Geen inline credentials | config buiten document root |

### Runtime paden

| Context | Config | Autoload |
|---------|--------|----------|
| Hosting | `dirname($_SERVER['DOCUMENT_ROOT']) . '/private/contact-mail.config.php'` | `dirname(__DIR__) . '/vendor/autoload.php'` |
| Docker | `/var/www/private/contact-mail.config.php` | `/var/www/vendor/autoload.php` |

Docker genereert de mailconfig vanuit environment variables met `docker/groeiwijze/generate-config.sh`.

## AI-Harnassing

`CLAUDE.md` is de single source of truth. `AGENTS.md`, `GEMINI.md` en `RULES.md` verwijzen daarnaar.

### Rules

| Bestand | Onderwerp |
|---------|-----------|
| `colors.md` | Duin Harmonie palet en CSS tokens |
| `html-css.md` | BEM, page template, responsive, componentblokken |
| `content.md` | Nederlandse toon, niet-medisch, rustige CTA's |
| `accessibility.md` | WCAG 2.1 AA basics |
| `security.md` | PHP contactformulier en credentials |
| `skill-routing.md` | Bestandspatroon- en topicrouting |
| `workflow.md` | Feature directories, todos, commitconventies |
| `response-format.md` | Klikbare gesloten keuzes |
| `writing-standards.md` | Schrijfregels voor `.claude/` documentatie |

### Commands en skills

Alle 18 slash-commands hebben een bestaand skill-contract. Commands zijn wrappers; inhoudelijke contracten staan in `.claude/skills/`.

Belangrijke workflow-skills:

- `analyze-codebase`
- `audit-config`
- `check-standards`
- `review-changes`
- `finalize-changes`
- `commit-push`
- `new-spec`
- `validate-spec`
- `refactor`
- `refactor-plan`
- `website-review`

Domeinspecifieke skills:

- `groeiwijze-adaptive-intake-flow/SKILL.md`
- `groeiwijze-adaptive-site-structure/SKILL.md`

## Root Utilities

| Bestand | Doel |
|---------|------|
| `dev-reload.sh` | Statische live-reload preview via browser-sync + Tailscale |
| `start-sites.sh` | Start Docker container, optioneel Tailscale serve |
| `docker-compose.yml` | Docker setup voor PHP/Nginx |
| `add_aanbod.py` | One-off contentscript |
| `.env.example` | Voorbeeld environment variables |
| `config.txt` | Lokale credentials, gitignored |

## Development Modes

### Statische preview

```bash
cd website/ && python3 -m http.server 8000
```

of:

```bash
bash dev-reload.sh
```

Deze modes ondersteunen het PHP-contactformulier niet.

### Docker met PHP

```bash
docker compose up --build
```

Docker publiceert de site op `http://localhost:8001` en gebruikt environment variables voor SMTP-configuratie.

## Wat hier niet is

- Geen database
- Geen CMS
- Geen front-end framework
- Geen JavaScript-framework
- Geen bundler of build-systeem
- Geen Sass/PostCSS/Tailwind
- Geen test-framework
- Geen authenticatie
- Geen sessies
- Geen client-side router
