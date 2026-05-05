---
name: publish
description: Publiceer groeiwijze.nl naar mijn.host — voorbeeld eerst, dan bevestiging vóór de echte publicatie. Output in mensentaal voor niet-technische gebruikers.
area: deployment
provides:
  - site_publish
depends_on:
  - rules/response-format.md
---

# Publish

Wrap `./scripts/publish.sh` met een veilig voorbeeld-eerst proces, een verplichte bevestiging vóór een echte publicatie, en meldingen in mensentaal. De gebruiker is niet-technisch — vermijd jargon zoals "dry-run", "live", "preflight", "mirror", "transfers" of "exit code" in alle zichtbare output.

## When to Use

- Gebruiker roept `/publish` aan met of zonder argumenten
- Gebruiker vraagt om de site te publiceren, bij te werken of live te zetten op mijn.host

## Inputs

Allemaal optioneel, white-space gescheiden in `$ARGUMENTS`:

- `live` — schakel echte publicatie in (default: alleen voorbeeld)
- `target=<name>` — default `production`
- `no-verify` — sla bereikbaarheidstest na publicatie over

Voorbeelden:

- `/publish` → voorbeeld bekijken (er verandert niets aan de site)
- `/publish live` → site echt bijwerken (na bevestiging)

## Algorithm

### Stap 1. Argumenten lezen

Zet `TARGET=production`, `LIVE=false`, `NO_VERIFY=false` als defaults. Loop door `$ARGUMENTS`:

- `target=...` → overschrijf `TARGET`
- `live` → `LIVE=true`
- `no-verify` → `NO_VERIFY=true`

Onbekend argument: stop met de "Onbekend argument"-output (zie Output Format).

### Stap 2. Controle vooraf (read-only)

Verifieer alles wat `publish.sh` nodig heeft, zonder iets te muteren:

```bash
test -f .env || echo "MISSING_ENV"
set -a; source .env 2>/dev/null; set +a

REQUIRED=(PUBLISH_HOST PUBLISH_PORT PUBLISH_USER PUBLISH_KEY
          PUBLISH_REMOTE_BASE PUBLISH_REMOTE_DOCROOT
          SMTP_USER SMTP_PASS MAIL_FROM MAIL_TO)
for v in "${REQUIRED[@]}"; do
  val="${!v-}"
  if [[ -z "$val" || "$val" == your-* || "$val" == *placeholder* ]]; then
    echo "MISSING_FIELD: $v"
  fi
done

key=".publish/keys/${TARGET}/id_ed25519"
test -f "$key" || echo "MISSING_KEY"
mode=$(stat -c '%a' "$key" 2>/dev/null || echo "")
[[ -z "$mode" || "$mode" == "600" ]] || echo "WRONG_KEY_MODE"
```

Bij ontbrekende of verkeerde items: vertaal via de tabel onder Stap 5 en STOP met de "Iets ontbreekt vooraf"-output. Toon nooit waarden — alleen veldnamen.

### Stap 3. Bevestiging vóór echte publicatie

ALS `LIVE=true`: stel altijd de keuzeknop voor en STOP. Ga niet door tot de gebruiker expliciet kiest:

```
Wil je de site nu echt bijwerken op groeiwijze.nl?
Dit overschrijft bestanden op de live site.

Echt publiceren / Eerst voorbeeld / Stoppen?
```

- "Echt publiceren" → ga naar Stap 4 met `--live`
- "Eerst voorbeeld" → ga naar Stap 4 zonder `--live`
- "Stoppen" → meld kort dat er niets is veranderd

Uitzondering: als de skill in dezelfde sessie net een voorbeeld heeft getoond en de gebruiker daar via de keuzeknop "Echt publiceren" koos, telt die keuze als bevestiging. Vraag niet opnieuw.

### Stap 4. Script aanroepen

Redirect alle scriptoutput naar een logbestand; toon zelf alleen de samenvatting.

```bash
flag=$([[ "$LIVE" == "true" ]] && echo "--live" || echo "--dry-run")
./scripts/publish.sh "$flag" "--target=${TARGET}" > /tmp/publish.log 2>&1
exit_code=$?
```

### Stap 5. Resultaat vertalen

| Code | Mens-leesbare melding |
|------|----------------------|
| 0 | Klaar — ga naar Stap 6 |
| 64 | "Er ontbreekt iets in de instellingen." Gebruik vertaaltabel hieronder. |
| 65 | "Er kan nog niet gepubliceerd worden." Gebruik vertaaltabel hieronder. |
| 66 | "De verbinding met de server werkt niet meer. Vraag de beheerder om je toegang opnieuw te bevestigen." |

#### Vertaaltabel — intern signaal naar mensentaal

Lees voor exit 65 de regel `preflight blocked: <category> (<detail>)` uit `/tmp/publish.log`.

