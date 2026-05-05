---
name: publish
description: Veilige wrapper rond ./scripts/publish.sh — dry-run is default, live vereist expliciete confirmation
area: deployment
provides:
  - site_publish
depends_on:
  - rules/response-format.md
---

# Publish

Wrap `./scripts/publish.sh` met fail-fast prereq-validatie, een verplichte confirmation-gate vóór `--live`, en exit-code → actionable mapping. Dry-run is altijd safe en default; live vereist een expliciete keuze van de gebruiker via choice-button.

## When to Use

- Gebruiker roept `/publish` aan met of zonder argumenten
- Gebruiker vraagt om de site naar mijn.host te pushen / deployen / publishen / live te zetten

## Inputs

Allemaal optioneel, white-space gescheiden in `$ARGUMENTS`:

- `target=<name>` — default `production`
- `live` — schakel echte deploy in (default: dry-run)
- `no-verify` — sla post-live curl-check over

Voorbeelden:

- `/publish` → dry-run naar production
- `/publish target=staging` → dry-run naar staging
- `/publish live` → live naar production (na confirmation)
- `/publish live no-verify` → live, geen post-deploy curl

## Algorithm

### Stap 1. Parse arguments

Zet `TARGET=production`, `LIVE=false`, `NO_VERIFY=false` als defaults. Loop door `$ARGUMENTS`:

- `target=...` → overschrijf `TARGET`
- `live` → `LIVE=true`
- `no-verify` → `NO_VERIFY=true`

Onbekende argumenten: meld en stop.

### Stap 2. Prereq-validatie (read-only)

Verifieer alles wat `publish.sh` nodig heeft, zonder iets te muteren:

```bash
test -f .env || echo "MISSING: .env (run: cp .env.example .env, dan invullen)"
set -a; source .env 2>/dev/null; set +a

REQUIRED=(PUBLISH_HOST PUBLISH_PORT PUBLISH_USER PUBLISH_KEY
          PUBLISH_REMOTE_BASE PUBLISH_REMOTE_DOCROOT
          SMTP_USER SMTP_PASS MAIL_FROM MAIL_TO)
for v in "${REQUIRED[@]}"; do
  val="${!v-}"
  if [[ -z "$val" || "$val" == your-* || "$val" == *placeholder* ]]; then
    echo "MISSING/PLACEHOLDER in .env: $v"
  fi
done

key=".publish/keys/${TARGET}/id_ed25519"
test -f "$key" || echo "MISSING: $key (run: ssh-keygen -t ed25519 -N '' -f $key)"
mode=$(stat -c '%a' "$key" 2>/dev/null || echo "")
[[ -z "$mode" || "$mode" == "600" ]] || echo "WRONG MODE ($mode): $key (run: chmod 600 $key)"
```

Bij ANY missing/wrong-mode item: print de fix-one-liners en STOP met choice-button. Toon nooit waarden — alleen veld-namen.

### Stap 3. Live-gate (alleen bij `LIVE=true`)

ALS `LIVE=true`: presenteer altijd choice-button en STOP. Ga niet door tot de gebruiker expliciet kiest.

```
Live deploy naar ${TARGET}? Dit schrijft naar de remote en kan stale files verwijderen.

Live deploy / Eerst dry-run / Cancel?
```

- Keuze "Live deploy" → ga naar stap 4 met `--live`
- Keuze "Eerst dry-run" → ga naar stap 4 zonder `--live`
- Keuze "Cancel" → stop met melding

### Stap 4. Run publish.sh

```bash
flag=$([[ "$LIVE" == "true" ]] && echo "--live" || echo "--dry-run")
./scripts/publish.sh "$flag" "--target=${TARGET}" 2>&1 | tee /tmp/publish.out
exit_code=${PIPESTATUS[0]}
```

### Stap 5. Exit-code mapping

| Code | Categorie | Volgende actie |
|------|-----------|----------------|
| 0 | succes | Stap 6 |
| 64 | arg/env-fout | Lees melding op laatste regel; meestal duplicaat van stap 2 |
| 65 | preflight blocked | Parse `category` en `detail`; tabel hieronder |
| 66 | lftp transfer-fout | Meestal: key niet (meer) geautoriseerd in DirectAdmin, of `remote_root` pad bestaat niet op de server |

#### Exit 65 — preflight category × detail

Lees `preflight blocked: <category> (<detail>)` op de laatste stderr-regel:

