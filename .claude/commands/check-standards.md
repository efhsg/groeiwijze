---
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(grep:*), Read, Grep
description: Snelle pre-flight check op gestaged bestanden tegen projectstandaarden
---

# Check Standards

Snelle screening van gestaged bestanden — vult `/review-changes` aan als pre-flight check.

## Staged bestanden

!`git diff --cached --name-only`

## Task

Lees elk gestaged bestand en doorloop de relevante checks. Geen volledige review — alleen evidente schendingen.

### CSS-bestanden (`*.css`)

| Check | Regel |
|-------|-------|
| Geen niet-palet hex | Alleen kleuren uit `rules/colors.md`; CSS custom properties verplicht |
| Geen magische spacing | Gebruik `--space-xs` t/m `--space-xxl` |
| BEM in selectors | Geen losse element-selectors zoals `header h1 a`; gebruik klassen |

Grep-patronen om te draaien:
- `#[0-9a-fA-F]\{3,8\}` in CSS — moet beperkt zijn tot palet-tokens
- Hex-waarden buiten `:root` declaratie — verdacht

### HTML-bestanden (`*.html`)

| Check | Regel |
|-------|-------|
| `lang="nl"` aanwezig | Op `<html>` element |
| Eén `<h1>` per pagina | Niet meer, niet minder |
| `alt`-attribuut op alle `<img>` | Decoratief = `alt=""`, informatief = beschrijvend |
| BEM klassen | Geen onderstrepen-niet-BEM, geen camelCase |
| Form labels | Elk `<input>` heeft `<label for="...">` |

### Content (in HTML)

Verboden woorden uit `rules/content.md`:
- `behandeling` (wel: begeleiding, traject)
- `patient` (wel: client, je, jij)
- urgentie-taal: "nu actie", "boek meteen", "nog X plekken"
- medische claims

### PHP (`contact-submit.php`)

| Check | Regel |
|-------|-------|
| Honeypot-veld | Aanwezig en server-side gecontroleerd |
| Tijdcheck | Min. 3 seconden tussen laden en submit |
| Rate limiting | Per-IP teller |
| Input sanitization | `filter_var()` of `htmlspecialchars()` op alle invoer |
| Geen credentials | SMTP-config niet inline |

## Output

Per bestand: bestandsnaam + gevonden issues (of "OK")

Slot:

```
## Samenvatting

**Gechecked:** N bestanden
**Issues gevonden:** M
**Klaar voor commit:** Ja / Nee — los eerst {N} kritieke items op

{Optioneel: voer /review-changes uit voor volledige review}
```

$ARGUMENTS
