# Custom Buttons in Prompts

Gebruik choice buttons om expliciete keuzes te geven in workflows. Claude Code detecteert deze automatisch aan het einde van een response en rendert klikbare knoppen.

## Preferred syntax: slash-separated

```
Optie1 / Optie2 / Optie3?
```

De regel moet de **laatste non-empty line** van de response zijn.

### Voorbeelden

```
Implementatie / Review ronde / Handmatig bewerken?
```

```
Akkoord met de aanpak? (Ja / Nee / Aanpassen)
```

```
Geen verbeterpunten — doorgaan / Aanpassen?
```

### Regels slash-syntax

| Regel | Detail |
|-------|--------|
| Separator | ` / ` (spatie-slash-spatie) |
| Aantal opties | 2-4 |
| Max lengte per optie | 80 tekens |
| Context-prefix | Tekst vóór `—` / `–` wordt gestript |
| Trailing `?` | Optioneel, wordt gestript |

## Alternatieve syntax: bracket-letter

```
[I] Start implementatie
[R] Nog een review ronde
[E] Handmatig bewerken
```

Gebruik bij meer dan 4 opties of als letter-codes nodig zijn.

### Regels bracket-syntax

| Regel | Detail |
|-------|--------|
| Patroon | `[X] Beschrijving` (hoofdletter) |
| Aantal opties | 2-5 |
| Max lengte beschrijving | 40 tekens |
| Positie | Opeenvolgende regels aan eind response |

## Gebruik in prompts

Plaats buttons altijd:
1. Als **laatste regels** van de response (geen tekst erna)
2. Na een samenvatting of vraag
3. Gevolgd door een expliciete wachtinstructie (in de prompt, niet in output)

## Edit-detectie

Opties met deze woorden krijgen een "edit" actie:
`bewerk`, `edit`, `aanpassen`, `modify`, `adjust`

## Best practices

| Regel | Voorbeeld |
|-------|-----------|
| Concrete acties | `Start implementatie` niet `Ga verder` |
| Slash preferred | `Doorvoeren / Aanpassen?` boven `[A] Doorvoeren` |
| Max 4 opties (slash) | Meer past niet; gebruik bracket voor 5 |

## Anti-patterns

**Fout — tekst na buttons:**
```
Implementatie / Review?
Laat me weten wat je wilt.
```

**Goed — buttons als laatste:**
```
Laat me weten wat je wilt.

Implementatie / Review?
```

## Context → button-pattern mapping

| Context | Buttons |
|---------|---------|
| Na analyse | `Start {actie} / Plan aanpassen?` |
| Fase-overgang | `Volgende stap / Review / Aanpassen?` |
| Afsluiting | `Commit wijzigingen / Aanpassen?` |
| Review met verbeterpunten | `Doorvoeren / Aanpassen / Overslaan?` |
| Review zonder verbeterpunten | `Geen verbeterpunten — doorgaan / Aanpassen?` |
