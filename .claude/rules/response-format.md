# Response Format

## Gesloten vragen — custom-buttons syntax

Elke gesloten vraag (keuze, ja/nee, bevestiging) MOET:

1. Als **laatste regel** van de response staan
2. Slash-syntax gebruiken voor 2-4 opties: `Optie1 / Optie2 / Optie3?`
3. Of bracket-syntax voor 5 of meer opties op aparte regels: `[A] Optie`
4. Geen tekst na de opties

Responses worden als klikbare buttons gerenderd. Bullet-lists, numbered lists en open vragen leveren geen buttons.

## Anti-patterns — niet gebruiken

Bullet-list:
```
Wat wil je doen?
- Implementatie
- Review
- Bewerken
```

Numbered list:
```
1. **Start implementatie** — plan opstellen
2. **Review ronde** — nieuwe iteratie

Wat wil je nu doen?
```

Open vraag zonder opties:
```
Akkoord met de aanpak, of wil je nog iets aanpassen?
```

Zie `.claude/skills/custom-buttons.md` voor volledige detectielogica.
