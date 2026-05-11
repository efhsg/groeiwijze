---
name: note
description: Schrijf een AI Note in het lopende PromptManager-project via de wrapper-tool van deze run
area: workflow
provides:
  - ai_note_creation
depends_on: []
---

# Note

Maak een top-level **AI Note** in het PromptManager-project waarin deze run draait, door de wrapper-tool aan te roepen die de runner aan deze sessie heeft toegevoegd.

## When to Use

- Gebruiker roept `/note` aan met optionele titel/samenvatting als argument
- Een belangrijke beslissing, bevinding of milestone moet vastgelegd worden zodat de eigenaar het later terugvindt in PromptManager
- De gebruiker zegt "leg dit vast", "schrijf dit op als note", "save this finding"

## Voorwaarden

Deze skill werkt alleen als de runner een wrapper-tool heeft geïnjecteerd. Check dat eerst:

1. Lees de system-prompt-instructies van deze run en zoek naar het blok dat begint met `You may create one top-level PromptManager AI Note`.
2. Onder dat blok staat een `Command:`-header gevolgd door een regel met het absolute wrapper-pad (eindigend op `.sh`) en een heredoc-voorbeeld in een `<<'JSON' ... JSON`-blok.
3. Zonder dat blok is de wrapper niet beschikbaar — meld dat en stop.

Mogelijke redenen dat de wrapper er niet is:

- `Project.ai_notes_enabled = false` voor dit project in PromptManager
- De provider van deze run ondersteunt geen wrapper-injectie (alleen Claude, Codex en Gemini; Ollama via LocalClaudeProvider niet)
- De run draait buiten PromptManager (lokale CLI-sessie zonder runner-context)

Als de instructies wel aanwezig zijn maar de wrapper-aanroep faalt of een approval-prompt levert, ligt het waarschijnlijk aan de approval-mode van de provider:

- **Claude:** werkt altijd autonoom — de allowlist regelt het
- **Codex:** werkt autonoom in `full-auto` (default) en `auto-edit`; `suggest` vereist user-approval per call
- **Gemini:** werkt autonoom in `yolo` (default); `default`, `auto_edit` en `plan` blokkeren of vragen approval voor shell-exec

## Algorithm

### Stap 1 — Wrapper-pad ophalen

Extract de absolute pad-string uit het `Command:`-blok in de system-prompt-instructies. Het pad eindigt op `.sh` en bevat `ai-runner-note-contexts/create_ai_note-`. Onthoud het letterlijke absolute pad — dat moet je in stap 4 als beginstring van het Bash-commando gebruiken.

### Stap 2 — Titel bepalen

- Als `$ARGUMENTS` niet leeg is en op de eerste regel een korte string staat: gebruik die als titel (max 80 chars).
- Anders: leid de titel af uit de huidige context. Geen vragen stellen tenzij de context echt onduidelijk is.
- Titel-conventies:
  - Action-oriented: "Beslissing: X", "Bevinding: Y", "Plan: Z"
  - Geen punt aan het eind
  - Geen markdown
  - Geen lange uitleg — dat hoort in de body

### Stap 3 — Body opstellen (Quill Delta JSON)

Een Quill Delta is `{"ops":[{"insert":"<tekst>\n"}, ...]}`. Voor headers en lijsten:

```json
{"ops":[
  {"insert":"Sectie kop"},
  {"insert":"\n","attributes":{"header":2}},
  {"insert":"Eerste alinea met de kern.\n"},
  {"insert":"Bullet 1"},
  {"insert":"\n","attributes":{"list":"bullet"}},
  {"insert":"Bullet 2"},
  {"insert":"\n","attributes":{"list":"bullet"}}
]}
```

Body-conventies:

- Wat is besloten/gevonden? (1-3 zinnen)
- Waarom — welke trade-off of constraint maakt dit relevant later?
- Concreet vervolg, indien van toepassing — bestand, sectie, of taakomschrijving
- Geen credentials, tokens, klantdata of identifiers van andere projecten
- Geen letterlijke overname van AI-prompt — schrijf voor de eigenaar die dit later terugleest

### Stap 4 — Wrapper aanroepen

Roep de wrapper aan met het **letterlijke absolute pad** als beginstring van het Bash-commando, gevolgd door de JSON-envelope op stdin via een heredoc:

```bash
/runtime/ai-runner-note-contexts/create_ai_note-XXXXX.sh <<'JSON'
{"name":"<titel>","content_delta":{"ops":[...]}}
JSON
```

Vervang het pad in het voorbeeld door het pad dat je in stap 1 hebt opgehaald.

Maak geen tijdelijk shellscript, testscript, alias, variabele-wrapper of helperbestand. De Bash-call zelf moet direct met het absolute wrapper-pad beginnen en de JSON-envelope via stdin doorgeven.

**Belangrijk voor Claude (enforced model):** gebruik het letterlijke pad als eerste token van het commando. Begin niet met een variabele-toewijzing (`WRAPPER=...; "$WRAPPER" ...`) — Claude's allowlist matcht op de pad-prefix `Bash(<absoluut-pad>:*)`, dus elk commando dat met iets anders begint wordt geweigerd.

Gebruik de heredoc-vorm `<<'JSON' ... JSON` met enkele aanhalingstekens — dat schakelt shell-interpolatie uit zodat de JSON-content letterlijk wordt doorgegeven.

De wrapper logt zelf naar PromptManager; de output is JSON op stdout.

### Stap 5 — Response interpreteren

| Stdout | Betekenis |
|--------|-----------|
| `{"success":true,"note_id":<int>}` | Note opgeslagen — meld de note_id aan de gebruiker |
| `{"success":false,"error_code":"invalid_payload",...}` | JSON-envelope is fout — controleer titel niet leeg en `content_delta.ops` is een array |
| `{"success":false,"error_code":"payload_too_large",...}` | Body > 1 MiB — kort de body in en probeer opnieuw |
| `{"success":false,"error_code":"invalid_context",...}` | Runner-context is verlopen of corrupt — meld dit, niet opnieuw proberen |
| `{"success":false,"error_code":"not_authorized",...}` | Wrapper-autorisatie geweigerd — meld dit, niet opnieuw proberen |
| `{"success":false,"error_code":"create_failed",...}` | Validatie-fout in PromptManager (titel te lang, ongeldige content) — kort de titel in (max 255 chars) en probeer opnieuw |

## Output Format

Bij success:

```markdown
**AI Note opgeslagen** — id `<note_id>`, titel "`<titel>`"
```

Bij failure:

```markdown
**AI Note niet opgeslagen** — `<error_code>`: `<korte reden>`
```

Geen choice-buttons aan het eind tenzij de gebruiker een keuze moet maken (bijv. retry-actie na recoverable error).

## Definition of Done

- Wrapper-pad gevonden in system-prompt-instructies (of skill stopt met heldere melding)
- Titel ≤ 80 chars, body is geldige Quill Delta JSON
- Geen credentials/tokens/klantdata in de body
- Wrapper direct aangeroepen zonder tijdelijk script, helperbestand, alias of variabele-wrapper
- Response geïnterpreteerd
- Eigen output is één regel; geen overbodige uitleg
