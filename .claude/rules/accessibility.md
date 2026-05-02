# Accessibility — WCAG 2.1 AA

Minimale toegankelijkheidseisen, afgestemd op een stress-sensitieve doelgroep.

## Contrast

- Tekst: minimaal **4.5:1** ratio
- Grote tekst (18px+ bold of 24px+): minimaal **3:1** ratio
- Valideer altijd tegen het Duin Harmonie kleurenpalet (zie `rules/colors.md`)

## Focus

- Zichtbare focus-indicators op alle interactieve elementen (links, knoppen, formuliervelden)
- Gebruik `outline` of `box-shadow`, niet alleen kleurverandering
- Verwijder nooit `outline: none` zonder alternatief

## Formulieren

- Elk input-veld heeft een gekoppeld `<label>` (via `for`/`id`)
- Foutmeldingen gekoppeld via `aria-describedby`
- Gebruik `required` en `aria-required="true"` waar nodig
- Groepeer gerelateerde velden met `<fieldset>` + `<legend>`

## Navigatie

- Skip-to-content link als eerste focusbaar element
- Logische heading hierarchie: `h1` > `h2` > `h3` (geen niveaus overslaan)
- Eén `<h1>` per pagina
- `<nav>` element met `aria-label` voor navigatieblokken

## Afbeeldingen

- Alt-tekst verplicht op alle `<img>`
- Decoratieve afbeeldingen: `alt=""`
- Informatieve afbeeldingen: beschrijf de functie, niet het uiterlijk

## Motion

- Respecteer `prefers-reduced-motion`:
  ```css
  @media (prefers-reduced-motion: reduce) {
    * { animation-duration: 0.01ms !important; transition-duration: 0.01ms !important; }
  }
  ```

## Touch targets

- Minimaal **44x44px** voor alle interactieve elementen op touch devices
- Voldoende ruimte tussen klikbare elementen
