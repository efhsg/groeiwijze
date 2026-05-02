---
name: groeiwijze-adaptive-intake-flow
description: Ontwerp een AVG-vriendelijke, stress-sensitieve intake/check flow (Groen/Oranje/Rood) voor groeiwijze.nl, met duidelijke uitkomsten en koppeling naar contactformulier. Gebruik bij vragen over intake, check-flow, matching, of doorverwijzing.
---

# GroeiwijzeAdaptiveIntakeFlow

## Intent

Ontwerp een **korte check** die:
- snel aangeeft of iemand bij Groeiwijze aan het goede adres is
- passende "therapeutische opties" toont (zonder diagnoses/claims)
- bij passendheid soepel doorleidt naar contact
- **AVG-vriendelijk** is (dataminimalisatie, toestemming, bewaartermijn)

**Context:** Zie CLAUDE.md voor doelgroep, stijl en tech stack. Doel: betere matching, minder e-mail heen-en-weer.

**Non-goals:** Geen diagnoses, crisisinterventie, dossieropbouw, of gevoelige details in stap 1.

---

## Safety & ethics gate (altijd eerst)

De flow mag nooit:
- suïcidaliteit of acute crisis "uitvragen" in detail
- de indruk wekken dat dit medische zorg vervangt

Wel:
- 1 veiligheidsvraag op hoog niveau (nee/twijfel/ja)
- bij "ja/twijfel": **Rood** route met verwijzing (huisarts/spoed/113)

---

## AVG defaults (must)

### Dataminimalisatie
- Stap 1: zo veel mogelijk **meerkeuze**
- Geen vrije tekst over trauma/medische details
- Geen gevoelige persoonsgegevens (DOB/BSN/diagnoses/medicatie)

### Geen opslag zonder reden
- Stap 1 kan anoniem draaien (geen opslag)
- Pas bij "Contact" wordt data verzonden

### Toestemming
- Bij contact: expliciete checkbox (niet vooraf aangevinkt)
- Link naar privacy + bewaartermijn

### Transport
- Geen intake-data in URL querystrings
- Alleen POST (hidden fields of samenvatting)

---

## Flow design (2 stappen)

### Stap 1 — "Korte check (2 minuten)"
8–12 vragen, grotendeels meerkeuze.
Output: **Groen / Oranje / Rood** + 2–3 opties.

### Stap 2 — "Contact / kennismaking"
Alleen bij Groen/Oranje:
- contactgegevens
- samenvatting van antwoorden (compact)
- consent checkbox

Bij Rood:
- geen contactformulier als primaire route
- wel: rustige uitleg + verwijzingen

---

## Question set (recommended)

**Q1 Hulpvraag (max 2 keuzes)**
- stress/overbelasting
- angst/piekeren
- somber/verlies
- grenzen/zelfbeeld
- relatie/hechting
- verwerking/ingrijpend (globaal)
- anders

**Q2 Duur**
- < 1 maand / 1–6 maanden / > 6 maanden / langer

**Q3 Belastingsscore (1–10)**

**Q4 Veiligheid (hoog niveau)**
- nee / twijfel / ja (direct gevaar)

**Q5 Huidige hulp**
- nee / huisarts / therapeut / anders

**Q6 Voorkeur aanpak**
- inzicht/gesprek / praktisch / lichaamsgericht / combinatie / weet ik niet

**Q7 Vorm**
- 1-op-1 / wandel / online / combinatie

**Q8 Beschikbaarheid (globaal)**
- overdag / avond / flexibel

Optional (alleen als nodig):
- regio (tekst of dropdown)
- voorkeur: eerst mail of kennismaken

---

## Scoring & routing (simple rules)

### Rood
- Q4 = ja of twijfel
- of (Q3 >= 9) én (Q4 niet expliciet "nee")

Output:
- "Dit vraagt nu directe hulp."
- Verwijs: huisarts / 113 / spoed (NL)

### Oranje
- Q3 7–8
- of "verwerking/ingrijpend" als hoofdthema
- of lopende intensieve behandeling

Output:
- "Waarschijnlijk passend, ik stem graag even kort af."
- CTA: kennismakingscall of korte intake via contact

### Groen
- Q3 1–6
- geen safety flags
- thema's binnen aanbod

Output:
- "Je bent welkom. Dit lijkt te passen."
- CTA naar contact

---

## Options mapping (show max 3 cards)

De agent moet kaarten tonen als "kan helpen bij…", nooit "behandelt".

Voorbeeld kaarten:
- **Rust & herstel bij overbelasting** (stress/piekeren)
- **Grenzen & zelfregie** (zelfbeeld/grenzen)
- **Betekenisgeving & verwerking** (verlies/ingrijpend, stap voor stap)

Per kaart:
- 1 zin "waarom dit"
- 2 bullets "wat je kunt verwachten"
- 1 CTA ("Kennismaken")

---

## UI copy rules (stress-sensitief)

- Geen "urgent" taal bij Groen/Oranje
- Wel normaliseren: "Je hoeft het niet alleen uit te zoeken."
- Korte zinnen, veel witruimte
- Progress indicator: "Stap 1 van 2"
- Altijd een "Liever direct contact?" link (behalve Rood)

---

## Output requirements (Agent deliverable)

De agent levert:
1. Intake flow (stappen + schermen)
2. Vraagset (8–12) in NL, meerkeuze-georiënteerd
3. Routing logica (Groen/Oranje/Rood)
4. Copy snippets (titel, uitleg, uitkomst-teksten)
5. AVG-block (toestemmingstekst + bewaartermijnsuggestie)
6. Technical handoff (hidden fields + POST, provider-agnostic)

---

## Example prompt

"Gebruik GroeiwijzeAdaptiveIntakeFlow. Ontwerp de 'Past dit bij jou?' check voor groeiwijze.nl. Doelgroep is stressgevoelig. Maak het AVG-vriendelijk, met Groen/Oranje/Rood en doorleiding naar contact."
