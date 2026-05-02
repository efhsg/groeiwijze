---
name: refactor
description: Structurele verbeteringen in HTML/CSS/JS zonder gedragswijziging
area: workflow
depends_on:
  - rules/html-css.md
  - rules/colors.md
---

# Refactor

Voer structurele verbeteringen door zonder zichtbaar gedrag te wijzigen.

## When to Use

- Gebruiker vraagt een specifiek bestand of stuk code te refactoren
- Na een feature-implementatie om code op te schonen
- Om duplicatie te verminderen die in een review is gevonden

## Inputs

- `scope`: bestandspad of directory om te refactoren (verplicht)

## Constraints

Niet-onderhandelbaar:

1. **Geen gedragswijziging** — visuele output en functionaliteit blijven identiek
2. **DRY** — alleen toepassen om daadwerkelijke duplicatie te elimineren; stop als het doel bereikt is
3. **Geen features, geen bugfixes** — puur structuur
4. **BEM blijft geldig** — na refactor moeten alle klassen nog steeds BEM-conform zijn
5. **Kleurenpalet intact** — geen CSS custom properties veranderen of introduceren buiten het Duin Harmonie palet

## Algorithm

1. Lees het doelbestand volledig
2. Identificeer refactoringkansen:
   - **CSS** — dubbele declaraties → gedeelde klasse of custom property; magische getallen → spacing/color token; lange selectors → BEM-element
   - **HTML** — herhalende structuren → consistent sjabloon; inconsistente naamgeving → uniform BEM-patroon
   - **JS** — dubbele event handlers → gedeelde functie; inline logica → benoemde functie
3. Noteer de huidige visuele staat (welke elementen zijn zichtbaar, hoe gedragen ze zich)
4. Pas refactoring toe
5. Vergelijk: alle elementen nog steeds aanwezig? Stijlen visueel gelijk?
6. Run review-checklist mentaal:
   - Kleuren via CSS custom properties?
   - BEM naamgeving intact?
   - Responsive breakpoints intact?

## Refactoring Patronen

### CSS — Duplicatie samenvoegen

```css
/* Voor */
.hero__title { color: #3E4444; font-size: clamp(1.5rem, 3vw, 2.5rem); }
.section__title { color: #3E4444; font-size: clamp(1.5rem, 3vw, 2.5rem); }

/* Na */
.hero__title,
.section__title { color: var(--color-text); font-size: clamp(1.5rem, 3vw, 2.5rem); }
```

### CSS — Magisch getal naar token

```css
/* Voor */
.card { padding: 24px; margin-bottom: 16px; }

/* Na */
.card { padding: var(--space-lg); margin-bottom: var(--space-md); }
```

### JS — Dubbele handler → gedeelde functie

```js
// Voor
document.querySelector('.btn-a').addEventListener('click', () => { toggle(); updateUI(); });
document.querySelector('.btn-b').addEventListener('click', () => { toggle(); updateUI(); });

// Na
function handleToggle() { toggle(); updateUI(); }
document.querySelector('.btn-a').addEventListener('click', handleToggle);
document.querySelector('.btn-b').addEventListener('click', handleToggle);
```

## Output Format

```
## Refactoring Summary

**Bestanden gerefactord:** N
- `website/css/style.css`

**Wijzigingen:**
- Dubbele color declaraties samengevat in gedeelde selector (3x)
- Magisch getal 24px vervangen door var(--space-lg) (5x)

**Visuele controle:** identiek — geen zichtbare wijzigingen
**BEM:** intact
**Kleurenpalet:** intact
```

## Definition of Done

- [ ] Alle doelbestanden zijn gerefactord
- [ ] Geen zichtbare gedragswijziging
- [ ] BEM naamgeving intact
- [ ] Kleuren via CSS custom properties
- [ ] Geen nieuwe hard-coded waarden geïntroduceerd
