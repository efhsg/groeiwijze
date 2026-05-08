---
name: worktree-workflow
description: Hoe AI-agents zich gedragen in PromptManager's gebruiker-gestuurde worktree-flow — werk in de toegewezen worktree, geen merge of branch-switch
area: workflow
provides:
  - worktree_workflow
depends_on: []
---

# Worktree Workflow

Hoe AI-agents (Claude CLI, Claude Opus, Codex, Gemini) werken in de gebruiker-gestuurde git worktree-flow van PromptManager. De gebruiker beheert de branch-cyclus (aanmaken, synchroniseren, mergen) via de PromptManager-UI; de agent werkt binnen één worktree en blijft daar.

## Persona

AI-agent toegewezen aan één worktree door de gebruiker. Weet dat de branch van de worktree vastligt, weet dat merge-back een UI-actie is, en weigert op eigen initiatief branch-niveau git-operaties uit te voeren.

## Wanneer gebruiken

- Sessie start in een directory onder `/projects/grw/`
- Gebruiker noemt worktrees, sync-status, merge back, rebase, pull of branch-creatie
- Agent staat op het punt `git checkout`, `git merge`, `git rebase`, `git pull` of `git switch` uit te voeren
- Agent overweegt te lezen of schrijven in een sibling-worktree-directory

## Hoe worktrees hier werken

Een **git worktree** is een extra working tree gekoppeld aan dezelfde repository — een aparte directory uitgechecked op een andere branch, dezelfde `.git`-store. Geen clone, geen gedupliceerde history.

In dit project:

- De primaire working tree is de **main worktree** (branch `master`).
- Elke extra worktree is een sibling-directory naast de main: `<root>-<suffix>/` (bijvoorbeeld `/projects/grw/groeiwijze.nl-feature-test`).
- Worktrees worden aangemaakt, gesynced en verwijderd via de **PromptManager-UI**. De agent roept de plumbing niet zelf aan.
- De **actieve worktree** van een sessie wordt bij sessiestart bepaald door de URL-parameter `?wt=<suffix>` in de PromptManager-UI. De primaire werkdirectory van de sessie IS de actieve worktree.

## Workflow

```
[Gebruiker maakt worktree]   →   [AI-chat past aan]   →   [Gebruiker reviewt]   →   [Gebruiker merget naar master]
   (PromptManager-UI)             (agent-territorium)      (buiten scope)            (PromptManager-UI)
```

### 1. Gebruiker maakt de worktree aan

De gebruiker start een nieuwe worktree vanuit de PromptManager-UI. Onder de motorkap: `git worktree add -b <branch> <pad> master`, plus environment-setup.

**Agent-rol:** geen — de agent is nog niet actief voor deze worktree.

### 2. AI-chat past de code aan

De gebruiker opent een AI-chat-sessie scoped aan de worktree (`?wt=<suffix>`). De werkdirectory van de agent is het worktree-pad.

**VERPLICHTE regels:**

- **Lees en schrijf alleen binnen de actieve worktree.** Raak een sibling-worktree (`<root>-<andere-suffix>/`) niet aan zonder expliciete bevestiging van de gebruiker.
- **Wissel niet van branch.** Geen `git checkout <andere-branch>`, geen `git switch`. De branch ligt vast door de worktree.
- **Niet mergen, rebasen of pullen.** Sync-operaties worden door de gebruiker via de PromptManager-UI gestart.
- **Maak geen branches** vanuit een worktree. Branch-creatie hoort bij de worktree-creatie-flow of bij `/new-branch` als je in de main worktree werkt.
- **Commit op de eigen branch van de worktree.** `/finalize-changes` en `/commit-push` werken al op de huidige branch — dat is per ontwerp de branch van de worktree.

### 3. Gebruiker keurt goed en merget naar master

Wanneer de gebruiker tevreden is, start de **gebruiker** zelf de merge-back vanuit de PromptManager-UI. De UI-actie:

- Weigert als de worktree uncommitted changes heeft.
- Verifieert dat de root repo op de bron-branch (`master`) staat.
- Doet een dry-run conflict-check via `git merge-tree`.
- Voert `git merge --no-ff` uit van de worktree-branch naar `master`.

**Agent-rol:** geen. Als de gebruiker zegt "merge dit naar master," voer dan **niet** zelf `git merge` uit. Verwijs naar de merge-back-actie in de PromptManager-UI.

## Actieve worktree bepalen

| Aanwijzing | Actieve worktree |
|------------|------------------|
| Werkdirectory eindigt op `/groeiwijze.nl` | main worktree |
| Werkdirectory eindigt op `/groeiwijze.nl-<suffix>` | de worktree met die `path_suffix` |
| Sessie-URL bevat `?wt=<suffix>` | matcht de werkdirectory |
| Geen `?wt=` parameter | main worktree |

Werkdirectory en `?wt=` komen overeen bij sessiestart. Lijken ze midden in de sessie uit elkaar te lopen, stop en vraag voordat je schrijft.

## Stop Points

**VERPLICHT** — Stop en vraag wanneer:

- Gebruiker vraagt de agent om te mergen, rebasen of pullen in de worktree
- Gebruiker vraagt de agent om van branch te wisselen binnen een worktree
- Gebruiker vraagt de agent om een bestand te bewerken in een sibling-worktree-directory
- Werkdirectory en een expliciete worktree-referentie spreken elkaar tegen

Toon in zo'n geval:

`Open PromptManager-UI / Sla operatie over / Override en doorgaan?`

**Wacht op gebruikersinput. Ga NIET door totdat de gebruiker reageert.**

## Anti-patterns

| Niet doen | Wel doen |
|-----------|----------|
| `cd /projects/grw/groeiwijze.nl-andere-feature` | Blijf in de actieve worktree; bevestig vóór elke cross-worktree edit |
| `git checkout master` vanuit een worktree | Vertel de gebruiker een sessie te openen in de main worktree |
| `git merge feature/x` om wijzigingen in master te krijgen | Verwijs naar de PromptManager-UI merge-back-actie |
| `git pull` binnen een worktree | Verwijs naar de pull- of rebase-actie in de UI |
| Actieve worktree onthouden tussen sessies | Bepaal hem opnieuw uit de huidige werkdirectory bij elke sessie |

## Definition of Done

- Agent leest en schrijft alleen binnen de actieve worktree van de sessie
- Agent voert nooit `git merge`, `git rebase`, `git pull`, `git checkout <branch>` of `git switch` uit
- Bij vraag om merge / sync / branch-switch: agent stopt en wijst naar de PromptManager-UI
- Cross-worktree edits gebeuren alleen na expliciete bevestiging van de gebruiker

## Zie ook

- `.claude/rules/workflow.md` — algemene workflow-regels
- PromptManager `WorktreeService` — git plumbing in de PromptManager-codebase (read-only referentie, niet aanroepen)
