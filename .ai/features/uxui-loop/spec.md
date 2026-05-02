# Feature: uxui-verbeter-loop

**Aangemaakt:** 2026-05-01
**Status:** draft
**Eigenaar:** Eigenaar groeiwijze.nl
**Slug:** gwuxui

---

## 1. Doel

**Kernbericht:** Een iteratieve verbeterprompt die in vier stappen — inventariseer, prioriteer, ontwerp, verifieer — één UX/UI-pijnpunt per ronde aanpakt en daarmee continue verbetering ondersteunt.

De huidige `/website-review` is een grondige eenmalige scan van de hele site. Die werkt voor een kwartaal-audit, maar leidt vaak tot een lange lijst die niet wordt opgevolgd omdat er geen kader is om er stap voor stap doorheen te werken.

De verbeter-loop dwingt tot één pijnpunt per ronde: inventariseer top vijf, kies één, ontwerp samen met de UX/UI-rollen, controleer effect, herhaal. De eigenaar krijgt een ritme — bijvoorbeeld maandelijks één ronde — in plaats van eens per jaar overweldigd raken door een audit.

Tijdens de ontwerpfase leveren de UX Designer en UI Designer rollen elk een perspectief; bij conflict treedt de Arbiter-rol op. De stress-sensitieve bezoeker is indirecte stakeholder wiens beleving als toetssteen geldt.

---

## 2. Scope

### In scope

- Vier-fasen prompt: inventariseer, prioriteer, ontwerp, verifieer
- Eén pijnpunt per ronde — strikt geforceerd
- Gebruikt UX Designer en UI Designer rollen tijdens ontwerpfase
- Effectmeting in laatste fase: wat is verbeterd, hoe meetbaar
- Output is rondesgewijs: één rapport per ronde, niet één massa-rapport

### Niet in scope

- Site-brede pijnpuntenlijst zonder prioritering — daarvoor bestaat `/website-review`, voorkomt scope-overlap
- Implementatie van het ontwerp — de prompt levert ontwerp, eigenaar voert door, splitst denken van doen
- Cross-ronde tracking of dashboard — geen state tussen rondes, vereenvoudigt scope
- Vergelijking met andere websites of benchmark — focust op eigen verbetering, benchmark is buiten scope

---

## 3. Bezoekersflow

Stap-voor-stap wat de eigenaar (beheerder) ervaart:

1. Eigenaar voert de loop-prompt uit en geeft aan dat ze een nieuwe ronde wil starten.
2. Claude inventariseert top vijf UX/UI-pijnpunten op basis van site-content en levert ze met evidentie.
3. Eigenaar kiest één pijnpunt om aan te pakken in deze ronde.
4. Claude past de UX Designer en UI Designer rollen toe en levert een voorstel met before/after-schets.
5. Eigenaar bevestigt het ontwerp of vraagt om aanpassing.
6. Claude vat de ronde samen met meetbare verwachte impact en stelt een vervolgvraag voor de volgende ronde voor.
7. Eigenaar besluit te stoppen of een nieuwe ronde te plannen.

---

## 4. Edge cases

| Situatie | Verwacht gedrag |
|----------|-----------------|
| Geen evidente pijnpunten te vinden | Claude meldt dit en stelt voor de eerstvolgende ronde over te slaan of een diepere `/website-review` te draaien |
| Eigenaar wil twee pijnpunten tegelijk aanpakken | Claude weigert en herinnert aan het één-per-ronde principe; vraagt om expliciete keuze |
| Pijnpunt overlapt met een eerder afgehandeld pijnpunt uit vorige ronde | Claude vraagt of de eerdere oplossing onvoldoende was en welke aanvullende verbetering nodig is |
| Voorgesteld ontwerp raakt het centrale design system | Claude markeert dit als systeem-impact en raadt aan eerst de structuur-prompt te draaien |
| Eigenaar accepteert ontwerp maar voert niet door | Claude registreert dat doorvoer pending is en herinnert in de volgende ronde |
| UX en UI rol leveren conflicterende voorstellen | Claude past de Arbiter-rol toe om convergentie te begeleiden of expliciet stilstand te markeren |

---

## 5. Acceptatiecriteria

- AC-gwuxui1: De inventarisatie-fase levert minstens drie en ten hoogste vijf pijnpunten met evidentie per item.
- AC-gwuxui2: De prompt blokkeert tegelijk aanpakken van meerdere pijnpunten en weigert verder te gaan tot één keuze gemaakt is.
- AC-gwuxui3: Het ontwerp-rapport vermeldt zowel UX-perspectief als UI-perspectief in gescheiden secties.
- AC-gwuxui4: De verificatie-fase produceert een meetbare verwachte impact per ontworpen verbetering.
- AC-gwuxui5: De ronde-samenvatting bevat de gekozen volgende stap of expliciete melding van loop-einde.

---

## 6. Impact op bestaande pagina's

**Raakt:** UX/UI-aspecten van pagina's onder `website/`, mogelijk het centrale stylesheet, en het ritme van iteratieve verbetering.

- `website/`: per ronde één pagina of component geraakt — alleen na bevestigd ontwerp en doorvoer
- Centrale stylesheet: alleen geraakt als ontwerp tokens, BEM of micro-interactions raakt
- Geen wijziging tot eigenaar ontwerpvoorstellen doorvoert; bezoeker merkt cumulatief effect na meerdere rondes

---

## 7. Open punten

- Moet een vorige-rondes-log automatisch worden bijgehouden of blijft het per ronde stateless? Eigenaar beslist na de eerste twee rondes.
