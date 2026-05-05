# Functionele specificatie: dev-mailcatcher

**Feature-map:** `.ai/features/dev-mailcatcher/`
**Status:** accepted
**Feature-slug:** mailcatcher
**Aangemaakt:** 2026-05-05

---

## 1. Doel en context

**Kernbericht (één zin):** Een dev-mailcatcher vangt alle mail die de groeiwijze.nl-dev-omgeving verstuurt en toont die in een browser-inbox, zodat de niet-technische beheerder en ontwikkelaars het contactformulier kunnen testen zonder dat productie-mailboxen worden geraakt.

De huidige dev-omgeving deelt de SMTP-instellingen met productie. Elke form-submit vanuit een dev-container of worktree bezorgt daardoor een echte mail bij het productie-ontvangeradres. Deze koppeling is gesignaleerd in de worktrees-analyse (zie cross-link onderaan) en moet structureel weg: niet door per-worktree workarounds, maar door de dev-omgeving als geheel een eigen mail-bestemming te geven. Aanleiding is concreet: zodra worktrees in gebruik komen, wordt het aantal "test-submits" hoger, en daarmee het risico op vervuilde productie-mailboxen en onbedoelde communicatie naar klant-adressen.

---

## 2. Actoren

| Actor | Rol | Toegang / recht |
|-------|-----|-----------------|
| Beheerder (niet-technisch) | Test het contactformulier in dev en verifieert de inhoud van de gevangen mail in de browser-inbox | Lezer van de mailcatcher-inbox |
| Ontwikkelaar / AI-agent | Wijzigt de form-handler of het formulier en verifieert het effect zonder productie te raken | Lezer en startverantwoordelijke voor de dev-stack |
| Productie-server | Draait de site met echte SMTP en mag geen mailcatcher-component meekrijgen | Geen — expliciet uitgesloten |
| Mailcatcher-service | Vangt SMTP-verbindingen en toont mail in de inbox | Eigenaar van eigen inbox-state, draait alleen in dev |

---

## 3. Scope

### In scope

- Dev-stack krijgt een aparte mail-bestemming waar alle uitgaande mail uit de dev-site bij aankomt.
- Mailcatcher draait als lokale, in de dev-stack ingesloten dienst — geen externe service, geen accountregistratie en geen credential-beheer voor de beheerder.
- Browser-bereikbare inbox-weergave met afzender, ontvanger, onderwerp, body en headers van elke gevangen mail.
- Auto-start van de mailcatcher samen met de dev-stack: één commando brengt site én mailcatcher op, zonder extra stap voor de beheerder.
- Auto-stop van de mailcatcher samen met de dev-stack.
- Het mailcatcher-blok in het dev-`docker-compose`-bestand draagt een expliciete dev-only-markering, zodat een lezer in één oogopslag ziet dat het component niet voor productie bedoeld is.
- Eén env-voorbeeldbestand met dev-veilige defaults (mail-bestemming wijst out-of-the-box naar de mailcatcher); inline-commentaar markeert welke waarden een hypothetische Docker-deploy op productie zou moeten overschrijven. Productie gebruikt vandaag geen env-bestand — de huidige hosting leest een eigen mail-config-bestand rechtstreeks.
- Onboarding-documentatie die uitlegt waar de inbox bereikbaar is en hoe de beheerder gevangen mail bekijkt.
- Heldere foutmelding bij form-submit als de mailcatcher niet draait, zonder dat de rest van de site valt.

### Niet in scope

