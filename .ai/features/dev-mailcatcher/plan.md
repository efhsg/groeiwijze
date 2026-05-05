# Implementatieplan: dev-mailcatcher

**Feature-map:** `.ai/features/dev-mailcatcher/`
**Behoort bij:** `spec.md` (status `accepted`, 10 AC's, review_2-feedback verwerkt)
**Aangemaakt:** 2026-05-05

---

## 1. Doel

Vertaal de geaccepteerde functionele keuzes uit `spec.md` naar concrete implementatie-stappen, technologie-keuzes en bestand-wijzigingen. Dit document beschrijft HOE; de spec beschrijft WAT.

---

## 2. Technologiekeuzes

| Component | Keuze | Reden |
|-----------|-------|-------|
| Mailcatcher-image | `axllent/mailpit:latest` (later pinnen op een specifieke versie zodra de eerste werkende setup landt) | Actief onderhouden, ~20 MB Alpine-image, ingebouwde HTTP-API, ondersteunt STARTTLS met auto-generated cert en `--smtp-auth-accept-any` |
| Compose-service-naam | `mailcatcher` | Beschrijvend, neutraal naar tooling-keuze (toekomstige migratie naar MailHog/Maildev mogelijk zonder service-naam-change) |
| SMTP-poort intern | 1025 (Mailpit-default) | Geen host-publicatie nodig — alleen bereikbaar binnen Docker-netwerk |
| HTTP-UI-poort host | 8025 (Mailpit-default) | Vrij op de dev-host (8001 is groeiwijze, 8443 is Tailscale-HTTPS-site) |
| Tailscale-Serve-poort UI | 8444 | Vrij naast de site op 8443 |
| TLS-strategie | Mailpit auto-generated cert + `MP_SMTP_AUTH_ACCEPT_ANY=true` + `MP_SMTP_AUTH_ALLOW_INSECURE=true` | Form-handler kan STARTTLS blijven sturen; auth-credentials worden geaccepteerd zonder validatie |

---

## 3. Wijzigingen per bestand

### 3.1 `docker-compose.yml`

Voeg een tweede service toe naast `groeiwijze`:

```yaml
  # dev-only — niet bedoeld voor productie (zie .ai/features/dev-mailcatcher/spec.md)
  mailcatcher:
    image: axllent/mailpit:latest
    container_name: groeiwijze_mailcatcher
    ports:
      - "127.0.0.1:8025:8025"   # web-UI — alleen localhost; Tailscale-Serve publiceert extern op 8444
      # 1025 alleen intern — geen host-publicatie
    environment:
      - MP_SMTP_AUTH_ACCEPT_ANY=true
      - MP_SMTP_AUTH_ALLOW_INSECURE=true
      - MP_MAX_MESSAGES=500
    restart: unless-stopped
```

Update `groeiwijze`-service:
- Geen `depends_on: [mailcatcher]` — dat zou de site-start blokkeren bij mailcatcher-uitval (botst met AC-mailcatcher6 "rest werkt door").
- SMTP-env-vars wijzen via `.env` naar `mailcatcher:1025` (zie 3.2).

### 3.2 `.env.example`

Vervang het huidige SMTP-blok door dev-veilige defaults met inline-commentaar:

```bash
# === Mail (dev-default: groeiwijze_mailcatcher in docker-compose) ===
# Standaardwaarden wijzen naar de mailcatcher-sidecar; alle form-submit-mails
# komen in de Mailpit-inbox op http://localhost:8025.
#
# Voor een hypothetische Docker-deploy op productie: overschrijf SMTP_HOST,
# SMTP_PORT, SMTP_USER, SMTP_PASS, MAIL_FROM en MAIL_TO met productie-waarden.
# Productie via mijn.host-SFTP gebruikt geen .env — mail-config staat in
# private/contact-mail.config.php op de productie-host.
SMTP_HOST=mailcatcher
SMTP_PORT=1025
SMTP_USER=mailpit
SMTP_PASS=mailpit
MAIL_FROM=dev-noreply@groeiwijze.local
MAIL_FROM_NAME=Groeiwijze (dev)
MAIL_TO=dev-anja@groeiwijze.local

# Security (dev-veilig — mag identiek aan productie blijven)
RATE_LIMIT_SALT=groeiwijze_ratelimit_2024
```

De Publish/SFTP-blok blijft ongewijzigd.

### 3.3 `.env` (op de dev-host)

Bestaande dev-`.env` aanpassen volgens `.env.example`. Niet checked in (gitignored). Documentatie-stap in onboarding (zie 3.6).

### 3.4 `docker/groeiwijze/contact-submit.php`

Spec §3 staat minimale SMTP-transport-parametrisering toe (zie spec §3 niet-scope). De huidige hardcode `SMTPSecure = STARTTLS` + `SMTPAuth = true` is incompatibel met een dev-mailcatcher zonder echte TLS-cert. Minimaal noodzakelijke aanpassing:

```php
$mailer->SMTPSecure = $config['smtp_secure'] ?? PHPMailer::ENCRYPTION_STARTTLS;

if (!empty($config['smtp_skip_verify'])) {
    $mailer->SMTPOptions = [
        'ssl' => [
            'verify_peer' => false,
            'verify_peer_name' => false,
            'allow_self_signed' => true,
        ],
    ];
}
```

Twee config-keys toegevoegd: `smtp_secure` (default `tls`) en `smtp_skip_verify` (default `false`). Productie-config blijft gedrag onveranderd; dev-config zet `smtp_skip_verify=true`.

### 3.5 `docker/groeiwijze/generate-config.sh`

Twee nieuwe regels in de PHP-config-array:

```php
'smtp_secure'      => '${SMTP_SECURE:-tls}',
'smtp_skip_verify' => ${SMTP_SKIP_VERIFY:-false},
```

`.env.example` (3.2) voegt navenant toe:

```bash
SMTP_SECURE=tls
SMTP_SKIP_VERIFY=true
```

In productie-mail-config (`private/contact-mail.config.php` op de hosting-server) blijft `smtp_skip_verify` afwezig of expliciet `false`.

### 3.6 `start-sites.sh`

Tussen de site-start en de Tailscale-Serve-regel: inbox via Tailscale exposeren. Minimale aanpassing:

```bash
if command -v tailscale &> /dev/null; then
    echo ""
    HOSTNAME=$(tailscale status --json | jq -r '.Self.DNSName' | sed 's/\.$//')
    echo "Tailscale serve commands (run manually to enable HTTPS):"
    echo "  tailscale serve --bg --https=8443 http://localhost:8001"
    echo "  tailscale serve --bg --https=8444 http://localhost:8025"
    echo ""
    echo "HTTPS access:"
    echo "  Site:           https://$HOSTNAME:8443"
    echo "  Mailcatcher UI: https://$HOSTNAME:8444"
fi
```

Locale-toegang-output uitbreiden:

```bash
echo "Local access:"
echo "  Site:           http://localhost:8001"
echo "  Mailcatcher UI: http://localhost:8025"
```

### 3.7 Onboarding-documentatie

Nieuwe sectie in `CLAUDE.md` (of een aparte `docs/dev-mailcatcher.md` als de hoofd-`CLAUDE.md` te vol wordt) met:

1. Wat is de mailcatcher (één alinea, link naar spec).
2. Hoe bekijk je gevangen mail (URL `http://localhost:8025` of Tailscale-URL).
3. **Waarschuwing**: alle Tailscale-leden lezen mee — gebruik fictieve testdata, geen echte klant-PII (AC-mailcatcher8).
4. Productie gebruikt geen `.env`; mail-config-bestand op mijn.host-host blijft gescheiden van dev-flow.

---

## 4. Implementatievolgorde

1. **Mailcatcher-service in compose** (3.1) — start los, verifieer `http://localhost:8025` toont een lege Mailpit-inbox.
2. **`.env.example` + dev-`.env` updaten** (3.2, 3.3) — SMTP-vars wijzen naar `mailcatcher:1025`.
3. **`generate-config.sh` uitbreiden** (3.5) — twee nieuwe config-keys.
4. **`contact-submit.php` parametriseren** (3.4) — minimale pass-through voor `smtp_secure` en `smtp_skip_verify`.
5. **End-to-end test** — form-submit op `localhost:8001/contact.html` levert mail in Mailpit-inbox binnen 5s (AC-mailcatcher2).
6. **`start-sites.sh` uitbreiden** (3.6) — Tailscale-URL voor inbox tonen.
7. **Onboarding-doc** (3.7) — schrijven en linken vanuit hoofd-`CLAUDE.md`.
8. **Foutpad-test** — `docker compose stop mailcatcher`, doe form-submit → submit faalt zichtbaar; `localhost:8001/index.html` blijft laden (AC-mailcatcher6).

---

## 5. Test-mapping per AC

| AC | Validatiestap |
|----|--------------|
| AC-mailcatcher1 | Inspecteer dev-`.env`: `MAIL_TO` is dev-only-adres; productie-`MAIL_TO` blijft alleen op productie-host |
| AC-mailcatcher2 | Form-submit op `localhost:8001/contact.html` → controleer Mailpit-API `GET /api/v1/messages` op twee nieuwe entries: één naar `MAIL_TO` (admin), één naar het ingevulde bezoekers-e-mailadres. Venster: 5s bij warme container, 30s bij cold start (eerste image-pull) |
| AC-mailcatcher3 | `docker compose up -d` → `curl -sf http://localhost:8025` levert HTTP 200 |
| AC-mailcatcher4 | `docker compose down` → `docker ps | grep mailcatcher` is leeg |
| AC-mailcatcher5 | `grep -i mailcatcher docker-compose.yml` op productie-host: niet aanwezig (productie heeft geen Docker, dus per definitie gedekt) |
| AC-mailcatcher6 | `docker compose stop mailcatcher` → form-submit toont fout; `curl -sf http://localhost:8001/index.html` is HTTP 200 |
| AC-mailcatcher7 | Inspectie van `.env.example` op dev-defaults + inline commentaar |
| AC-mailcatcher8 | Inspectie van onboarding-doc op URL + Tailscale-waarschuwing + PII-advies |
| AC-mailcatcher9 | Inspectie van productie-`private/contact-mail.config.php`: `smtp_host` is `mail.groeiwijze.nl`, geen mailcatcher-referentie |
| AC-mailcatcher10 | Compose-binding is `127.0.0.1:8025:8025`. Drie observaties: (a) `curl http://localhost:8025` op dev-host = HTTP 200; (b) `curl https://<tailscale-name>:8444` van Tailscale-peer = HTTP 200; (c) `curl http://<dev-host-publiek-IP>:8025` van niet-Tailscale netwerk = connection refused / timeout |

---

## 6. Implementatie-risico's

| Risico | Mitigatie |
|--------|-----------|
| Mailpit-versie zonder `MP_SMTP_AUTH_ACCEPT_ANY` (zeer oude versies) | Pin op `axllent/mailpit:v1.20+` zodra de eerste werkende setup is gevalideerd |
| Self-signed cert + `verify_peer=false` in PHPMailer leidt tot security-gat in dev | Keys alleen in dev-`.env`; productie-config bevat `smtp_skip_verify=false` |
| Mailpit-poort 8025 conflict met andere lokale tooling | Documenteer in onboarding; alternatief vrij poort-nummer beschikbaar |
| Tailscale-Serve op 8444 conflict met andere serves | `start-sites.sh` toont de commando's maar voert ze niet automatisch uit — beheerder kiest |
| Dev-host start de stack maar `mailcatcher`-image is nog niet gepulld bij eerste run | `docker compose up -d --build` in `start-sites.sh` regelt de pull |

---

## 7. Open implementatie-keuzes

Geen blokkerende open keuzes. Niet-blokkerend:

- **Pinning van Mailpit-versie** — `latest` in eerste run, daarna pinnen op de geteste versie (bijv. `v1.20.5`).
- **Locatie onboarding-doc** — `CLAUDE.md` direct of een aparte `docs/dev-mailcatcher.md`. Te beslissen op moment van schrijven afhankelijk van `CLAUDE.md`-grootte.
- **Mailpit-`MP_MAX_MESSAGES`-waarde** — 500 als ruime default; aanpasbaar zonder spec-impact.

---

## 8. Definition of Done

- [ ] `docker compose up -d` brengt site én mailcatcher op zonder errors
- [ ] Form-submit op `localhost:8001/contact.html` levert twee mails (admin + visitor) binnen 5s in Mailpit-inbox (warme container)
- [ ] Compose-binding is `127.0.0.1:8025:8025`; publiek-IP-curl op poort 8025 weigert
- [ ] Mailcatcher-stop laat statische pagina's onaangetast; form-submit faalt zichtbaar
- [ ] `.env.example` defaults wijzen naar mailcatcher zonder productie-SMTP-credentials; nieuwe checkout krijgt veilig dev-gedrag
- [ ] `start-sites.sh` toont zowel site- als inbox-URL (lokaal + Tailscale)
- [ ] Onboarding-doc bevat URL, terminal-vrije stappen, Tailscale-waarschuwing en PII-advies (incl. afzender-IP en mail-headers)
- [ ] Productie-config (`private/contact-mail.config.php` op mijn.host) SFTP-inspectie: geen mailcatcher-referenties

---

## Cross-link

- Spec: `.ai/features/dev-mailcatcher/spec.md`
- Aanleiding: `.ai/features/worktrees/analysis.md` §11.3 en §12
- Form-handler: `docker/groeiwijze/contact-submit.php`
- Config-generator: `docker/groeiwijze/generate-config.sh`
