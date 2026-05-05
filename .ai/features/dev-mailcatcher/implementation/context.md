# Implementatie Context

## Doel

Voeg Mailpit toe als dev-mailcatcher in de Docker-stack, zodat form-submits in de dev-omgeving niet meer bij productie-mail terechtkomen. Mailcatcher is dev-only (compose-service); productie blijft op directe SFTP-deploy met `private/contact-mail.config.php`.

## Scope

- **In:** `docker-compose.yml` (extra service), `.env.example` (dev-veilige defaults + 2 nieuwe SMTP-keys), `docker/groeiwijze/generate-config.sh` (2 keys doorgeven), `docker/groeiwijze/contact-submit.php` (SMTP-encryptie + skip-verify parametrisering), `start-sites.sh` (inbox-URL tonen), onboarding-doc in `CLAUDE.md`.
- **Uit:** `website/contact-submit.php` (SFTP/productie-codepad — ongewijzigd), formulier-validatie/anti-spam/rate-limiting, productie-config.

## Key references

- Spec: `.ai/features/dev-mailcatcher/spec.md` (10 AC's)
- Plan: `.ai/features/dev-mailcatcher/plan.md` (§3 wijzigingen per bestand, §4 implementatievolgorde)
- Project rules: `/projects/groeiwijze.nl/.claude/rules/`
- Codebase analysis: `/projects/groeiwijze.nl/.claude/codebase_analysis.md`

## Definition of Done

Per `plan.md` §8 (DoD-lijst):
- `docker compose up -d` brengt site én mailcatcher op zonder errors → **runtime, niet uitvoerbaar zonder Docker op dev-host**
- Form-submit levert twee mails (admin + visitor) binnen 5s in Mailpit-inbox → **runtime**
- Compose-binding `127.0.0.1:8025:8025` → statisch verifieerbaar
- Mailcatcher-stop laat statische pagina's onaangetast; form-submit faalt zichtbaar → **runtime**
- `.env.example` defaults wijzen naar mailcatcher → statisch verifieerbaar
- `start-sites.sh` toont site- en inbox-URL → statisch verifieerbaar
- Onboarding-doc bevat URL, terminal-vrije stappen, Tailscale-waarschuwing, PII-advies → statisch verifieerbaar
- Productie-config geen mailcatcher-referenties → SFTP-inspectie door release-uitvoerder

## Classificatie

S/M — 6 bestanden wijzigen, 1 onboarding-doc-update. Single-session.

## Modus

AUTONOOM — geen interactieve confirmaties; obstakels in `insights.md`.
