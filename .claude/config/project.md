# Project Configuratie

## Tech Stack

- **Front-end:** HTML5, CSS3, Vanilla JavaScript (ES6), Google Fonts (Libre Franklin)
- **Back-end:** PHP 8+ (alleen contactformulier), PHPMailer via Composer
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

Root directory bevat preview-iteraties (`_archive/preview-*.html`) en logo-varianten in SVG.

## Development Server

**Optie 1 — Python (simpel, geen PHP):**
```bash
cd website/ && python3 -m http.server 8000
```
Let op: contactformulier werkt niet zonder PHP.

**Optie 2 — Docker + Browser-sync met live reload:**
Zie `.claude/design/live-reload-setup.md` voor volledige setup met Docker (Nginx + PHP-FPM) + Tailscale.

```bash
bash dev-reload.sh
```

## Deployment

1. Kopieer inhoud van `website/` naar webserver met PHP-ondersteuning
2. Installeer Composer dependencies (`composer install`) voor PHPMailer
3. Configureer `private/contact-mail.config.php` buiten document root (SMTP credentials)
4. Geen front-end build stap nodig

## Contactformulier

Het formulier (`contact.html`) verzendt via `contact-submit.php`:

- **Backend:** PHP + PHPMailer (SMTP)
- **Config:** `private/contact-mail.config.php` (buiten document root)
- **Anti-spam:** honeypot veld, tijdcheck (min. 3s), IP rate limiting (max 5/uur)
- **Flow:** formulier → validatie → e-mail naar praktijk + bevestiging naar bezoeker → `thank-you.html`

## Externe Services

| Service | Gebruik |
|---------|---------|
| Google Fonts | Libre Franklin font |
| SMTP provider | E-mail verzending via PHPMailer |
| Tailscale | Remote development access |
