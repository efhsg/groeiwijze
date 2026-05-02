# Feature: pagina-optimaliseren

**Aangemaakt:** 2026-05-01
**Status:** draft
**Eigenaar:** Eigenaar groeiwijze.nl
**Slug:** gwpage

---

## 1. Doel

**Kernbericht:** Een per-pagina verbeterprompt die in drie passes — content, layout, look & feel — concrete, geprioriteerde verbetervoorstellen oplevert met copy-paste-klare patches.

De huidige `/website-review` levert een brede site-scan in healthcare-perspectief, maar dat is een eenmalige diepe audit. Voor periodieke fijnafstelling van losse pagina's ontbreekt een instrument dat kort en gericht werkt: één HTML-pagina, drie passes, klaar in één werksessie.

De eigenaar kan kiezen welke pagina aandacht krijgt op een specifiek moment, zonder elke keer een volledige site-audit te draaien. Per pagina worden content (toon, lengte, hiërarchie), layout (witruimte, hergebruik, mobiel) en look & feel (palet, BEM, micro-interactions) systematisch beoordeeld.

Claude voert de passes uit; de stress-sensitieve bezoeker is indirecte stakeholder wiens beleving als toetssteen voor de voorstellen geldt.

---

## 2. Scope

### In scope

- Verbeterprompt die één HTML-pagina als input accepteert
- Drie expliciet gescheiden passes: content, layout, look & feel
- Per voorstel: severity, effort en concrete patch
- Conformiteitstoetsing aan kleurpalet, BEM, content-toon, toegankelijkheid
- Output in het Nederlands met patches in HTML/CSS-syntax

### Niet in scope

- Site-brede analyse — daarvoor bestaat `/website-review`, voorkomt scope-overlap
- Automatisch toepassen van patches — eigenaar beslist per voorstel, splitst denken van doen
- Cross-pagina consistentiecheck — werkt op pagina-niveau, voorkomt dubbele scope
- Performance-optimalisatie of asset-bundling — focust op content/UX, performance is een andere discipline

---

## 3. Bezoekersflow

Stap-voor-stap wat de eigenaar (beheerder) ervaart:

1. Eigenaar voert de prompt uit met als input een pagina-pad onder `website/`.
2. Claude leest de pagina volledig en bevestigt welke pagina geanalyseerd wordt.
3. Claude voert pass 1 uit (content) en levert voorstellen met severity en patch.
4. Claude voert pass 2 uit (layout) en levert voorstellen met severity en patch.
5. Claude voert pass 3 uit (look & feel) en levert voorstellen met severity en patch.
6. Claude vat alle voorstellen samen in een geprioriteerde tabel.
7. Eigenaar kiest welke voorstellen ze direct doorvoert en welke ze parkeert.

---

## 4. Edge cases

| Situatie | Verwacht gedrag |
|----------|-----------------|
| Pagina bevat ingebedde inline scripts of styles | Claude registreert de inconsistentie en stelt extractie voor naar het centrale stylesheet |
| Pagina gebruikt kleuren buiten het Duin Harmonie palet | Claude markeert dit als kritiek en stelt vervanging door bestaande tokens voor |
| Pagina-content overschrijdt 500 regels | Claude levert voorstellen per sectie in plaats van als één lijst, om scanbaar te blijven |
| Pagina is bijna leeg (placeholder of werk-in-uitvoering) | Claude vraagt of de pagina actief is voordat passes worden uitgevoerd |
| Voorgestelde patch raakt template-elementen die op andere pagina's terugkomen | Claude markeert dit als cross-pagina-impact en raadt aan eerst de structuur-prompt te draaien |
| Eigenaar vraagt om pass 4 (bijvoorbeeld SEO) | Claude weigert scope-uitbreiding en verwijst naar een aparte prompt of skill |

---

## 5. Acceptatiecriteria

- AC-gwpage1: De prompt produceert per pass minstens één voorstel of meldt expliciet dat de pass niets opleverde.
- AC-gwpage2: Elk voorstel bevat severity (kritiek, hoog, medium, laag) en effort-inschatting (kort, middel, lang).
- AC-gwpage3: Elk voorstel levert een concrete HTML- of CSS-snippet die de eigenaar kan kopiëren en plakken.
- AC-gwpage4: De prompt blokkeert site-brede aanbevelingen en verwijst naar een ander instrument.
- AC-gwpage5: De samenvattingstabel vermeldt voor elk voorstel pass, severity, effort en korte beschrijving.

---

## 6. Impact op bestaande pagina's

**Raakt:** individuele HTML-pagina's onder `website/` en mogelijk het centrale stylesheet.

- `website/<pagina>.html`: kandidaat-wijzigingen via voorgestelde patches — alleen na expliciete doorvoer door eigenaar
- Centrale stylesheet: alleen geraakt als een voorstel vraagt om token-vervanging of BEM-correctie
- Geen wijziging tot eigenaar voorstellen doorvoert; bezoeker merkt verbeteringen pas na deploy

---

## 7. Open punten

- Geen.
