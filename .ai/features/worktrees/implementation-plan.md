# Implementatieplan — groeiwijze.nl worktrees + PromptManager composable-pipeline

> **Spiegel-versie.** Identiek aan `/var/www/worktree/main/.ai/features/groeiwijze-worktrees/implementation-plan.md`. Wijzigingen in deze file moeten in beide locaties worden doorgevoerd.

## Uitgangspunten

- Elke milestone levert een **afgerond product** dat zelfstandig getest, gecommit en eventueel ingeschoven kan worden zonder de rest van de roadmap af te wachten.
- Sommige milestones zijn klein en eindgebruiker-merkbaar; andere zijn groter en developer-merkbaar (architectuur-deliverables).
- Tracks (T1, T2) lopen los van de iteratie-milestones; ze hebben hun eigen tempo en zijn niet blokkerend voor M1-M4.

## Volgorde-overzicht

```
M1: dev-mailcatcher                    (los, vóór alles)
   ↓
M2: end-to-end worktree-flow            (PM + groeiwijze.nl gecombineerd)
   ↓
M3: PromptManager-UI compleet           (drift-detectie + merge-knop + recipe-display)
   ↓
M4: Rol-analyse-skill (iteratie 2)

T1 (track los): Yii2 stap-extractie     (PM fase 4, geleidelijk per PR, parallel of na M3)
T2 (track los): Roadmap-features        (DB-isolatie / vendor-config / port-allocatie, na T1)
```

## M1 — Dev-mailcatcher

**Afgerond product:** dev-omgeving stuurt form-submits naar mailcatcher (Mailpit lokaal of Mailtrap cloud), productie ongewijzigd. Beheerder kan via vaste URL gevangen mail bekijken.

**Scope:**
- Mailpit-container (of equivalent) toegevoegd aan `groeiwijze.nl/docker-compose.yml`
- Dev-`.env` SMTP-vars wijzen naar mailcatcher (`SMTP_HOST=mailpit`, `SMTP_PORT=1025`)
- Productie-`.env` ongewijzigd (productie-server houdt eigen `.env`)
- `.env.example` bijgewerkt met dev-vs-prod-annotaties
- Onboarding-doc / README: "Hoe bekijk je verzonden mail in dev"

**Validatie:** form-submit op `contact.html` in dev → mail in mailcatcher-UI binnen 5s; productie-mailbox blijft leeg.

**Waarom eerst:** alle worktrees-werk hierna produceert dev-form-submits; zonder mailcatcher gaan die naar productie. Veiligheidsblokkade.

**Geschatte omvang:** klein (1-2 dagen).

**Eigen analyse:** `/projects/groeiwijze.nl/.ai/features/dev-mailcatcher/analysis.md`

---

## M2 — End-to-end worktree-flow

**Afgerond product:** ontwikkelaar maakt via PromptManager (CLI of bestaande AJAX-endpoints) een worktree aan voor groeiwijze.nl; beheerder bezoekt URL en kan via switcher tussen main en worktree wisselen; main is default; verwijderde worktrees vallen terug op main.

### PromptManager-zijde (combineert fasen 1+2+3 uit migratiestrategie)

- `SetupStepInterface` — interface met `getName()`, `getDisplayLabel()`, `execute()`, `rollback()`, `dependsOn()`
- `StackPipeline` — `(Stack, SetupStep[])`-DTO
- Pipeline-registry in DI: `Stack → StackPipeline`
- `WorktreeSetupServiceV2` — pipeline-engine met topo-sort en faal-rollback
- `Stack` PHP-enum (`YII2`, `STATIC`)
- Migratie: `Project.stack` (varchar, default `yii2`)
- Migratie: `ProjectWorktree.setup_error_message` (varchar 500)
- `static`-recipe = `[]` geregistreerd in DI
- `Yii2LegacyStep`-wrapper roept huidige `WorktreeSetupService::setup()` aan
- `yii2`-recipe = `[Yii2LegacyStep]` geregistreerd
- `WorktreeService` (lifecycle) routeert naar `WorktreeSetupServiceV2`
- groeiwijze.nl als `Project`-record: `stack = static`, `root_directory = /projects/groeiwijze.nl`, `source_branch = master`
- Tests: leeg-recipe doorloop (AC-3), Yii2-regressie (AC-11), end-to-end met tijdelijke git-init (AC-2)

### groeiwijze.nl-zijde

