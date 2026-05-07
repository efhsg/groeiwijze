# Feature: worktrees-polish — switcher en endpoint UX/observability

**Aangemaakt:** 2026-05-07
**Status:** draft
**Eigenaar:** Eigenaar groeiwijze.nl
**Slug:** gwwtp

---

## 1. Doel

**Kernbericht:** Verfijn de worktree-switcher en `_wt/list.php` na launch op vijf punten zonder gedrags-breaking changes.

Gevolg: developer-ervaring scherper (server-foutmodi zichtbaar in UI), screenreader-conform (ARIA-pattern strikt), focus-flow voorspelbaar bij dropdown-open, code-cleanup in endpoint, en stale-state visueel duidelijker.

**Herkomst:** post-launch code-review op de drie commits van de worktrees-feature (54d1fa4, 5527c85, 0b4283c, 6ad419c). Zes polish-tickets geïdentificeerd (PT-1 t/m PT-6); PT-4 is "geen actie" en valt buiten deze spec.

---

## 2. Scope

### In scope

- **PT-1**: `_wt/list.php` retourneert HTTP 500 in plaats van 200 met lege array bij `realpath`- of `scandir`-failure.
- **PT-2**: ARIA-pattern keuze voor de switcher: native `<nav>`/`<ul>`/`<li>`/`<button>` óf `role="listbox"`/`role="option"`. Afstappen van `role="menu"`/`role="menuitem"` mits er geen arrow-key roving focus is.
- **PT-3**: Focus-shift naar eerste of actief menu-item bij `openPanel()` — alleen relevant indien PT-2 voor `role="menu"` kiest.
- **PT-5**: Verwijder redundante `is_dir($projectsRoot)`-check in `list.php` na succesvolle `realpath`.
- **PT-6**: Lichtere stale-state achtergrond voor betere zichtbaarheid in donkere modus.

### Niet in scope

- **PT-4**: Invalid-branch in `applyState()` (regels 171-176) — defense-in-depth voor genuinely ongeldige `?wt=`-input. Tekst zelden zichtbaar omdat nginx invalid suffixes server-side al naar main mapt. Behouden zoals is.
- ArrowDown/Up roving focus binnen menu — alleen relevant indien PT-2 voor `role="menu"` kiest; valt anders weg in PT-2-implementatie.
- Refactor van `setBadge` of andere infrastructuur.
- Wijziging van `?wt=`-preservatie of contact-flow.
- Productie-deploy of nginx-config.

---

## 3. Componenten en locaties

| Ticket | Locatie | Wijziging |
|--------|---------|-----------|
| PT-1 | `docker/groeiwijze/_wt/list.php:23-27, 30-34` | `http_response_code(500)` op realpath/scandir failure-paden |
| PT-2 | `docker/groeiwijze/_wt/switcher.js:65, 128, 74` | Wijzig of laat ARIA-rollen weg, sync met toetsenbordpattern |
| PT-3 | `docker/groeiwijze/_wt/switcher.js:234-237` | Focus-shift in `openPanel()` (alleen bij role=menu pad) |
| PT-5 | `docker/groeiwijze/_wt/list.php:23` | Verwijder `!is_dir($projectsRoot)` na `realpath`-check |
| PT-6 | `docker/groeiwijze/_wt/switcher.js:23` | `.wt-switcher--stale` background van `#5A4A1F` naar lichtere variant |

---

## 4. Edge cases

| Situatie | Verwacht gedrag |
|----------|-----------------|
| `realpath('/var/www/projects')` retourneert `false` | HTTP 500, `error_log` blijft generiek, geen body-leak |
| `scandir($projectsRoot)` retourneert `false` | HTTP 500, idem |
| Switcher zonder JavaScript | Niet relevant — feature is JS-only en wordt enkel via `<script defer>` injectie geactiveerd |
| Toetsenbordnavigatie via Tab/Shift+Tab | Blijft werken (P2-AC-gwwt6) — onafhankelijk van PT-2 keuze |
| Toetsenbordnavigatie via pijltoetsen bij `role=listbox` | Browser/screenreader gebruikt eigen primitives — geen custom implementatie nodig |
| Stale-state contrast | Witte tekst op nieuwe achtergrond moet WCAG AA halen (≥4.5:1) |

