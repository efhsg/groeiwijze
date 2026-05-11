# Skills Registry

## Beschikbare skills

### Domeinspecifiek

| Skill | Beschrijving | Contract |
|-------|-------------|----------|
| Adaptive Intake Flow | Intake/check flow ontwerp (Groen/Oranje/Rood) | `skills/groeiwijze-adaptive-intake-flow/SKILL.md` |
| Adaptive Site Structure | Site-structuur keuze (one-pager/multi-page/hybrid) | `skills/groeiwijze-adaptive-site-structure/SKILL.md` |
| Website UX Coach | UX-expert persona die ADHD-vriendelijk begeleidt bij website-verbeteringen | `skills/website-ux-coach.md` |

### Validatie & Review

| Skill | Beschrijving | Contract |
|-------|-------------|----------|
| Triage Review | Externe code review kritisch beoordelen | `skills/triage-review.md` |
| Review Changes | Gestructureerde review voor commit (kleuren, BEM, a11y, content, security) | `skills/review-changes.md` |
| Improve Prompt | Prompt-bestand in `.ai/prompts/` analyseren en verbeteren | `skills/improve-prompt.md` |
| Improve Role | Rolbestand in `.ai/prompts/roles/` analyseren en verbeteren | `skills/improve-role.md` |
| Optimize Skill | Skill-bestand structureel reviewen en optimaliseren | `skills/optimize-skill.md` |
| Evaluate Skill | Semantische evaluatie van een skill (read-only, advies) | `skills/evaluate-skill.md` |
| Validate Spec | Lichtgewicht checklist-validatie van een feature-spec | `skills/validate-spec.md` |
| Audit Config | Auditeer Claude-configuratiebestanden op gaps | `skills/audit-config.md` |
| Check Standards | Pre-flight check op gestaged bestanden | `skills/check-standards.md` |
| Website Review | UI/UX en toegankelijkheidsreview | `skills/website-review.md` |
| Analyze Codebase | Regenereer `codebase_analysis.md` | `skills/analyze-codebase.md` |

### Deployment

| Skill | Beschrijving | Contract |
|-------|-------------|----------|
| Publish | Veilige wrapper rond `./scripts/publish.sh` — dry-run default, live met confirmation | `skills/publish.md` |

### Workflow

| Skill | Beschrijving | Contract |
|-------|-------------|----------|
| Finalize Changes | Review checklist doorlopen en commitbericht voorstellen | `skills/finalize-changes.md` |
| Archive Design | Feature directory archiveren naar `.ai/features/.archive/` | `skills/archive-design.md` |
| New Branch | Nieuwe feature- of fix-branch aanmaken | `skills/new-branch.md` |
| New Spec | Lichtgewicht feature-spec genereren onder `.ai/features/{naam}/` | `skills/new-spec.md` |
| Refactor | Structurele verbeteringen zonder gedragswijziging | `skills/refactor.md` |
| Refactor Plan | Refactor analyseren en plannen (geen wijzigingen) | `skills/refactor-plan.md` |
| Commit Push | Staged changes committen en pushen naar origin | `skills/commit-push.md` |
| Onboarding | Snelle start — project overview, key files, commands | `skills/onboarding.md` |
| Custom Buttons | Slash-syntax en bracket-syntax voor klikbare keuzes | `skills/custom-buttons.md` |
| Worktree Workflow | Hoe agents zich gedragen in PromptManager's gebruiker-gestuurde worktree-flow | `skills/worktree-workflow.md` |
| Note | Schrijf een AI Note in het PromptManager-project via de runner-wrapper | `skills/note.md` |

## Beschikbare commands (slash)

### Workflow

| Command | Doel |
|---------|------|
| `/new-branch` | Nieuwe branch aanmaken |
| `/new-spec` | Lichtgewicht feature-spec genereren |
| `/check-standards` | Snelle pre-flight check op gestaged bestanden |
| `/review-changes` | Volledige review van wijzigingen vóór commit |
| `/finalize-changes` | Checklist + commitbericht voorstellen |
| `/commit-push` | Commit en push naar origin |
| `/archive-design` | Design directory archiveren |
| `/refactor` | Structurele code-verbeteringen |
| `/refactor-plan` | Plan een refactor (analyse zonder wijzigingen) |
| `/onboarding` | Project quick start |
| `/note` | Schrijf een AI Note via de runner-wrapper |

### Deployment

| Command | Doel |
|---------|------|
| `/publish` | Site naar mijn.host pushen (dry-run default; `live` voor echte deploy) |

### Persona

| Command | Doel |
|---------|------|
| `/website-ux-coach` | Activeer Website UX Coach persona voor de sessie |

### Validatie & analyse

| Command | Doel |
|---------|------|
| `/improve-prompt` | Prompt verbeteren |
| `/improve-role` | Rol verbeteren |
| `/triage-review` | Externe review beoordelen |
| `/website-review` | UI/UX en toegankelijkheidsreview |
| `/audit-config` | Harnassing zelf auditen op gaps |
| `/optimize-skill` | Skill structureel optimaliseren |
| `/evaluate-skill` | Skill semantisch evalueren (read-only) |
| `/validate-spec` | Feature-spec checklist-validatie |
| `/analyze-codebase` | Regenereer `codebase_analysis.md` |

## Topic routing

| Onderwerp | Laad skill |
|-----------|-----------|
| intake, check, matching, doorverwijzing, "past dit bij jou" | Adaptive Intake Flow |
| structuur, navigatie, IA, one-pager, multi-page, hybrid | Adaptive Site Structure |
| externe review, triage, feedback, code review, beoordeling | Triage Review |
| review vóór commit, code kwaliteit, stijlcheck | Review Changes |
| pre-flight check, snel screenen, vóór commit | Check Standards |
| afronden, commit, checklist, finalize | Finalize Changes |
| commit, push, naar origin sturen | Commit Push |
| prompt verbeteren, prompt kwaliteit, .ai/prompts/ | Improve Prompt |
| rol verbeteren, role persona, .ai/prompts/roles/ | Improve Role |
| design archiveren, opruimen, voltooide feature | Archive Design |
| nieuwe branch, feature starten, git branch | New Branch |
| nieuwe feature-spec, plan, design directory | New Spec |
| spec valideren, spec compleet, AC-checks | Validate Spec |
| refactoren, opschonen, DRY, duplicatie | Refactor |
| refactor plannen, analyse, voorbereiding | Refactor Plan |
| nieuwe sessie, project overzicht, quick start | Onboarding |
| keuze-buttons, slash-syntax, custom-buttons | Custom Buttons |
| website review, UI/UX, visueel, healthcare lens | Website Review |
| harnassing audit, config audit, gaps | Audit Config |
| skill verbeteren, skill review, skill check | Optimize Skill |
| skill semantisch beoordelen, skill diepgang | Evaluate Skill |
| codebase overzicht regenereren | Analyze Codebase |
| publish, deploy, naar mijn.host pushen, live zetten, --dry-run, --live | Publish |
| UX coach, persona aannemen, ADHD-vriendelijke begeleiding, focus houden, parkeer-notes | Website UX Coach |
| worktree, sync, merge back, mergeback, branch-flow | Worktree Workflow |
| note, ai note, vastleggen, beslissing opslaan, bevinding bewaren | Note |

## Bestandspatroon routing

Zie `.claude/rules/skill-routing.md` voor automatische routing op bestandstype.

## Gebruik

1. Lees eerst de relevante rules in `.claude/rules/`
2. Scan deze index voor een relevante skill
3. Laad alleen de benodigde skill — niet allemaal tegelijk
4. Volg het contract (SKILL.md of skill.md) van de geladen skill
