---
allowed-tools: Read, Grep, Glob
description: Analyseer de website en maak een refactoringplan voor CSS/HTML/JS opschoning
---

# Refactor Plan

Analyseer de website en stel een gefaseerd refactoringplan op. Geen wijzigingen — alleen analyse en plan.

## Reference Documents

Lees eerst:
- `.claude/rules/colors.md` — kleurenpalet
- `.claude/rules/html-css.md` — BEM, page template, responsive
- `.claude/rules/accessibility.md` — WCAG 2.1 AA
- `.claude/codebase_analysis.md` — projectstructuur

## Phase Selection

Vraag de gebruiker welke fase(n) te draaien:

**Vraag:** "Welke analysefase(n) moet ik draaien?"

**Opties** (multiSelect):
1. **CSS Tokens & Duplicatie** — non-token kleuren, magische waarden, dubbele declaraties
2. **BEM Compliance** — niet-BEM klassen, inconsistente naamgeving
3. **Page Template Consistentie** — afwijkingen tussen HTML pagina's (heading hiërarchie, semantische elementen, meta-tags)
4. **Accessibility Gaps** — ontbrekende alts, form labels, h1-counts, focus states
5. **Content Toon** — verboden woorden, urgentie-taal, ontbrekende normaliserende zinnen

Bij geen keuze: draai **alle fasen**.

---

## Phase 1: CSS Tokens & Duplicatie

**Severity:** High

1. **Non-token hex-waarden** (moeten via `var(--color-*)` of `var(--space-*)`)
   - Grep `website/css/style.css` op `#[0-9a-fA-F]{3,8}` buiten `:root` declaratie
   - Grep op `\d+px` buiten spacing/font-size context

2. **Dubbele property-declaraties** (kandidaten voor consolidatie)
   - Identieke property-sets over verschillende selectors
   - Hetzelfde `font-size: clamp(...)` op meerdere klassen

**Output:** lijst met locaties (regel-nummer waar mogelijk) en effort (S/M/L).

---

## Phase 2: BEM Compliance

**Severity:** High

1. **Klassen zonder BEM-structuur**
   - Grep HTML op `class="[a-z]+ [a-z]+"` met losse woorden (geen `__` of `--`)
   - camelCase klassenamen (verboden)

2. **Inconsistente naamgeving**
   - Verschillende blokken voor dezelfde component (bijv. `.card` en `.box` voor hetzelfde patroon)

**Output:** lijst met selectors en voorgestelde BEM-vorm.

---

## Phase 3: Page Template Consistentie

**Severity:** Medium

1. **Heading hiërarchie**
   - Tel `<h1>` per pagina — moet altijd 1 zijn
   - Detecteer h1→h3 of h2→h4 sprongen

2. **Meta-tags**
   - `lang="nl"` op `<html>` — verplicht
   - `viewport` meta — verplicht
   - `description` meta — aanbevolen

3. **Semantische structuur**
   - `<header>`, `<main>`, `<footer>` aanwezig op alle pagina's
   - `<nav>` met `aria-label`

**Output:** tabel pagina × gevonden afwijkingen.

---

## Phase 4: Accessibility Gaps

**Severity:** Critical (WCAG 2.1 AA)

1. **`<img>` zonder `alt`** — grep HTML op `<img(?![^>]*alt=)`
2. **`<input>` zonder gekoppeld `<label>`** — controle `for`/`id`
3. **Skip-link** — `<a href="#main">` als eerste focusbaar element
4. **Focus-indicators** — grep CSS op `outline: none` zonder vervanging
5. **`prefers-reduced-motion`** media query aanwezig

**Output:** lijst per pagina met severity Critical/High/Medium.

---

## Phase 5: Content Toon

**Severity:** Medium (per `rules/content.md`)

1. **Verboden woorden** — grep HTML op `behandeling`, `patient`, `therapie` (als claim)
2. **Urgentie-taal** — grep op `nu`, `meteen`, `direct`, `nog X plekken`, `boek nu`
3. **Engelse insluipsels** — anglicismen in copy
4. **CTA-aantal** — meer dan 1 primaire CTA per pagina

**Output:** lijst per pagina met aanbevolen alternatieve formulering.

---

## Output Requirements

Schrijf bevindingen naar `.claude/refactor_plan.md`:

### Per fase

- **Aantal violations:** N
- **Specifieke locaties:** `bestand:regel`
- **Effort estimate:** S (<30 min) / M (30 min – 2 uur) / L (>2 uur)

### Samenvatting (bij meerdere fasen)

1. **Gezondheidsscore:** 1-10 op basis van gevonden issues
2. **Quick wins:** wijzigingen direct toepasbaar met laag risico
3. **Volgorde-suggestie:** welke bestanden eerst, op basis van impact

### Prioriteitsniveaus

- **Critical:** Toegankelijkheid (WCAG-blokkers)
- **High:** Kleur-token violations, BEM-schendingen
- **Medium:** Page template inconsistentie, content-toon
- **Low:** Code style suggesties

## Task

$ARGUMENTS
