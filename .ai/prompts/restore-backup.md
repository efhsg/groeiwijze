## Restore project backup

Zet een website backup terug vanuit `_archive/`.

- **Locatie:** Werk vanuit `/projects/groeiwijze.nl/` (persistent volume). Schrijf nooit naar `/home/esg/`.
- **Veiligheid:** Controleer backup integriteit voordat je terugzet. Maak eerst een safety backup van de huidige situatie.

---

## Stap 1 — Toon beschikbare backups

Lijst alle backup bestanden in `_archive/`, gesorteerd op datum (nieuwste eerst):

```bash
ls -1t _archive/website-backup_*.zip 2>/dev/null | head -n 10
```

Als er geen backups zijn, stop en meld dit aan de gebruiker.

---

## Stap 2 — Gebruiker laat backup selecteren

Toon de lijst in een leesbare vorm met nummering:

```
Beschikbare backups:

1. website-backup_2026-01-31-12:42.zip  (31 jan 2026, 12:42)
2. website-backup_2026-01-30-09:15.zip  (30 jan 2026, 09:15)
3. website-backup_2026-01-29-18:30.zip  (29 jan 2026, 18:30)
...

Welke backup wil je terugzetten? (voer nummer of bestandsnaam in)
```

Gebruik **AskUserQuestion** om de keuze te krijgen.

---

## Stap 3 — Controleer backup integriteit

Test of het zip-bestand geldig is:

```bash
unzip -t _archive/[GEKOZEN_BACKUP].zip
```

Als dit faalt, stop en meld dat de backup corrupt is.

---

## Stap 4 — Maak safety backup van huidige situatie

Voordat je terugzet, maak een automatische safety backup:

```bash
date +%Y-%m-%d-%H:%M
```

```bash
mkdir -p _archive && zip -r _archive/safety-backup_YYYY-MM-DD-HH:MM.zip . \
  -x "./_archive/*" "./.git/*" "./vendor/*" "./node_modules/*"
```

Bevestig aan gebruiker: "Safety backup aangemaakt: `safety-backup_YYYY-MM-DD-HH:MM.zip`"

---

## Stap 5 — Schoon huidige website op

Verwijder alle bestanden **behalve** `.git/` en `_archive/`:

```bash
find . -maxdepth 1 -not -name '.' -not -name '..' \
  -not -name '.git' -not -name '_archive' -exec rm -rf {} +
```

**Let op:** Dit commando is destructief. De safety backup uit stap 4 is essentieel.

---

## Stap 6 — Pak backup uit

Zet de gekozen backup terug:

```bash
unzip -q _archive/[GEKOZEN_BACKUP].zip -d .
```

---

## Stap 7 — Controleer resultaat

Verifieer dat belangrijke bestanden aanwezig zijn:

```bash
ls -la website/ docker/ CLAUDE.md 2>/dev/null
```

---

## Stap 8 — Herstart services (optioneel)

Als Docker containers draaien, herstart ze:

```bash
docker compose ps
```

Als er actieve containers zijn:

```bash
docker compose restart
```

Als er geen containers draaien, geef dit aan de gebruiker met suggestie:

```
Services zijn niet actief. Start handmatig met:
docker compose up -d
```

---

## Stap 9 — Terugkoppeling aan gebruiker

Geef een heldere samenvatting:

```
✓ Backup terugzetten voltooid

Hersteld vanaf:  website-backup_2026-01-31-12:42.zip
Safety backup:   safety-backup_2026-01-31-14:20.zip
Services:        Herstart (of "Niet actief — start handmatig")

Belangrijke bestanden gecontroleerd:
  ✓ website/
  ✓ docker/
  ✓ CLAUDE.md

De website staat nu in de staat van [DATUM TIJD uit backup naam].
```

---

## Safety notes

- De safety backup in stap 4 is **verplicht** — sla dit nooit over
- Controleer altijd backup integriteit (stap 3) voordat je terugzet
- Bewaar safety backups; deze kunnen later handmatig verwijderd worden
- Bij twijfel: stop en vraag gebruiker om bevestiging voordat je terugzet
