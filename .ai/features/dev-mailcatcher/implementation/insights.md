# Implementatie Insights

## Pre-flight obstakels

- **Docker niet beschikbaar op dev-host (deze sessie):** runtime-AC-validatie (`docker compose up -d`, form-submit-test, `curl http://localhost:8025`) kan niet vanuit deze sessie. Statische validatie is wel mogelijk: `docker compose config` is helaas óók niet aanwezig, dus YAML-syntax wordt via Python `yaml.safe_load` gevalideerd. Runtime-AC's worden door de uitvoerder (gebruiker) afgevinkt na `docker compose up -d`.
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