- `docker-compose.yml`: mount aanpassen naar `/projects:/var/www/projects:ro`
- `nginx.conf` aangepast:
  - `map $arg_wt $wt_root` met suffix-whitelist `^[a-zA-Z0-9_-]{1,100}$`
  - `root $wt_root/website`
  - `try_files`-fallback naar main-pad voor stale `?wt=`
  - `Cache-Control: no-store` op asset-locaties bij aanwezige `?wt=`
  - `sub_filter '</body>'` voor switcher-injectie
  - `location ~ /private/` deny-block (bestaand, blijft gelden)
- `/_wt/list.php` — filesystem-scan op `groeiwijze.nl-*` sibling-dirs, JSON-output
- `/_wt/switcher.js` — klikbare widget met badge voor actieve worktree
- Smoke-test: `start-sites.sh`, worktree handmatig aanmaken, switchen, fallback testen, path-traversal weren

### Validatie (eindgebruiker-merkbaar)

- worktrees-doc: AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-11
- PromptManager-doc: AC-1 t/m AC-5, AC-9 t/m AC-12

**Geschatte omvang:** groot (~9-10 dagen voor één persoon). Splitsbaar in twee parallel-tracks (PM-developer + groeiwijze.nl-developer) — verkort doorlooptijd, vereist coördinatie aan integratie-einde.

**Niet splitsen in M2a/M2b:** PM-side zonder groeiwijze.nl-side is niet eindgebruiker-merkbaar; en omgekeerd. Behandel als één milestone met interne taakverdeling.

---

## M3 — PromptManager-UI compleet

**Afgerond product:** niet-technische beheerder kan via PromptManager-UI worktrees zien, status volgen, ghost-records opruimen, en goedkeuren-en-mergen via één knop.

**Scope:**
- Project-detail-page: data-driven recipe-weergave (leest `StackPipeline.steps`, toont `getDisplayLabel()`)
- Lege recipe → expliciete melding "Geen setup-stappen — git worktree volstaat"; stappenlijst verborgen
- Stack-dropdown bij Project-aanmaak met korte beschrijving per stack
- `setup_error_message` getoond bij failure-status (eerste regels van exception)
- Drift-detectie endpoint + UI integratie (FR-11):
  - Bij page-load reconciliatie-check tussen DB en filesystem
  - Ghost-records (DB-record zonder dir) → "Verwijder ghost-record"-knop
  - Onbekende dirs (dir zonder DB-record) → "Importeer onbekende worktree"-knop
- "Goedkeuren en merge naar main"-knop op worktree-row
  - Conflict-pre-check via bestaande `WorktreeService::mergeBack()`
  - Bij conflict: UI-melding met opties "pull/rebase eerst" of "annuleren"
  - Auto-cleanup OFF: worktree blijft staan na merge
  - UI-tekst maakt expliciet dat productie-deploy aparte stap is

**Validatie:**
- worktrees-doc: AC-12 (goedkeuren-en-merge via UI)
- PromptManager-doc: FR-11 (drift-detectie + 1-klik-acties)

**Geschatte omvang:** middel (~7-8 dagen).

**Afhankelijkheid:** M2 moet af (UI heeft pipeline-engine + groeiwijze.nl-Project nodig om iets te tonen).

---

## M4 — Rol-analyse-skill iteratie 1

**Afgerond product:** beheerder of ontwikkelaar triggert via skill/command een rol-analyse over de delta tussen twee worktrees; per gekozen rol een md-rapport in de worktree-directory.

**Scope:**
- Skill-scaffolding conform bestaande `.claude/skills/`-conventie in groeiwijze.nl
- Inputs: rol-keuze (multi-select uit `groeiwijze.nl/.ai/prompts/roles/`), source-worktree, target-worktree (default `main`)
- Diff-generatie: `git diff <source>..<target>` + lijst van geraakte HTML-pagina's
- Per geselecteerde rol: rol-prompt + diff + (optioneel) gerenderde HTML-content als context
- LLM-call orchestratie
- Output: md-rapport per rol per vergelijking in `<worktree>/.ai/reviews/<timestamp>/<rol>.md`
- Output-pad in `.gitignore`

**Validatie:** AC-10 (worktrees-doc) — skill accepteert juiste inputs, produceert rapporten.

**Geschatte omvang:** middel (~5 dagen).

**Afhankelijkheid:** M2 moet af (skill heeft minstens twee worktrees nodig).

