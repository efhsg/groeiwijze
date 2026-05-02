# Color Palette — Duin Harmonie

## Goedgekeurde kleuren

```css
/* Brand Colors */
--color-groen: #8DA382;        /* Primary green */
--color-groen-dark: #6B8560;   /* Dark green */
--color-zand: #A68B77;         /* Sand/warm brown */
--color-blauw: #7A91A1;        /* Blue-gray */

/* Text Colors */
--color-text: #3E4444;         /* Primary text (dark gray-green) */
--color-muted: #5E7585;        /* Muted text (blue-gray) */

/* Background Colors */
--color-white: #FFFFFF;        /* Pure white */
--color-bg-warm: #F8F6F2;      /* Warm cream background */
--color-bg-soft: #F4F2EE;      /* Soft beige background */

/* Border/Utility */
--color-border: #E8E6E2;       /* Subtle border color */
```

## Regels

1. **Geen willekeurige kleuren** — Elke kleurwaarde moet uit het goedgekeurde palet hierboven komen
2. **Gebruik CSS custom properties** — Verwijs via `var(--color-name)`, niet via hex-waarden
3. **Geen kleurmodificaties** — Gebruik geen `opacity`, `rgba()`, of filters om nieuwe kleuren te maken zonder goedkeuring
4. **Uitzondering voor wit/transparantie** — `#FFFFFF`, `white`, `transparent`, en `rgba(255,255,255,X)` zijn toegestaan voor functionele doeleinden
5. **Schaduwen** — Gebruik neutrale grijstinten zoals `rgba(62, 68, 68, 0.X)` gebaseerd op `--color-text`

## Nieuwe kleur toevoegen

Als een nieuwe kleur nodig is:
1. Bespreek eerst met de gebruiker
2. Voeg toe aan `website/css/style.css` design tokens
3. Werk dit bestand bij

> Historische referentie: `_archive/preview-006.html` bevat het oorspronkelijke paletvoorbeeld — niet meer leidend.

## Handhaving

Bij elke CSS-wijziging:
- Controleer dat alle kleuren uit het goedgekeurde palet komen
- Gebruik CSS custom properties (variabelen)
- Introduceer nooit willekeurige hex/rgb-waarden
- Gebruik nooit kleuren uit externe bronnen of aannames
