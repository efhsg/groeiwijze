# Security

Van toepassing op PHP-backend code, met name `contact-submit.php`.

## Contactformulier

Het formulier is het enige aanvalsoppervlak van de site. Handhaaf deze beschermlagen:

- **Honeypot-veld** — verborgen inputveld dat bots invullen, mensen niet
- **Tijdcheck** — minimaal 3 seconden tussen laden en verzenden (bots gaan sneller)
- **IP rate limiting** — maximaal 5 verzendingen per uur per IP-adres
- **Input sanitization** — gebruik `htmlspecialchars()` of `filter_var()` op alle invoer
- **Geen gegevens loggen** — log nooit namen, e-mailadressen of berichtinhoud

## SMTP-credentials

- Credentials staan in `private/contact-mail.config.php` — buiten de document root
- Nooit credentials in code, commentaar of `.env` die in git belandt
- `.env.example` documenteert welke variabelen nodig zijn, zonder waarden

## Validatie

- Valideer alle formuliervelden server-side (niet alleen client-side)
- E-mailadressen valideren met `filter_var($email, FILTER_VALIDATE_EMAIL)`
- Verplichte velden expliciet controleren — gooi een fout bij ontbrekende waarden
- Gebruik geen `$_GET` voor formulierdata — alleen `$_POST`

## Functionele grens

- De site heeft geen database, geen sessies, geen authenticatie
- Uitbreiding die een van deze introduceert vereist expliciete bespreking