---

## 5. Acceptatiecriteria

- **AC-gwwtp1** — `_wt/list.php` retourneert HTTP 500 wanneer `realpath` of `scandir` faalt; switcher activeert `applyError()`-state via bestaande failure-funnel.
- **AC-gwwtp2** — ARIA-rollen op trigger en menu-items zijn consistent met het toetsenbordpattern. Combinatie `role="menu"` + alleen Tab-navigatie (WAI-ARIA APG mismatch) komt niet meer voor.
- **AC-gwwtp3** — Indien `role="menu"` behouden: bij `openPanel()` ontvangt het eerste of actieve menu-item focus, en pijltoetsen verplaatsen focus tussen items. Indien `role="listbox"` of native: AC vervalt.
- **AC-gwwtp5** — `list.php` bevat geen redundante `is_dir($projectsRoot)`-check direct na succesvolle `realpath`.
- **AC-gwwtp6** — Stale-state achtergrond is visueel duidelijk onderscheiden van actief en error, zowel in licht als donker thema, en behoudt WCAG AA contrast (≥4.5:1) voor de witte tekst.

---

## 6. Securitygrenzen

Geen wijziging in security-control:

- `_wt/list.php` blijft alleen suffix-array emit (AC-gwwt18 ongewijzigd).
- `error_log` blijft generieke melding zonder pad-, branch- of raw-input-lekkage.
- HTTP 500 body bevat geen path-, branch- of `.git`-details — emit lege array of generieke foutmelding zonder context.
- Whitelist-validatie en path-traversal-defense ongewijzigd.
- Switcher blijft `<script defer>` injectie via nginx `sub_filter` op HTML-types — geen wijziging in injectie-pad.

---

## 7. Teststrategie

| Ticket | Verificatie |
|--------|-------------|
| PT-1 | Handmatig: container restart met fictieve `PROJECTS_ROOT` of bind-mount-conflict zodat `realpath` faalt. Curl `_wt/list.php` → verwacht 500. Browser-test: pill toont `⚠ ?` (error-state). |
| PT-2 | Code-review op rol-naam-consistentie + handtest met screenreader (NVDA, VoiceOver of Orca) op pattern-conformiteit. |
| PT-3 | (Indien role=menu) handtest: open dropdown via klik en Enter; verifieer dat eerste/actieve menu-item focus krijgt. |
| PT-5 | Code-review (geen runtime-impact). PHP-lint clean. |
| PT-6 | Visuele regressiecheck in licht- en donker-thema. WCAG contrast-ratio bevestigd via devtools (Chrome a11y panel of axe-core). |

---

## 8. Open punten

- **PT-2 pattern-keuze**: native `<nav>` (geen ARIA) versus expliciet `role="listbox"`. Native is simpeler en past bij nav-context; listbox is preciezer voor selectie. Beslissing voor implementatie nodig.
- **PT-6 kleurwaarde**: `#A87A1F` of `#B8842A` of andere variant. Visuele test in beide thema's bepaalt.
- **PT-1 generieke fout-respons**: emit lege array (huidig gedrag op succes-pad) of een minimale `{"error": "list_unavailable"}`-object. Eerste behoudt array-contract; tweede verbetert observability voor toekomstige clients.

---

## Cross-links

- Originele feature: `/projects/groeiwijze.nl/.ai/features/.archive/worktrees/` (gitignored archief)
- Implementatie-commits: 54d1fa4 (P1), 5527c85 (P2), 0b4283c (badge-tweak), 6ad419c (P3)
- Code-review-vondsten: gedocumenteerd in `insights.md` van het archief onder sectie "P2 Code Review — Polish-tickets"
