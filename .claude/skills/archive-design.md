---
name: archive-design
description: Archiveer een feature directory naar .ai/features/.archive/
area: workflow
provides:
  - design_archival
depends_on: []
---

# Archive Design

Verplaats een voltooide feature directory naar `.ai/features/.archive/` zodat de werkruimte overzichtelijk blijft.

## When to Use

- Na het voltooien van een feature of fix waarvan een feature directory bestaat
- Aangeroepen vanuit `/finalize-changes` na gebruikersgoedkeuring
- Gebruiker roept `/archive-design` aan

## Inputs

- `$ARGUMENTS`: naam of pad van de feature directory (optioneel)

## Algorithm

### 1. Bepaal te archiveren item

**Als `$ARGUMENTS` opgegeven:** gebruik als naam (bijv. `site-structuur` of `.ai/features/site-structuur`).

**Als `$ARGUMENTS` leeg:** toon beschikbare feature directories en vraag:

```bash
ls -1 .ai/features/ 2>/dev/null | grep -v '^\.archive$'
```

Presenteer als genummerde lijst en vraag welke gearchiveerd moet worden.

### 2. Valideer het item

1. Resolve pad: als naam opgegeven zonder prefix → `.ai/features/{naam}`
2. Bestaat het pad? Zo niet → meld "Niet gevonden: `{pad}`" en stop
3. Is het al gearchiveerd (staat in `.ai/features/.archive/`)? → meld "Al gearchiveerd" en stop
4. Doelopad: `.ai/features/.archive/{naam}`
5. Bestaat doelopad al? → meld conflict en stop

### 3. Archiveer

```bash
mkdir -p .ai/features/.archive
git mv ".ai/features/{naam}" ".ai/features/.archive/{naam}"
```

Als git mv mislukt (niet in git repository of niet getrackt):

```bash
mv ".ai/features/{naam}" ".ai/features/.archive/{naam}"
```

### 4. Rapporteer

```
Gearchiveerd: .ai/features/{naam} → .ai/features/.archive/{naam}
```

## Definition of Done

- Feature directory is verplaatst naar `.archive/`
- Rapportage toont bron en doel
- Geen bestanden verwijderd — alleen verplaatst
