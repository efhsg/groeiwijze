---
name: commit-push
description: Commit staged changes en push naar origin na expliciete opdracht
area: workflow
provides:
  - git_commit_push
depends_on:
  - rules/workflow.md
---

# Commit Push

Commit en push wijzigingen nadat de gebruiker expliciet `/commit-push` aanroept of opdracht geeft.

## When to Use

- Gebruiker vraagt om commit en push
- Na `/finalize-changes` met goedgekeurd commitbericht

## Algorithm

1. Run `git diff --staged --stat` en `git diff --stat`.
2. Als staged wijzigingen aanwezig zijn, gebruik die.
3. Als er alleen unstaged wijzigingen zijn, stage met `git add -A`.
4. Als er geen wijzigingen zijn, meld "Niets te committen" en stop.
5. Bepaal commitbericht:
   - `$ARGUMENTS` als opgegeven
   - anders eerder voorgesteld bericht
   - anders genereer volgens `rules/workflow.md`
6. Run `git commit -m`.
7. Run `git push origin HEAD`.
8. Bij remote conflict: `git pull --rebase origin HEAD`, daarna opnieuw pushen.
9. Meld commithash en push-status.

## Constraints

- Voeg geen `Co-Authored-By` of AI-attributie toe
- Gebruik geen destructieve git-commands
- Respecteer bestaande unstaged wijzigingen; revert niets

## Definition of Done

- Wijzigingen zijn gecommit
- Branch is naar origin gepusht
- Output noemt commithash
