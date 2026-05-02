## Backup project

Maak een backup zip van het project in `_archive/`.

- **Locatie:** Werk vanuit `/projects/groeiwijze.nl/` (persistent volume). Schrijf nooit naar `/home/esg/`.
- **Bestandsnaam:** `website-backup_YYYY-MM-DD-HH:MM.zip`
- **Exclude:** `_archive/`, `.git/`, `vendor/`, `node_modules/`

**Stap 1** — Timestamp ophalen:

```bash
date +%Y-%m-%d-%H:%M
```

**Stap 2** — Zip aanmaken (vervang `YYYY-MM-DD-HH:MM` door output van stap 1):

```bash
mkdir -p _archive && zip -r _archive/website-backup_YYYY-MM-DD-HH:MM.zip . \
  -x "./_archive/*" "./.git/*" "./vendor/*" "./node_modules/*"
```