| Intern signaal | Wat zeg je tegen de gebruiker | Wat is de vervolgstap |
|----------------|------------------------------|----------------------|
| `MISSING_ENV` | "Het instellingenbestand `.env` bestaat nog niet." | "Kopieer `.env.example` naar `.env` en vul de gegevens in." |
| `MISSING_FIELD: <veld>` | "Er ontbreekt iets in de instellingen: `<veld>`." | "Open `.env` en vul `<veld>` in." |
| `MISSING_KEY` of `missing_publish_key` | "Er is nog geen toegangssleutel voor de server." | "Vraag de beheerder om de sleutel opnieuw in te stellen." |
| `WRONG_KEY_MODE` of `corrupt_publish_volume` | "Een toegangsbestand op je computer is beschadigd of staat verkeerd." | "Vraag de beheerder om de installatie opnieuw uit te voeren." |
| `missing_host_trust` | "De server is gewisseld of nog niet vertrouwd." | "Vraag de beheerder om de host-bevestiging opnieuw te doen." |
| `unsafe_remote_path` | "Het opgegeven pad op de server klopt niet." | "Controleer de server-instellingen in `.env`." |
| `invalid_key_scope` | "De sleutel hoort bij een ander project of doel." | "Controleer de server-instellingen in `.env`." |
| `unsafe_symlink` | "Er staat een verwijzing in het project die buiten het project wijst." | "Verwijder of verplaats deze verwijzing." |

Vermeld onderaan elke foutmelding: "Volledige technische details staan in `/tmp/publish.log`."

### Stap 6. Bereikbaarheidstest

ALS `LIVE=true` én `NO_VERIFY=false` én `exit_code=0`:

```bash
http=$(curl -s -o /dev/null -w "%{http_code}" "https://groeiwijze.nl/")
```

Status 200 → "Site bereikbaar". Anders → "De site reageert nog niet zoals verwacht (HTTP `<code>`). Wacht een minuut en herlaad."

### Stap 7. Rapporteren

Volg Output Format hieronder. Tellingen voor het rapport haal je uit `/tmp/publish.log`:

```bash
transfers=$(grep -cE "^Transferring file" /tmp/publish.log)
removes=$(grep -cE "^Removing old file" /tmp/publish.log)
```

Gebruik `transfers` als "bestanden bijgewerkt". Vermeld verwijderingen alleen als `removes > transfers + 5` — dan toon je een waarschuwing ("`<X>` bestanden zijn ook van de site verwijderd; controleer of dit klopt").

Sluit altijd af met een keuzeknop als laatste regel.

## Constraints

- **Schrijf alle zichtbare tekst in mensentaal.** Geen "dry-run", "live", "preflight", "mirror", "transfers", "exit code" of "lftp" in de output.
- **Nooit `--live` zonder bevestiging via keuzeknop.** Stap 3 is verplicht en niet over te slaan.
- **Nooit `.env` of `.publish/` muteren.** Skill is read-only — alleen `./scripts/publish.sh` schrijft state.
- **Nooit waarden van geheime velden tonen.** Bij missing/placeholder vermeld alleen veldnamen.
- **Verberg ruwe scriptoutput.** Redirect naar `/tmp/publish.log`. Verwijs daar alleen naar bij fouten.
- **Idempotent.** Herhaalde aanroepen geven hetzelfde resultaat.

## Stop Points

VERPLICHT — stop en wacht op de gebruiker wanneer:

- Stap 2 vindt iets ontbrekends — toon mensentaal-melding + vervolgstap, vraag keuze
- Stap 3 is bereikt met `live` — vraag bevestiging via keuzeknop
- Stap 5 retourneert exit ≠ 0 — toon mensentaal-melding + vervolgstap

## Output Format

### Voorbeeld klaar (geen wijziging op de site)

```markdown
## Voorbeeld klaar

Ik heb gecontroleerd wat er zou veranderen op groeiwijze.nl:

  • ${transfers} bestanden zouden worden bijgewerkt
  • Geen onverwachte verwijderingen

Er is niets aan de live site veranderd.

Echt publiceren / Eerst nog kijken / Stoppen?
```

### Site is bijgewerkt en bereikbaar

```markdown
## Site is bijgewerkt

  ✓ ${transfers} bestanden geüpload
  ✓ Site bereikbaar (https://groeiwijze.nl/)

Klaar. Eventueel kun je in je browser nog even rondkijken.

Site openen / Klaar?
```

### Site is bijgewerkt maar reageert niet zoals verwacht

```markdown
## Site is bijgewerkt

  ✓ ${transfers} bestanden geüpload
  ⚠ De site reageert nog niet zoals verwacht (HTTP ${http})

Wacht een minuut en herlaad de site. Komt het probleem niet vanzelf goed, vraag dan om hulp.

Opnieuw testen / Klaar?
```

### Iets ontbreekt vooraf

```markdown
## Er kan nog niet gepubliceerd worden

${mens-leesbare melding uit vertaaltabel}

**Wat je kunt doen:** ${vervolgstap}

Volledige technische details staan in `/tmp/publish.log`.

Opnieuw proberen / Stoppen?
```

### Onbekend argument

```markdown
## Ik begrijp het commando niet helemaal

Het woord `${arg}` herken ik niet als optie. Bedoelde je:

  • `/publish` — voorbeeld bekijken
  • `/publish live` — site echt publiceren

Voorbeeld bekijken / Echt publiceren / Stoppen?
```

## Definition of Done

- Argumenten gelezen; onbekende afgewezen in mensentaal
- Controle vooraf is geslaagd, of er staat een duidelijke melding wat ontbreekt
- Bij echte publicatie: keuzeknop-bevestiging gehad vóór `--live`
- `./scripts/publish.sh` aangeroepen met juiste flags, output naar `/tmp/publish.log`
- Bij succes: mens-leesbaar succesrapport (+ bereikbaarheidstest bij echte publicatie, tenzij `no-verify`)
- Bij fout: mens-leesbare melding + vervolgstap; verwijs naar `/tmp/publish.log` voor details
- Laatste regel is een keuzeknop
- Geen jargon, geen geheimen, geen wijziging buiten het script
