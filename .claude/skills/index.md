# Skills Registry

## Beschikbare skills

### Domeinspecifiek

| Skill | Beschrijving | Contract |
|-------|-------------|----------|
| Adaptive Intake Flow | Intake/check flow ontwerp (Groen/Oranje/Rood) | `skills/groeiwijze-adaptive-intake-flow/SKILL.md` |
| Adaptive Site Structure | Site-structuur keuze (one-pager/multi-page/hybrid) | `skills/groeiwijze-adaptive-site-structure/SKILL.md` |

### Validatie & Review

| Skill | Beschrijving | Contract |
|-------|-------------|----------|
| Triage Review | Externe code review kritisch beoordelen | `skills/triage-review.md` |
| Review Changes | Gestructureerde review voor commit (kleuren, BEM, a11y, content, security) | `skills/review-changes.md` |
| Improve Prompt | Prompt-bestand in `.ai/prompts/` analyseren en verbeteren | `skills/improve-prompt.md` |
| Optimize Skill | Skill-bestand structureel reviewen en optimaliseren | `skills/optimize-skill.md` |
| Evaluate Skill | Semantische evaluatie van een skill (read-only, advies) | `skills/evaluate-skill.md` |
| Validate Spec | Lichtgewicht checklist-validatie van een feature-spec | `skills/validate-spec.md` |
| Audit Config | Auditeer Claude-configuratiebestanden op gaps | `commands/audit-config.md` (command-only) |
| Check Standards | Pre-flight check op gestaged bestanden | `commands/check-standards.md` (command-only) |
| Website Review | UI/UX en toegankelijkheidsreview | `commands/website-review.md` (command-only) |
| Analyze Codebase | Regenereer `codebase_analysis.md` | `commands/analyze-codebase.md` (command-only) |

### Workflow

| Skill | Beschrijving | Contract |
|-------|-------------|----------|
| Finalize Changes | Review checklist doorlopen en commitbericht voorstellen | `skills/finalize-changes.md` |
| Archive Design | Feature directory archiveren naar `.ai/features/.archive/` | `skills/archive-design.md` |
| New Branch | Nieuwe feature- of fix-branch aanmaken | `skills/new-branch.md` |
| New Spec | Lichtgewicht feature-spec genereren onder `.ai/features/{naam}/` | `skills/new-spec.md` |
| Refactor | Structurele verbeteringen zonder gedragswijziging | `skills/refactor.md` |
| Refactor Plan | Refactor analyseren en plannen (geen wijzigingen) | `commands/refactor-plan.md` (command-only) |
| Commit Push | Staged changes committen en pushen naar origin | `commands/commit-push.md` (command-only) |
| Onboarding | Snelle start — project overview, key files, commands | `skills/onboarding.md` |
| Custom Buttons | Slash-syntax en bracket-syntax voor klikbare keuzes | `skills/custom-buttons.md` |

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

### Validatie & analyse

| Command | Doel |
|---------|------|
| `/improve-prompt` | Prompt verbeteren |
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

## Bestandspatroon routing

Zie `.claude/rules/skill-routing.md` voor automatische routing op bestandstype.

## Gebruik

1. Lees eerst de relevante rules in `.claude/rules/`
2. Scan deze index voor een relevante skill
3. Laad alleen de benodigde skill — niet allemaal tegelijk
4. Volg het contract (SKILL.md of skill.md) van de geladen skill
