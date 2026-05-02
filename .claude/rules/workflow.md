# Workflow & Conventies

## Voordat je codeert

1. Lees de relevante bestanden in `.claude/rules/`
2. Scan `.claude/skills/index.md` voor een relevante skill
3. Bekijk bestaande code en patronen voordat je wijzigt

## Feature directory

Voor complexe features, gebruik een feature directory:

```
.ai/features/[feature-naam]/
  spec.md       # Functionele specificatie (zie .claude/templates/feature-spec.md)
  plan.md       # Aanpak, keuzes, afwegingen
  insights.md   # Bevindingen tijdens research
```

Genereren via `/new-spec {naam}`. Algemene design-documenten (geen feature) blijven in `.claude/design/`.

## Implementatiegeheugen — todos.md

Bij langere implementaties, houd voortgang bij:

```
.ai/features/[feature-naam]/
  plan.md       # Aanpak en keuzes
  todos.md      # Stappenchecklist
  insights.md   # Bevindingen en afwijkingen
```

### Werkwijze todos.md — VERPLICHT

Als een `todos.md` bestaat voor de huidige taak, is het de **gezaghebbende checklist**. Volg deze regels:

1. **Sessiestart / context-hervatting:** Lees `todos.md` eerst. Bepaal welke taken `[x]` (klaar) zijn en welke `[ ]` (open). Hervat bij de eerste open taak.
2. **Werk op volgorde:** Voltooi taken sequentieel zoals opgesomd. Sla niet vooruit.
3. **Markeer direct als klaar:** Na het voltooien van een taak, werk de checkbox bij naar `[x]` **vóórdat** je aan de volgende begint.
4. **Werk nooit zonder bij te werken:** Als je werk doet, moet de checklist dit weerspiegelen.
5. **Context-hervatting:** Na context-compressie is `todos.md` het herstelpunt. Lees het, vertrouw de checkboxes, hervat bij de eerste open taak.

## Commit conventies

Prefix | Gebruik
-------|--------
`ADD:` | Nieuwe feature of bestand
`CHG:` | Wijziging aan bestaande functionaliteit
`FIX:` | Bugfix
`DEL:` | Verwijdering
`TXT:` | Tekstuele/copy wijziging (geen code)
`DOC:` | Documentatie

- Imperatief: "ADD: contactformulier validatie" (niet "Added...")
- Max ~70 tekens
- Nederlands of Engels, consistent per commit

## Review checklist

Controleer voor elke wijziging:

- [ ] Kleuren uit goedgekeurd palet (`rules/colors.md`)
- [ ] BEM naamgeving (`rules/html-css.md`)
- [ ] Responsive: werkt op mobiel en desktop
- [ ] Accessibility basics (`rules/accessibility.md`)
- [ ] Content toon klopt (`rules/content.md`)
- [ ] Page template structuur consistent
