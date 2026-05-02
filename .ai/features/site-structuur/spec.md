# Feature: site-structuur-interview

**Aangemaakt:** 2026-05-01
**Status:** draft
**Eigenaar:** Eigenaar groeiwijze.nl
**Slug:** gwstruct

---

## 1. Doel

**Kernbericht:** Een interview-prompt die de eigenaar door scherpe, domeinbewuste vragen leidt om de bestaande site-structuur te confronteren en concrete pagina-mutatievoorstellen oplevert.

De huidige harnas heeft `groeiwijze-adaptive-site-structure` als skill, maar die helpt alleen bij de keuze tussen one-pager, multi-page en hybrid bij een groene wei. Voor een bestaande site met twaalf pagina's ontbreekt een actief instrument dat vraagt of de structuur de bezoeker dient of organisch is gegroeid.

De prompt voert een gestructureerd gesprek per pagina, vraagt naar bezoekersintentie, navigatieroutes en redundantie, en levert een rapport met concrete mutaties: samenvoegen, splitsen, weghalen, toevoegen. De eigenaar kan zelfstandig reflecteren op de informatiearchitectuur zonder externe UX-consultant.

Claude voert het interview uit; de stress-sensitieve bezoeker is indirecte stakeholder wiens perspectief in de vragen meeweegt.

---

## 2. Scope

### In scope

- Interview-prompt die per pagina vraagt: wie komt hier, vanuit welke vraag, waar gaat ze daarna heen
- Confrontatievragen: welke pagina is overbodig, welke mist, welke is doodlopend
- Rapport met categorisatie van mutaties: samenvoegen, splitsen, weghalen, toevoegen
- Prioritering van mutaties op basis van bezoekersimpact
- Output in het Nederlands, conform content-toon van groeiwijze.nl

### Niet in scope

- Implementatie van de mutaties — de prompt levert alleen het rapport, splitst denken van doen
- Analytics-integratie of bezoekersdata — werkt op basis van eigenaar-reflectie, geen analytics aangesloten
- A/B-testing of variant-vergelijking — buiten scope van een statische site, geen testinfrastructuur
- SEO-optimalisatie of zoekwoordenanalyse — focust op informatiearchitectuur, SEO is een andere discipline

---

## 3. Bezoekersflow

Stap-voor-stap wat de eigenaar (beheerder) ervaart:

1. Eigenaar voert de interview-prompt uit met een verwijzing naar groeiwijze.nl als context.
2. Claude leest de pagina-index en bevestigt welke pagina's in scope zijn.
3. Claude stelt per pagina drie vragen: wie komt hier, vanuit welke vraag, waar gaat ze daarna heen.
4. Eigenaar beantwoordt; Claude noteert per pagina een korte samenvatting.
5. Claude stelt drie confrontatievragen over de hele site: overbodige pagina, ontbrekende pagina, doodlopende pagina.
6. Claude vat het gesprek samen en levert een rapport met geprioriteerde mutatievoorstellen.
7. Eigenaar bevestigt welke voorstellen ze opvolgt en welke ze terzijde schuift.

---

## 4. Edge cases

| Situatie | Verwacht gedrag |
|----------|-----------------|
| Eigenaar weet niet wie de typische bezoeker van een pagina is | Claude formuleert een hypothese op basis van pagina-content en vraagt om bevestiging |
| Eigenaar wil tussentijds stoppen | Claude levert een tussentijds rapport en markeert wat onbehandeld bleef |
| Aantal pagina's groeit boven twintig | Claude stelt voor in twee sessies te werken: eerst hoofdpagina's, dan support-pagina's |
| Eigenaar vraagt om implementatie tijdens interview | Claude weigert het scope-conflict en verwijst naar een aparte vervolgstap |
| Pagina-content is leeg of placeholder | Claude registreert de pagina als "leeg" en vraagt of die geschrapt of gevuld moet worden |
| Twee pagina's hebben overlappende intentie | Claude stelt expliciet voor te overwegen samen te voegen en vraagt naar voor- en nadelen |

---

## 5. Acceptatiecriteria

- AC-gwstruct1: De prompt produceert per pagina een korte samenvatting met bezoeker, vraag en vervolgstap.
- AC-gwstruct2: De prompt levert een rapport dat minstens vier mutatie-categorieën dekt: samenvoegen, splitsen, weghalen, toevoegen.
- AC-gwstruct3: De prompt vermeldt voor elke voorgestelde mutatie de bezoekersimpact in één zin.
- AC-gwstruct4: De prompt blokkeert direct overgaan tot implementatie en meldt dat een vervolgstap nodig is.
- AC-gwstruct5: Het rapport is in het Nederlands en bevat geen verboden woorden uit de content-rules van groeiwijze.nl.

---

## 6. Impact op bestaande pagina's

**Raakt:** de informatiearchitectuur van groeiwijze.nl, mogelijk meerdere pagina's onder `website/`, en de page-template-consistentie.

- `website/`: geen directe wijziging — de prompt levert alleen analyse, doorvoer is een aparte stap
- Eigenaar beslist per voorstel of ze het opvolgt — bezoeker merkt pas iets na een vervolgactie

---

## 7. Open punten

- Moet de prompt analytics-data kunnen accepteren als optionele input, of blijft het puur reflectief? Eigenaar beslist bij volgende werksessie.
