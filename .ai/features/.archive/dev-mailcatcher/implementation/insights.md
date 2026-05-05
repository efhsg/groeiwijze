# Implementatie Insights

## Pre-flight obstakels

- **Docker niet beschikbaar op dev-host (sessie commit 2f55fa0):** runtime-AC-validatie (`docker compose up -d`, form-submit-test, `curl http://localhost:8025`) kan niet vanuit deze sessie. Statische validatie is wel mogelijk: `docker compose config` is helaas óók niet aanwezig, dus YAML-syntax wordt via Python `yaml.safe_load` gevalideerd. Runtime-AC's worden door de uitvoerder (gebruiker) afgevinkt na `docker compose up -d`.
- **Geen formele linter / test framework in project:** `php -l` voor PHP-syntax, `bash -n` voor shell-scripts is alles wat we hebben. Geen unit tests — dat is consistent met `.claude/config/project.md` ("Geen build system, geen test framework").

## Beslissingen tijdens implementatie

- **`SMTP_SECURE`/`SMTP_SKIP_VERIFY` ook op `groeiwijze`-service in compose:** plan §3.1 noemt deze twee env-vars niet expliciet bij de `groeiwijze`-service-update, alleen bij `.env`-flow. Toegevoegd zodat `docker-compose.yml` consistent doorgeeft wat `generate-config.sh` consumeert. Zonder deze regels zou de container default-`tls`/`false` zien — dat klopt voor productie, maar is een impliciete koppeling die makkelijk kan stuk gaan bij een rename.
- **Onboarding in `CLAUDE.md` (niet aparte `docs/dev-mailcatcher.md`):** `CLAUDE.md` is 67 regels en heeft ruimte. Plan §3.7 noemt aparte file als optie "als CLAUDE.md te vol wordt". Niet het geval — directe sectie houdt de info dicht bij waar lezers al kijken.
- **Sectie-volgorde in `CLAUDE.md`:** "Dev mailcatcher" staat tussen "Project Overview" en "Rules" zodat het direct na de project-context komt en vóór de regelverwijzingen.

## Pitfalls

- **Runtime-AC's niet validateerbaar in deze sessie:** Docker is niet beschikbaar op deze host. AC-mailcatcher2/3/4/6/10 vereisen `docker compose up -d` en form-submit-tests. De uitvoerder (gebruiker) moet die op de dev-host afvinken na pull. Implementatie zelf is statisch volledig.
- **`SMTPSecure` empty-string vs null:** `$config['smtp_secure'] ?? PHPMailer::ENCRYPTION_STARTTLS` vangt alleen `null`, niet empty string. Dat is bewust: een lege string in `.env` betekent "geen encryptie" en dat moet PHPMailer zo zien. De default `tls` in `.env.example` voorkomt accidentele klare-text-verbindingen.
- **`smtp_skip_verify` in `generate-config.sh` is unquoted:** `${SMTP_SKIP_VERIFY:-false}` produceert PHP-literal `true` of `false` (niet quoted string). Dat is correct — anders zou `'false'` truthy zijn in PHP.

## Validatie-resultaten (statisch)

- `php -l docker/groeiwijze/contact-submit.php` — No syntax errors detected
- `bash -n start-sites.sh` — OK
- `bash -n docker/groeiwijze/generate-config.sh` — OK
- `docker-compose.yml` — top-level services: `groeiwijze`, `mailcatcher`; geen tabs; valid YAML-structuur
- Geen unit tests in project (`.claude/config/project.md` → "Geen test framework")

## Runtime-validatie op dev-host (2026-05-05)

- AC-mailcatcher2 faalde bij eerste runtime-test. Form-submit gaf HTTP 400 met
  PHP-melding `SMTP Error: Could not connect to SMTP host. STARTTLS command
  failed Command not implemented`. Mailpit-log toonde `[smtpd] response (...)
  502 5.5.1 Command not implemented`.
- **Root cause:** `.env.example` defaultte op `SMTP_SECURE=tls` +
  `SMTP_SKIP_VERIFY=true`, maar de `mailcatcher`-service in
  `docker-compose.yml` startte Mailpit zonder `--smtp-tls-cert`/`--smtp-tls-key`.
  Mailpit op poort 1025 stond dus in "no encryption"-modus, terwijl
  PHPMailer een STARTTLS-handshake initieerde. `SMTP_SKIP_VERIFY` had
  daardoor geen functie — het skippen van TLS-cert-verificatie is alleen
  zinvol als TLS daadwerkelijk in gebruik is.

## B1-fix toegepast (2026-05-05, zelfde sessie)

Mailpit STARTTLS-capable gemaakt via cert-init-sidecar:

1. **`mailcatcher_certgen`-service** toegevoegd: `alpine:3.20` met
   `apk add openssl`, genereert eenmalig self-signed cert+key
   (`CN=mailcatcher`, `subjectAltName=DNS:mailcatcher,DNS:localhost`,
   10 jaar geldig) in named volume `mailcatcher_certs`. Idempotent —
   `if [ ! -f /certs/cert.pem ]` voorkomt regenereren bij elke `up`.
   `restart: "no"` — one-shot.
2. **`mailcatcher`-service** krijgt `depends_on: { mailcatcher_certgen:
   { condition: service_completed_successfully } }`, mount
   `mailcatcher_certs:/certs:ro`, env-vars `MP_SMTP_TLS_CERT=/certs/cert.pem`
   en `MP_SMTP_TLS_KEY=/certs/key.pem`. Mailpit-log bevestigt:
   `[smtpd] starting on [::]:1025 (STARTTLS optional)`.
3. **Top-level `volumes:`-sectie** toegevoegd voor `mailcatcher_certs`.
4. **`.env`-defaults teruggezet** naar `SMTP_SECURE=tls` /
   `SMTP_SKIP_VERIFY=true` (matcht `.env.example`).
5. **Verificatie:** form-submit via curl op
   `https://thinkpad-ubu.tail764e35.ts.net:8443/contact-submit.php`
   geeft HTTP 303; Mailpit-API toont `total:2` (admin + visitor) ~5s
   later. Geen 502-errors meer in mailcatcher-log.

Routes die niet gekozen zijn: Mailpit-image uitbreiden met openssl (minimal
image, niet uitbreidbaar zonder custom Dockerfile dat de upstream-image
overschrijft) en cert in repo committen (zero security risk maar cosmetisch
onfris en niet idempotent over reset). Sidecar werd gekozen om dev-spinup
zelf-bootstrappend te houden — geen handmatige cert-stappen voor nieuwe devs.

