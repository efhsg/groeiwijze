# Project Configuratie

## Tech Stack

- **Front-end:** HTML5, CSS3, Vanilla JavaScript (ES6), Google Fonts (Libre Franklin)
- **Back-end:** PHP 8.2+ in Docker, PHP 8+ op hosting (alleen contactformulier), PHPMailer via Composer
- **Geen** build system, geen test framework

## Bestandsstructuur

```
website/                            # Website root
├── index.html                      # Home
├── aanbod.html                     # Aanbod / diensten
├── visie.html                      # Visie
├── over-mij.html                   # Over mij
├── werkwijze.html                  # Werkwijze
├── herstelroute.html               # Herstelroute
├── tarieven.html                   # Tarieven
├── verwijzers.html                 # Voor verwijzers
├── veelgestelde-vragen.html        # FAQ
├── contact.html                    # Contactformulier
├── thank-you.html                  # Bedankpagina (noindex)
├── privacy.html                    # Privacybeleid
├── contact-submit.php              # Form handler (PHP/PHPMailer)
├── css/
│   └── style.css                   # Hoofdstylesheet met design system
├── js/
│   └── main.js                     # Mobiele navigatie toggle (minimaal)
└── assets/
    └── img/                        # Afbeeldingen en favicon
```

Root directory bevat preview-iteraties (`_archive/preview-*.html`) en logo-varianten in SVG. Zie `.claude/codebase_analysis.md` voor root-utilities (`dev-reload.sh`, `start-sites.sh` etc.).

Composer staat niet in de repository-root. Docker installeert PHPMailer via `docker/groeiwijze/composer.json`; op shared hosting moet `vendor/autoload.php` één niveau boven `website/` beschikbaar zijn, omdat `website/contact-submit.php` `dirname(__DIR__) . '/vendor/autoload.php'` laadt.

## .claude/ structuur

| Pad | Doel |
|-----|------|
| `.claude/rules/` | Gezaghebbende rules (zie `CLAUDE.md`) |
| `.claude/skills/` | Skill-contracten + `index.md` (registry) |
| `.claude/commands/` | Slash-command wrappers — verwijzen naar skill-contracten |
| `.claude/templates/` | Templates voor genereer-skills (bv. `feature-spec.md` voor `/new-spec`) |
| `.claude/design/` | Algemene design-documenten (geen feature) |
| `.claude/plans/` | Ad-hoc analyse-outputs (geen vaste structuur) |
| `.claude/codebase_analysis.md` | Snel oriëntatiepunt voor nieuwe sessies |
| `.claude/settings.json` | Gedeelde Claude Code permissies |
| `.claude/settings.local.json` | Lokale Claude Code overrides, gitignored |

## Development Server

**Optie 1 — Python (simpel, geen PHP):**
```bash
cd website/ && python3 -m http.server 8000
```
Let op: contactformulier werkt niet zonder PHP.

**Optie 2 — Browser-sync met live reload (geen PHP):**
Zie `.claude/design/live-reload-setup.md` voor setup met browser-sync + Tailscale. Dit serveert `website/` statisch en ondersteunt het contactformulier niet.

```bash
bash dev-reload.sh
```

**Optie 3 — Docker met PHP:**
Gebruik Docker wanneer het contactformulier lokaal functioneel getest moet worden.

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build
```

Docker luistert standaard op `http://localhost:8001`. De container genereert `/var/www/private/contact-mail.config.php` uit `.env`-waarden en installeert PHPMailer via `docker/groeiwijze/composer.json`.

## Deployment

1. Kopieer inhoud van `website/` naar de document root van een webserver met PHP-ondersteuning
2. Zorg dat `vendor/autoload.php` één niveau boven `website/` staat, of pas het autoload-pad in `contact-submit.php` expliciet aan
3. Installeer PHPMailer vanuit een Composer project buiten de document root, bijvoorbeeld naast `website/`
4. Configureer `private/contact-mail.config.php` buiten document root (SMTP credentials), op het pad dat `dirname($_SERVER['DOCUMENT_ROOT']) . '/private/contact-mail.config.php'` oplevert
5. Geen front-end build stap nodig

## Contactformulier

Het formulier (`contact.html`) verzendt via `contact-submit.php`:

- **Backend:** PHP + PHPMailer (SMTP)
- **Config:** `private/contact-mail.config.php` buiten document root; lokale secrets kunnen in `private/config/` staan, maar dat is niet het runtime-pad
- **Anti-spam:** honeypot veld, tijdcheck (min. 3s), IP rate limiting (max 5/uur)
- **Flow:** formulier → validatie → e-mail naar praktijk + bevestiging naar bezoeker → `thank-you.html`

## Externe Services

| Service | Gebruik |
|---------|---------|
| Google Fonts | Libre Franklin font |
| SMTP provider | E-mail verzending via PHPMailer |
| Tailscale | Remote development access |