**Iteratie 2-uitbreidingen** (latere milestones, eigen track):
- Screenshots via headless Chrome (sidecar-container)
- Lighthouse / axe-output als rol-input
- Async queue + UI-knop in PromptManager
- Per-pagina-granulariteit (apart rapport per pagina)

---

## T1 (track los) — Yii2 stap-extractie

**Afgerond product per PR:** één Yii2-stap uit `Yii2LegacyStep`-wrapper getrokken naar eigen Step-class met expliciet `dependsOn()`, `rollback()`, `getDisplayLabel()`.

**Volgorde per PR:**

1. `EnvSymlinkStep` — kleinste, geen state-afhankelijkheden; eerste extractie als template
2. `RuntimeDirsStep` — onafhankelijk, snel
3. `StorageSymlinkStep` — onafhankelijk
4. `ComposerVendorStep` — grootste; depends on niets; bevat ook fallback-logica naar `composer install`

Eindstaat: `yii2`-recipe = `[ComposerVendorStep, EnvSymlinkStep, RuntimeDirsStep, StorageSymlinkStep]`; `Yii2LegacyStep`-wrapper verdwijnt.

**Validatie per PR:** AC-11 (bestaande tests slagen onveranderd) + AC-12 (handmatige rooktest Yii2-worktree round-trip).

**Niet blokkerend voor iteratie 1.** Kan parallel of na M3 starten. Geleidelijk over weken in te plannen.

**Waarom als losse track:** elke PR is geïsoleerd; geen koppeling met eindgebruiker-features.

---

## T2 (track los) — Roadmap-features

Eigen feature-analyse per item zodra opgepakt:

| Feature | Vereist | Levert |
|---------|---------|--------|
| DB-isolatie per worktree | Composable steps volledig (na T1) | `DbSchemaCreateStep`, `DbMigrateStep`, `DsnWriteStep` per stack |
| Vendor-config-regen per worktree | Composable steps volledig | `ComposerDumpAutoloadStep`, `NpmRebuildStep` per stack |
| nginx-port-allocatie / reverse-proxy-orchestratie | Composable steps volledig | `NginxPortAllocateStep`, `NginxConfigWriteStep`; alternatief routerings-mechanisme naast `?wt=` |

Niet binnen scope van iteratie 1 of 2. Track activeert pas na T1.

---

## Volgorde-rationale

| Volgorde-keuze | Reden |
|----------------|-------|
| M1 vóór M2 | Mailbox-veiligheid is voorwaarde voor dev-form-submits in worktrees |
| M2 als één milestone (niet split PM/groeiwijze) | PM-side zonder groeiwijze.nl-side levert geen eindgebruiker-merkbaar product, en omgekeerd; samen leveren ze de eerste echte gebruikswaarde |
| M3 ná M2 | UI heeft pipeline-engine + groeiwijze.nl-Project nodig om iets zinvols te tonen |
| M4 ná M2 | Rol-analyse vergelijkt twee worktrees — minimaal één werkende worktree-flow vereist |
| T1 parallel of na M3 | Geen eindgebruiker-impact; technische schulden-aflossing |
| T2 ná T1 | DB-isolatie en vendor-regen vereisen composable Step-classes (niet legacy-wrapper) |

---

## Doorlooptijd-schatting

Bij één persoon op iteratie-track:

| Milestone | Omvang | Cumulatief |
|-----------|--------|-----------|
| M1 | 1-2 dagen | 2 dagen |
| M2 | 9-10 dagen | 12 dagen |
| M3 | 7-8 dagen | 20 dagen |
| M4 | 5 dagen | 25 dagen |

Iteratie 1 (M1+M2+M3): ~3 weken werk.
Iteratie 1+2 (M1+M2+M3+M4): ~4 weken werk.

Bij twee personen parallel op M2 (PM + groeiwijze.nl tracks): M2-doorlooptijd ~5 dagen ipv 9-10. Iteratie 1 dan ~2 weken.

T1 + T2 lopen daarna of parallel — geen vaste schatting.

---

## Cross-links

- groeiwijze.nl-functionele analyse: `/projects/groeiwijze.nl/.ai/features/worktrees/analysis.md`
- PromptManager-functionele analyse: `/var/www/worktree/main/.ai/features/groeiwijze-worktrees/analysis.md`
- Aanpalende feature: `/projects/groeiwijze.nl/.ai/features/dev-mailcatcher/analysis.md`
- Spiegel-versie van dit plan: `/var/www/worktree/main/.ai/features/groeiwijze-worktrees/implementation-plan.md`