- Productie-SMTP-configuratie — productie blijft ongewijzigd en ontvangt nooit mailcatcher-config.
- Per-worktree afwijkende mailbestemming — worktrees erven de dev-mail-bestemming via hun env-koppeling; afwijkingen vallen onder de worktrees-feature.
- Aanpassingen aan validatie-, anti-spam- of rate-limiting-gedrag van de form-handler — die blijven ongewijzigd. Wel toegestaan: minimale parametrisering van SMTP-encryptie en cert-verificatie via config-keys, zodat zowel productie-SMTP (TLS met geverifieerde cert) als dev-mailcatcher (TLS met self-signed cert) vanuit dezelfde codepad bereikbaar zijn.
- Mail-archivering, audit-trail of langetermijn-bewaring — de inbox is een dev-werkbank, geen logsysteem.
- HTML-mail-rendering of header-modificatie — formulier verstuurt nu plaintext; rendering-kwaliteit van de inbox is buiten beoordeling.
- Authenticatie op de inbox-applicatie — niet in scope; toegangscontrole loopt volledig via Tailscale-netwerk-lidmaatschap. Toevoegen van een nieuw apparaat of lid aan het Tailscale-netwerk staat gelijk aan het verlenen van leestoegang tot alle gevangen mail. De beheerder accepteert deze grens als kalm risico voor het huidige netwerk (kleine, vertrouwde set apparaten).

---

## 4. Happy path

1. Ontwikkelaar of beheerder start de dev-stack met het bestaande start-commando.
2. De dev-stack levert zowel de site als de mailcatcher op; beide zijn bereikbaar via een vooraf-gedocumenteerde lokale URL.
3. Bezoeker (in de praktijk: beheerder of ontwikkelaar tijdens een test) vult het contactformulier in en verstuurt het.
4. De dev-site bezorgt de mail bij de mailcatcher in plaats van bij een echte mailbox.
5. Beheerder opent de mailcatcher-inbox in de browser en ziet de zojuist verzonden mail binnen enkele seconden in de lijst staan.
6. Beheerder opent de mail en bevestigt afzender, ontvanger, onderwerp en body conform het ingevulde formulier.
7. Beheerder of ontwikkelaar stopt de dev-stack; mailcatcher en site stoppen samen.

---

## 5. Edge cases

| Situatie | Functioneel gewenst gedrag |
|----------|----------------------------|
| Mailcatcher draait niet (handmatig gestopt of gecrasht) terwijl een form-submit binnenkomt | Form-submit faalt met een heldere foutboodschap; statische pagina's blijven bereikbaar; rest van de site werkt door |
| Mailcatcher-poort is bezet door een ander proces tijdens dev-stack-start | Dev-stack-start meldt het conflict; beheerder krijgt een zichtbare foutboodschap zodat de mailcatcher niet stilzwijgend uit blijft |
| Inbox loopt vol omdat de mailcatcher niets persisteert tussen sessies | De inbox produceert geen blokkade; oudste mail mag verdrongen worden — acceptabel in dev |
| Dev-host of dev-stack wordt herstart en beheerder zoekt eerder gevangen mail | Eerder gevangen mail is na herstart niet meer beschikbaar; ephemeral inbox is het bedoelde gedrag — voor verificatie wordt opnieuw een form-submit gedaan |
| Worktree gebruikt een afwijkende env-koppeling en wijst niet naar de mailcatcher | Form-submit in die worktree raakt mogelijk productie-SMTP; functioneel gevolg is dezelfde situatie als vóór deze feature — wordt gemitigeerd door de worktrees-feature |
| Toekomstige Docker-deploy op productie kopieert het dev-env-voorbeeldbestand zonder de mail-overrides toe te passen | Productie-mail wijst dan naar een onbereikbare mailcatcher-host en faalt zichtbaar; inline-commentaar in het voorbeeldbestand markeert welke waarden overschreven moeten worden, zodat de fout meteen verklaarbaar is |
| Beheerder verwijdert de mailcatcher-container handmatig terwijl de site draait | Volgende form-submit faalt zoals bij "mailcatcher draait niet"; geen impact op statische pagina's |
| Nieuw apparaat / persoon krijgt toegang tot het Tailscale-netwerk | Het nieuwe lid heeft per direct leestoegang tot alle gevangen mail in de inbox; onboarding-doc en netwerk-beheer waarschuwen hiervoor — toelating tot Tailscale = de-facto inbox-toegang |
| Een test-form-submit bevat onbedoeld echte PII (bv. Anja test met een klantnaam, herkenbaar afzender-IP, of mail-headers) | Die PII is zichtbaar voor alle Tailscale-leden zolang de mail in de ephemeral inbox staat; mailbody bevat het IP-adres van de afzender en Mailpit toont volledige headers (Message-ID, Received-pad). Onboarding-doc adviseert fictieve testdata én verzending vanaf een Tailscale/VPN-IP, niet vanaf een herleidbaar publiek IP |
| Mailcatcher accepteert TLS- of auth-config van de form-handler niet (verkeerde cert, ontbrekende auth-accept-any) | Form-submit faalt zichtbaar met dezelfde generieke foutmelding als bij gestopte mailcatcher; statische pagina's blijven onverstoord — uitval-pad geldt onverkort, geen apart foutscherm nodig |

