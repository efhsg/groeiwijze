# Prompt for Claude CLI — Normalize header across all pages (Groeiwijze v0.3)

## Role
You are a careful front-end refactor agent. You edit static HTML files with minimal, safe, deterministic changes.

## Goal
Update **all HTML pages** (except `index.html`, which is already correct) so their `<header class="header">...</header>` matches **exactly** the header structure used in `index.html`.

## Constraints
- Do **not** change CSS or JS (only HTML files).
- Do **not** reformat unrelated parts of files.
- Preserve each page’s active nav state:
  - The current page link must have `class="nav__link nav__link--active"` and `aria-current="page"`.
  - All other links must be `class="nav__link"` with no `aria-current`.
- Keep the header wrapper structure exactly:
  - `<header class="header"><div class="container"><div class="header__inner"> ... </div></div></header>`
- Ensure every page uses **this exact logo block** (verbatim):

```html
<a href="index.html" class="logo">
  <img src="assets/img/logo2.svg" alt="" class="logo__icon" />
  <span class="logo__tagline">praktijk voor herstel en groei</span>
  <span class="sr-only">groeiwijze</span>
</a>
```

- Ensure every page uses a **nav-wrap** that matches this structure exactly (verbatim except the active link):

```html
<div class="nav-wrap">
  <button
    class="nav-toggle"
    aria-label="Menu"
    aria-expanded="false"
    aria-controls="main-nav"
  >
    <span class="nav-toggle__bar"></span>
    <span class="nav-toggle__bar"></span>
    <span class="nav-toggle__bar"></span>
  </button>
  <nav class="nav" id="main-nav" aria-label="Hoofdnavigatie">
    <a
      href="index.html"
      class="nav__link nav__link--active"
      aria-current="page"
      >Home</a
    >
    <a href="over-mij.html" class="nav__link">Over mij</a>
    <a href="werkwijze.html" class="nav__link">Werkwijze</a>
    <a href="tarieven.html" class="nav__link">Tarieven</a>
    <a href="veelgestelde-vragen.html" class="nav__link"
      >Veelgestelde vragen</a
    >
    <a href="contact.html" class="nav__link">Contact</a>
  </nav>
</div>
```

## Workspace assumptions
- The HTML and CSS live in `./v0.3/`.
- `index.html` contains the correct header and should be used as the single source of truth.
- Other pages likely include:
  - `over-mij.html`
  - `werkwijze.html`
  - `tarieven.html`
  - `veelgestelde-vragen.html`
  - `contact.html`
  - and any additional `*.html` files in `./v0.3/`

## Tasks
1. In `./v0.3/`, find all `*.html` files.
2. For each file **except** `index.html`:
   - Replace the entire `<header class="header"> ... </header>` with the one from `index.html`.
   - Then adjust the nav so the correct link is active for that page:
     - `over-mij.html` → “Over mij”
     - `werkwijze.html` → “Werkwijze”
     - `tarieven.html` → “Tarieven”
     - `veelgestelde-vragen.html` → “Veelgestelde vragen”
     - `contact.html` → “Contact”
     - Any other page: choose the closest match; if none, remove `nav__link--active`/`aria-current` from all links.
3. Keep indentation and line breaks consistent with `index.html`’s header (copy it verbatim).
4. Do not introduce duplicate `id="main-nav"` within a single page (it should appear once).
5. After edits, run a quick validation:
   - Each HTML file has exactly one `.nav-wrap`.
   - Each HTML file has exactly one `#main-nav`.
   - Exactly one nav link has `aria-current="page"`.

## Output
- Make the edits in place.
- Print a concise summary:
  - Which files were modified
  - Which link was set active per file
  - Any files skipped and why

## Execute now
Proceed to apply the changes.
