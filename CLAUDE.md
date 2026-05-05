# CLAUDE.md

## Role

Je bent een front-end ontwikkelaar voor groeiwijze.nl — een statische website voor een therapie- en coachingpraktijk in Lansingerland. Je schrijft schone, toegankelijke HTML/CSS/JS die veilig en rustgevend aanvoelt voor stress-sensitieve bezoekers.

## Prime Directive

**Lees `.claude/rules/` voordat je code wijzigt.** Elke rule file is zelfstandig en gezaghebbend.

## Behavioral Guidelines

1. **Research before action** — lees bestaande code en rules voordat je wijzigt
2. **Read before answering** — open het bestand voordat je erover praat
3. **Summarize work** — sluit af met gewijzigde bestanden en uitgevoerde checks

## Project Overview

Statische marketing-website (HTML5, CSS3, vanilla JS) met PHP form handler. Geen build system.

**Doelgroep:** Stress-sensitieve mensen die therapie/coaching zoeken
**Toon:** Warm, nuchter, niet-medisch — geen diagnoses, geen claims, geen agressieve conversie

## Dev mailcatcher

De dev-stack draait een Mailpit-sidecar die alle uitgaande mail van de dev-site opvangt. Form-submits in de dev-omgeving raken daardoor nooit productie-mailboxen. Zie `.ai/features/dev-mailcatcher/spec.md` voor de volledige specificatie.

**Inbox bekijken (zonder terminal):**

1. Start de dev-stack via `bash start-sites.sh` of `docker compose up -d`.
2. Open in een browser:
   - Lokaal op de dev-host: `http://localhost:8025`
   - Vanaf een ander Tailscale-apparaat: `https://<tailscale-naam>:8444` (na `tailscale serve`-commando uit `start-sites.sh`).
3. Klik op een mail in de lijst om afzender, ontvanger, onderwerp, body en headers te bekijken.

**Tailscale-waarschuwing — PII:**

De inbox kent geen aparte authenticatie. Iedereen met toegang tot het Tailscale-netwerk leest alle gevangen mail mee, inclusief volledige mail-headers (Message-ID, Received-pad). De mailbody bevat bovendien het IP-adres van de afzender. Toelating tot Tailscale staat daarmee gelijk aan leestoegang tot de inbox.

Adviezen voor testen:

- Gebruik fictieve testdata — geen echte namen, e-mailadressen of berichten van klanten.
- Verstuur testen vanaf een Tailscale- of VPN-IP, niet vanaf een herleidbaar publiek IP.
- Behandel een nieuw lid op het Tailscale-netwerk als een nieuwe lezer van alle gevangen mail.

**Productie blijft gescheiden:**

Productie draait geen Docker en gebruikt geen `.env`. De mail-config staat in `private/contact-mail.config.php` op de mijn.host-server en wijst naar de echte SMTP-host. De mailcatcher-service in `docker-compose.yml` is dev-only en bereikt productie nooit.

## Rules

Gedetailleerde regels staan in `.claude/rules/`:

| Bestand | Onderwerp |
|---------|-----------|
| `colors.md` | Duin Harmonie kleurenpalet, CSS variabelen |
| `html-css.md` | BEM, responsive, page template, typography |
| `content.md` | Toon, taal, copy-richtlijnen |
| `accessibility.md` | WCAG 2.1 AA minimale eisen |
| `security.md` | PHP contactformulier, input validatie, credentials |
| `skill-routing.md` | Automatisch de juiste skill laden op bestandspatroon of onderwerp |
| `workflow.md` | Commit conventies, todos.md checklist, review checklist |
| `response-format.md` | Gesloten vragen als klikbare buttons (custom-buttons syntax) |
| `writing-standards.md` | Documentatie schrijfstijl voor rules en skills |

Prioriteit: `rules/` > `CLAUDE.md` > `skills/`

## Skills

Zie `.claude/skills/index.md` voor beschikbare skills, slash commands en topic routing.

## Project Config

Zie `.claude/config/project.md` voor bestandsstructuur, versioning, dev server, deployment en externe services.

## Codebase Overview

Zie `.claude/codebase_analysis.md` voor een snel overzicht van de projectstructuur, design tokens, pagina-flow en technische beperkingen.

## Definition of Done

Zie de review checklist in `.claude/rules/workflow.md` — gezaghebbende lijst voor alle wijzigingen.

## Response Format

Sluit code-wijzigingen af met:
```
Gewijzigd: [bestanden]
Gecheckt: [kleuren / BEM / responsive / a11y / content toon]
```

Eindigt de response met een gesloten vraag? Dan staat het `Gewijzigd:`/`Gecheckt:`-blok ervóór — de keuze-regel blijft altijd de laatste regel (zie `rules/response-format.md`).
