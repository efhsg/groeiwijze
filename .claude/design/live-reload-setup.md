# Live-reload via browser-sync + Tailscale serve

## Probleem

De site is remote bereikbaar via Tailscale. De browser herlaadt niet automatisch bij wijzigingen aan HTML, CSS of JS.

## Aanpak

Browser-sync serveert de `website/` directory direct en injecteert een WebSocket-snippet voor auto-reload. Tailscale serve maakt het bereikbaar via HTTPS.

### Architectuur

```
[Browser remote] ← HTTPS → [Tailscale serve :3443]
                                   ↓
                            [browser-sync :3000] ← file watcher + static server
                                   ↓
                            [website/ directory]
```

Browser-sync:
- Serveert bestanden uit `website/` als statische site
- Watched `website/**/*.{html,css,js}` en `website/assets/img/*`
- Injecteert een WebSocket-snippet in elke HTML-response
- Bij een bestandswijziging stuurt het via WebSocket een reload-commando naar de browser

Tailscale serve:
- Maakt browser-sync (poort 3000) bereikbaar via HTTPS op poort 3443
- Alleen toegankelijk binnen het Tailscale-netwerk

**Let op:** PHP (`contact-submit.php`) werkt niet in deze dev-modus. Het contactformulier is alleen functioneel in de Docker productie-omgeving.

## Gebruik

```bash
bash dev-reload.sh
```

Dit script:
1. Checkt of alle dependencies aanwezig zijn (tailscale, jq, npx)
2. Configureert Tailscale serve op poort 3443 → localhost:3000
3. Start browser-sync op poort 3000, serveert `website/`

Open daarna `https://<tailscale-hostname>:3443` op je remote machine.

Stop met Ctrl+C. Het script ruimt Tailscale serve automatisch op via een EXIT trap.

## Vereisten

- **Node.js** op de host (voor `npx browser-sync@3`)
- **Tailscale** (voor remote access)
- **jq** (voor Tailscale hostname parsing)

Het script controleert bij opstarten of alle vereisten aanwezig zijn.

## Bestanden

| Bestand | Beschrijving |
|---------|-------------|
| `dev-reload.sh` | Start-script voor live-reload development server |
| `.claude/design/live-reload-setup.md` | Dit document |

## Opties browser-sync

| Optie | Waarde | Reden |
|-------|--------|-------|
| `--server` | `website` | Serveert bestanden direct uit website/ |
| `--files` | `website/**/*.{html,css,js}, assets/img/*` | Watched deze bestanden voor wijzigingen |
| `--port` | `3000` | Lokale poort voor browser-sync |
| `--no-open` | — | Opent geen lokale browser (je werkt remote) |
| `--no-notify` | — | Geen browser-sync notificatie-overlay |

## Hardening

| Maatregel | Beschrijving |
|-----------|-------------|
| Dependency checks | Controleert tailscale, jq, npx bij opstarten |
| Version pinning | `browser-sync@3` voorkomt onverwachte major upgrades |
| Cleanup trap | `trap cleanup EXIT` stopt Tailscale serve bij afsluiten |