---

## 6. Acceptatiecriteria

- AC-mailcatcher1 — Form-submit op de dev-site produceert geen mail bij productie-`MAIL_TO` of bij andere productie-mailboxen.
- AC-mailcatcher2 — Eén form-submit op de dev-site levert twee mails in de mailcatcher-inbox: één met `MAIL_TO` als ontvanger en de bericht-body uit het formulier, én één met het door de bezoeker ingevulde e-mailadres als ontvanger en de bezoekers-bevestigingstekst. Beide mails verschijnen binnen vijf seconden bij een al-draaiende mailcatcher-container; bij koude start (eerste image-pull) geldt een ruimer venster van dertig seconden.
- AC-mailcatcher3 — Het start-commando van de dev-stack levert de mailcatcher mee op zonder extra commando; de inbox is zichtbaar op de in de onboarding-doc vermelde URL.
- AC-mailcatcher4 — Het stop-commando van de dev-stack produceert geen achterblijvende mailcatcher-processen of -containers.
- AC-mailcatcher5 — Productie-deploy passeert zonder mailcatcher-component: een SFTP-inspectie van de mijn.host-host bevestigt dat productie-compose-config en productie-runtime geen mailcatcher-service bevatten. Validatie vereist productie-host-toegang en wordt door de release-uitvoerder afgevinkt, niet door een ontwikkelaar zonder SFTP-key.
- AC-mailcatcher6 — Bij een gestopte mailcatcher faalt alleen de form-submit met een heldere fout; statische pagina's tonen onverstoord en andere routes blokkeren niet.
- AC-mailcatcher7 — Het env-voorbeeldbestand vermeldt expliciet welke waarden voor dev en welke voor productie bedoeld zijn, zodat een nieuwe checkout meteen naar de mailcatcher wijst en niet per ongeluk naar productie-SMTP.
- AC-mailcatcher8 — De onboarding-documentatie vermeldt de URL van de inbox, de stappen om gevangen mail te bekijken zonder terminal, én de waarschuwing dat alle Tailscale-leden meelezen — inclusief het advies om fictieve testdata te gebruiken én te verzenden vanaf een Tailscale/VPN-IP (mailbody bevat het afzender-IP en mail-headers blijven volledig zichtbaar in Mailpit).
- AC-mailcatcher9 — Productie-mail blijft uitsluitend bij de echte SMTP-bestemming, vastgesteld via twee inspecties op de productie-host (release-uitvoerder, SFTP): (a) `private/contact-mail.config.php` heeft `smtp_host` op `mail.groeiwijze.nl` zonder mailcatcher-host-string; (b) een form-submit-test op de productie-site levert geen verkeer naar een mailcatcher-host.
- AC-mailcatcher10 — De mailcatcher-inbox is zichtbaar voor Tailscale-leden en geblokkeerd voor publiek internet, vastgesteld via drie observaties: (a) `curl http://localhost:8025` op de dev-host levert HTTP 200; (b) `curl https://<tailscale-name>:8444` van een Tailscale-peer levert HTTP 200; (c) `curl http://<dev-host-publiek-IP>:8025` vanaf een niet-Tailscale netwerk levert connection refused of timeout. Afdwinging loopt via host-binding op `127.0.0.1` plus Tailscale-Serve-publicatie.

