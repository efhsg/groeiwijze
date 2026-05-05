# Implementatie Todos

## Stappen

- [x] `docker-compose.yml` — voeg `mailcatcher`-service toe (Mailpit, host-bound op 127.0.0.1:8025)
- [x] `docker-compose.yml` — update `groeiwijze`-service met `SMTP_SECURE` en `SMTP_SKIP_VERIFY` env-vars
- [x] `.env.example` — vervang SMTP-blok met dev-veilige defaults, voeg `SMTP_SECURE`/`SMTP_SKIP_VERIFY` toe, inline-commentaar voor prod-overrides
- [x] `docker/groeiwijze/generate-config.sh` — voeg `smtp_secure` en `smtp_skip_verify` keys toe aan PHP-config
- [x] `docker/groeiwijze/contact-submit.php` — parametriseer `SMTPSecure` en cert-verificatie via config
- [x] `start-sites.sh` — voeg mailcatcher inbox-URL toe (lokaal + Tailscale-Serve-commando voor 8444)
- [x] Onboarding-doc — voeg sectie toe in `CLAUDE.md` (URL, gebruik, Tailscale-PII-waarschuwing)
- [x] Run linter + fix issues (php -l, bash -n, yaml-parse)
- [x] Run unit tests + fix failures (n.v.t. — geen test framework)
- [x] DoD check
- [ ] Commit
