# Notes — verbeter-hoofdmenu

Open punten en zijsporen die later opgepakt moeten worden.

## Note: Methodieken → Werkvormen — site-brede consistentie

**Status:** geparkeerd op 2026-05-08

### Aanleiding

Tijdens werk aan stap 2 (footer-uitbreiding) bleek dat de site beide termen door
elkaar gebruikt. `methodieken.html` is intern al consistent met "Werkvormen"
(meta-description, intro, h2, cards), maar title, h1 en de footer-link op die
pagina gebruikten nog "Methodieken". In deze sessie zijn alleen die drie
plekken aangepast — de rest van de site is bewust niet meegenomen om eerst te
ervaren hoe "Werkvormen" als pagina-titel aanvoelt.

### Later uitzoeken

- Site-breed vervangen: footer-label op de 12 andere HTML-pagina's
- `hoe-ik-werk.html`: h2 *"Voor wie meer wil weten over de methodieken"* + de
  read-more link *"lees meer over de methodieken"* aanpassen
- Filename hernoemen: `methodieken.html` → `werkvormen.html` (met
  fallback-pagina of redirect voor bestaande inkomende links)
- Afstemmen met de trauma-sensitieve tekstschrijver — "werkvormen" past beter
  bij de niet-jargon richtlijn dan "methodieken"

### Raakt mogelijk

- Footer-kolom "Meer informatie" op alle 13 HTML-pagina's
- `hoe-ik-werk.html`: h2 + read-more link naar deze pagina
- Filename `methodieken.html` en eventuele inkomende links / bookmarks
- SEO bij rename — overwegen of een fallback-pagina nodig is
