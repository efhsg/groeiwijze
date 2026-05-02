---
name: groeiwijze-adaptive-site-structure
description: Kies one-pager, multi-page of hybrid voor groeiwijze.nl met vaste defaults voor stressgevoelige doelgroepen (cognitieve belasting, emotionele veiligheid, besluitondersteuning). Gebruik bij vragen over site-structuur, IA, of navigatie.
---

# GroeiwijzeAdaptiveSiteStructure

## Intent

Maak een **structurele keuze** (one-pager vs multi-page vs hybrid) die maximaal **adaptief** is voor stressgevoelige bezoekers.

**Adaptive =** weinig keuze-stress, voorspelbare stappen, heldere "volgende stap", ruimte voor autonomie zonder verdwalen

**Context:** Zie CLAUDE.md voor doelgroep, stijl, tech stack en huidige site-structuur. Primair doel: vertrouwen + duidelijke route naar vervolgstap.

**Non-goals:** Geen SEO-discussies (tenzij gevraagd), "funnel hacks" of agressieve conversie.

---

## Input checklist (Agent vult dit in)

1. **Content volume**
   - compact / gemiddeld / groeiend

2. **Nood aan reflectie**
   - laag (direct contact) / middel / hoog (fit-check, intake)

3. **Bezoekerstatus (verwacht)**
   - rustig / gespannen / overprikkeld / crisis-achtig

4. **Intake aanwezig?**
   - geen / korte check / intake light / intake zwaar

5. **Team/onderhoud**
   - 1 persoon / klein team / groeiend team

---

## Beslismodel (Groeiwijze-defaults)

### Stap 1 — Safety gate

Als er intake/triage is: **plaats die nooit als "grote blok" midden in de homepage**.
- wel: aparte pagina of duidelijke sectie met "Stap 1 van 2"
- niet: verborgen lange formulieren zonder context

### Stap 2 — Structure choice

**DEFAULT: HYBRID (multi-page met one-page gedrag).**

Kies **HYBRID** als één of meer waar is (meestal bij Groeiwijze):
- content is gemiddeld of groeiend
- er is een "Past dit bij jou?"-check of intake
- doelgroep is stressgevoelig → baat bij segmentatie + rust
- je wil meerdere ingangen (over mij / werkwijze / tarieven) zonder overload

Kies **ONE-PAGER** alleen als álles waar is:
- content is compact (max ~5–7 schermen)
- intake is minimaal of afwezig
- je wil vooral één geleide kennismaking (narratief)
- je kan progressive disclosure heel strak uitvoeren

Kies **MULTI-PAGE** (klassiek) als:
- content groeit hard
- je hebt meerdere duidelijke trajecten/doelgroepen
- je wil elk thema volledig los kunnen uitbreiden
- je accepteert iets meer navigatie-keuzes (maar houdt het minimalistisch)

---

## Groeiwijze-aanbevolen IA (Information Architecture)

**Huidige structuur:** Zie CLAUDE.md voor bestaande pagina's.

**Bij toevoegen intake-check (`/past-dit-bij-jou.html`):**
- Plaats als aparte pagina (niet embedded in homepage)
- Maak zichtbaar in navigatie
- Aanbevolen positie: tussen "werkwijze" en "tarieven"

**Navigation defaults (stressvriendelijk):**
- Max 5 items in hoofdnavigatie
- 1 dominante CTA per pagina (Contact/Kennismaken), niet overal 3 knoppen
- Bij toevoegen intake: "Past dit bij jou?" als secundaire CTA

---

## Adaptive behavior rules (per pagina)

- Start met **1 zin die veiligheid geeft** ("Je hoeft niet meteen te weten…")
- Max 1 primaire CTA per scherm
- Gebruik "progressive disclosure":
  - eerst: kern
  - daarna: verdieping (accordion / details)
- "Tarieven" altijd scanbaar, geen wall of text
- Op mobiel: sticky CTA mag, maar **niet schreeuwerig**

---

## Output requirements (Agent deliverable)

1. **Keuze**: one-pager / multi-page / hybrid + motivatie (cognitieve belasting, autonomie, veiligheid)
2. **Intake placement**: waar en waarom (indien van toepassing)
3. **Risico's + mitigaties**: 2–4 bullets

---

## Relatie met groeiwijze-adaptive-intake-flow

Deze skill bepaalt **waar** de intake flow komt, de intake-flow skill bepaalt **hoe** die eruit ziet.

Samen zorgen ze voor:
- Structurele rust (site-structure)
- Inhoudelijke veiligheid (intake-flow)

---

## Example prompt

"Gebruik GroeiwijzeAdaptiveSiteStructure. Adviseer site-structuur voor groeiwijze.nl. Doelgroep is stressgevoelig. Er komt een korte check 'Past dit bij jou?' die naar contact leidt. Geef keuze + IA + risico's."
