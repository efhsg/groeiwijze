# HTML & CSS Conventies

## BEM Naamgeving

CSS klassen volgen Block-Element-Modifier:

```css
.block {}
.block__element {}
.block--modifier {}
.block__element--modifier {}
```

Voorbeelden uit de codebase:
- `.header__inner`, `.header__nav`
- `.card__title`, `.card__badge`
- `.hero__content`, `.hero__cta`
- `.section--warm`, `.section--groen`
- `.btn--primary`, `.btn--secondary`
- `.container--narrow`

## Page Template

Elke pagina volgt dezelfde structuur:

```html
<!DOCTYPE html>
<html lang="nl">
<head>
  <!-- meta tags, title, fonts, stylesheet -->
</head>
<body>
  <a class="skip-link" href="#main">Direct naar inhoud</a>
  <header class="header">...</header>
  <main id="main">
    <!-- content sections -->
  </main>
  <footer class="footer">...</footer>
  <script src="js/main.js"></script>
</body>
</html>
```

- `lang="nl"` altijd op `<html>`
- Consistent meta tags blok (charset, viewport, description)
- Semantische HTML5 elementen (`<header>`, `<main>`, `<section>`, `<footer>`, `<nav>`)
- Skip-to-content link vóór de header met target `#main`
- Stylesheet met versie query parameter (`css/style.css?v=N`) — verhoog `N` bij een CSS-wijziging om browsercaches te omzeilen

## Responsive

- **Mobile-first** als uitgangspunt
- **Breakpoints** (huidige codebase):
  - `480px` — mobiel portrait aanpassingen
  - `768px` — hoofd-breakpoint (layout, spacing)
  - `769px` — min-width triggers (grid layouts)
  - `1024px` — tablet/desktop navigatie omschakeling
- Geen aparte mobiele/desktop bestanden

## Typography

- **Font**: Libre Franklin (via Google Fonts, gewichten 400/500/600/700)
- **Sizing**: gebruik `clamp()` voor responsieve groottes
- **Spacing scale**:
  - `--space-xs`: 0.5rem
  - `--space-sm`: 1rem
  - `--space-md`: 1.5rem
  - `--space-lg`: 2rem
  - `--space-xl`: 3rem
  - `--space-xxl`: 5rem

## Layout

- **Container**: max-width `1100px`, gecentreerd
- **Narrow container**: max-width `720px` (voor tekst-zware pagina's)
- Gebruik `padding` via spacing scale variabelen

## Bestaande componentblokken

Herbruik bestaande blokken voordat je nieuwe componentnamen introduceert:

- Navigatie en frame: `.header`, `.logo`, `.nav`, `.nav-toggle`, `.footer`
- Layout en secties: `.container`, `.section`, `.hero`, `.profile`
- Contentpatronen: `.card`, `.feature-list`, `.quote-list`, `.phases`, `.read-more`, `.pricing-table`
- Formulieren: `.form`
- Utilities: `.lead`, `.text-center`, `.text-muted`, `.mt-*`, `.mb-*`, `.sr-only`

## Afbeeldingen

- Gebruik geoptimaliseerde formaten (WebP waar mogelijk, SVG voor logo's/iconen)
- Voor `alt`-tekst regels: zie `rules/accessibility.md`
