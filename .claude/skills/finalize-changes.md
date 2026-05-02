---
name: finalize-changes
description: Review checklist doorlopen en commitbericht voorstellen
area: workflow
provides:
  - change_finalization
depends_on:
  - rules/workflow.md
---

# Finalize Changes

Bereid wijzigingen voor op commit: doorloop de review checklist, archiveer eventuele design docs, en stel een commitbericht voor. Commit nooit autonoom — wacht altijd op expliciete bevestiging.

## When to Use

- Na een complete wijziging, vóór committen — de laatste stap
- Typisch na `/review-changes` met status PASS of PASS WITH COMMENTS
- Gebruiker roept `/finalize-changes` aan

## Inputs

Geen verplichte inputs — werkt op de huidige working tree.

## Algorithm

### Stap 1. Identificeer gewijzigde bestanden

```bash
git status --porcelain
git diff --stat
```

### Stap 2. Doorloop de review checklist

**VERPLICHT** — Lees elk gewijzigd HTML/CSS/JS bestand volledig vóór beoordeling.

Controleer per gewijzigd bestand:

- [ ] **Kleuren** — alleen Duin Harmonie palet, via CSS custom properties (`rules/colors.md`)
- [ ] **BEM** — CSS-klassen in Block-Element-Modifier patroon (`rules/html-css.md`)
- [ ] **Responsive** — mobile-first, juiste breakpoints (480px / 768px / 1024px)
- [ ] **Accessibility** — WCAG 2.1 AA: alt-teksten, form labels, focus, heading hierarchie (`rules/accessibility.md`)
- [ ] **Content toon** — Nederlands, warm, nuchter, niet-medisch, geen verboden woorden (`rules/content.md`)
- [ ] **Page template** — consistente structuur (DOCTYPE, lang="nl", semantische HTML)

Bij PHP-wijzigingen ook:
- [ ] **Security** — honeypot, tijdcheck, rate limiting, input sanitization (`rules/security.md`)

Rapporteer per check: ✓ of ✗ met `bestand:regel — beschrijving`.

### Stap 3. Archiveer design directory (indien aanwezig)

1. Bepaal huidige branch: `git branch --show-current`
2. Controleer of `.ai/features/[feature-naam]/` bestaat
3. Zo ja, vraag:

```
Feature directory '.ai/features/{naam}' gevonden — Archiveren / Overslaan?
```

**STOP. Wacht op gebruikersinput. Ga niet door naar stap 4.**

### Stap 4. Stel commitbericht voor

```bash
git add -A
git status
git diff --staged
```

Stel een commitbericht voor per `rules/workflow.md` (commits):

```
PREFIX: korte imperatieve beschrijving (~70 tekens)
```

Voer `git commit` **niet** uit — wacht op bevestiging.

Als checklist doorstaan:

```
Commit met /commit-push / Aanpassen?
```

**Wacht op gebruikersinput. Ga niet door totdat de gebruiker reageert.**

## Output Format

```
## Finalize Changes — Summary

**Review checklist:** ✓ doorstaan | ✗ N issues — zie stap 2 rapport
**Design archive:** {pad gearchiveerd | overgeslagen | geen match}

**Voorgesteld commitbericht:** {PREFIX}: {korte imperatieve beschrijving}

Commit met /commit-push / Aanpassen?
```

## Stop Points

**VERPLICHT** — Stop en vraag de gebruiker wanneer:

- Checklist-items mislukken in stap 2 — rapporteer issues, stel voor te fixen vóór commit
- Design directory gevonden in stap 3 — vraag archivering; termineer response onmiddellijk
- Commitbericht voorgesteld in stap 4 — voer `git commit` nooit autonoom uit

## Definition of Done

- Alle gewijzigde bestanden gecheckt tegen de review checklist
- Design directory archivering overwogen; gebruikerskeuze gevolgd
- Commitbericht voorgesteld per `rules/workflow.md`
- Sluitende slash-vraag gepresenteerd, wachtend op gebruikersgoedkeuring
- Geen `git commit` autonoom uitgevoerd