---

## 7. Impact op bestaande flows en data

- **Raakt:** dev-`docker-compose`-configuratie (extra service-blok, host-binding op `127.0.0.1`), dev-env-bestand (mail-bestemming wijst naar mailcatcher), env-voorbeeldbestand (één bestand met dev-veilige defaults en inline-commentaar voor prod-overrides), `docker/groeiwijze/generate-config.sh` (twee nieuwe config-keys voor SMTP-encryptie en cert-verificatie), `docker/groeiwijze/contact-submit.php` (dev-Docker-codepad — leest de twee nieuwe config-keys via PHPMailer), `start-sites.sh` (extra Tailscale-Serve-regel voor inbox), onboarding-doc en project-README. **Niet geraakt:** `website/contact-submit.php` is bron van waarheid voor het SFTP/productie-codepad en blijft ongewijzigd; het contactformulier en validatie-/anti-spam-/rate-limiting-gedrag veranderen niet. Productie blijft op de bestaande SFTP-deploy met directe mail-config zonder env-bestand.
- **Blokkeert:** geen externe afhankelijkheden — kan zelfstandig opgeleverd worden.
- **Blokkeert-door:** worktrees-feature consumeert deze feature impliciet (zodra de env-koppeling van een worktree naar de mailcatcher wijst, zijn form-submits in de worktree veilig).
- **Effect op bestaande data:** geen — er bestaan nog geen mailcatcher-data; productie-mailboxen blijven ongewijzigd.
- **Effect op bestaande gebruikers:** beheerder krijgt een Tailscale-URL voor de inbox (vergelijkbaar met hoe de site al via Tailscale bereikbaar is) en moet de eerste keer de plek van die URL kennen via onboarding; alle huidige Tailscale-leden krijgen leestoegang tot de inbox; ontwikkelaars zien geen wijziging in hoe de stack gestart wordt; productie-bezoekers merken niets.

---

## 8. Validatie en randvoorwaarden

- **Precondities:** dev-host heeft Docker en de bestaande dev-stack draaiend; env-bestand is aangemaakt vanuit het voorbeeldbestand met dev-defaults; productie-deploy gebruikt nog steeds zijn bestaande directe mail-config-bestand en geen env-bestand.
- **Invariants:** zolang de dev-stack draait, wijst de mail-bestemming van de site naar de mailcatcher; productie-runtime bevat nooit een mailcatcher-component — de afdwinging loopt via de architectuurkeuze dat productie geen Docker-runtime heeft (de huidige hosting voert het dev-`docker-compose`-bestand niet uit); de mailcatcher heeft geen externe afhankelijkheden buiten de dev-host (geen cloud-account, geen API-sleutels); de mailcatcher-poorten zijn op de dev-host gebonden aan `127.0.0.1`, zodat publiek internet de inbox niet rechtstreeks kan bereiken — Tailscale-Serve is de enige extern-toegankelijke route; Tailscale-netwerk-lidmaatschap is de enige toegangsgrens voor de inbox — er is geen aparte inbox-authenticatie; dev-`.env` en mailcatcher-env bevatten geen productie-SMTP-credentials (dummy-waarden volstaan in dev).
- **Postcondities:** na form-submit in dev is de mail aanwezig in de mailcatcher-inbox en niet bezorgd bij een productie-mailbox; na stoppen van de dev-stack draait geen mailcatcher-proces meer; eerder gevangen mail is na een herstart niet meer beschikbaar (ephemeral inbox).

---

## Cross-link

- Aanleiding: `.ai/features/worktrees/analysis.md` §11.3 en §12.