| Category | Detail | Actionable fix |
|----------|--------|----------------|
| `missing_publish_key` | `publish_dir_missing` | `.publish/` ontbreekt — install procedure runner-contract herhalen |
| `missing_publish_key` | `key_file_missing` | `ssh-keygen -t ed25519 -N '' -f .publish/keys/${TARGET}/id_ed25519` |
| `missing_publish_key` | `metadata_missing` | Re-run script — schrijft metadata zelf opnieuw |
| `missing_host_trust` | `host_not_in_known_hosts` | `rm .publish/known_hosts` en re-run; TOFU populeert opnieuw |
| `unsafe_remote_path` | `remote_root_unsafe` | Check `PUBLISH_REMOTE_BASE` / `PUBLISH_REMOTE_DOCROOT` in `.env` |
| `unsafe_remote_path` | `remote_root_outside_authorised` | `metadata.remote_root` valt buiten scope — coördineer met runner-admin |
| `corrupt_publish_volume` | `publish_dir_unreadable` | `chmod 0700 .publish && chmod 0600 .publish/keys/${TARGET}/id_ed25519 .publish/known_hosts` |
| `corrupt_publish_volume` | `metadata_unreadable` | `rm .publish/metadata/${TARGET}.json` en re-run |
| `invalid_key_scope` | `key_scope_mismatch` | Key uit ander project/target — controleer `PUBLISH_KEY` pad in `.env` |
| `unsafe_symlink` | `unsafe_symlink=<pad>` | Symlink wijst buiten project — verwijder of verplaats |

### Stap 6. Post-live verificatie

ALS `LIVE=true` én `NO_VERIFY=false` én `exit_code=0`:

```bash
http=$(curl -s -o /dev/null -w "%{http_code}" "https://groeiwijze.nl/")
echo "https://groeiwijze.nl/ → HTTP ${http}"
```

Vlag elke status ≠ 200 in het rapport.

### Stap 7. Report

Volg Output Format hieronder. Sluit altijd af met choice-button als laatste regel.

## Constraints

- **Nooit `--live` zonder choice-button confirmation.** Stap 3 is verplicht en niet over te slaan.
- **Nooit `.env` of `.publish/` muteren.** Skill is read-only — alleen `./scripts/publish.sh` schrijft state.
- **Nooit secret-waarden printen.** Bij missing/placeholder vermeld alleen veld-namen, geen values.
- **Idempotent.** Herhaalde aanroepen geven hetzelfde resultaat; geen toggle-state in de skill.
- **Onbekende args** afwijzen met heldere melding; niet stilzwijgend negeren.

## Stop Points

VERPLICHT — stop en wacht op de gebruiker wanneer:

- Stap 2 vindt missing/wrong-mode prereqs — toon fix-one-liners, vraag bevestiging
- Stap 3 is bereikt met `live` — vraag confirmation via choice-button
- Stap 5 retourneert exit ≠ 0 — toon actionable mapping, vraag vervolgkeuze

## Output Format

### Dry-run succesvol

```markdown
## Publish — Dry-run (${TARGET})

✓ Preflight ok
✓ Composer install
✓ Mirrors gesimuleerd: N transfers, M deletes (zie /tmp/publish.out)

Live deploy starten / Aanpassen / Done?
```

### Live succesvol + verified

```markdown
## Publish — Live (${TARGET})

✓ Preflight ok
✓ Mirrors voltooid
✓ https://groeiwijze.nl/ → HTTP 200

Site checken in browser / Done?
```

### Prereq failure

```markdown
## Publish — Prereq check failed

**Missing/placeholder:**
- ${field}
- ${field}

**Fix:**
- `${one-liner}`
- `${one-liner}`

Fix toepassen / Cancel / Done?
```

### Runtime failure (exit 65/66)

```markdown
## Publish — Failed (exit ${code})

**Categorie:** ${category}
**Detail:** ${detail}

**Fix:** ${one-liner uit mapping-tabel}

Fix toepassen / Cancel / Done?
```

## Definition of Done

- Argumenten geparseerd, onbekende afgewezen
- Prereq-validatie passed, of duidelijke missing-list met fix-one-liners
- Live-gate: choice-button confirmation gehad vóór `--live`
- `./scripts/publish.sh` aangeroepen met juiste flags
- Exit 0 → succesrapport (+ HTTP-verify bij live, tenzij `no-verify`)
- Exit ≠ 0 → actionable mapping geprint
- Laatste regel is een choice-button vraag
- Geen secrets geprint, geen state gemuteerd buiten het script
