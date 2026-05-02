---
allowed-tools: Bash, Read
description: Commit staged changes en push naar origin
---

# Commit and Push

## Stappen

### 1. Controleer wijzigingen

```bash
git diff --staged --stat
git diff --stat
```

- **Staged wijzigingen aanwezig** → ga naar stap 2
- **Geen staged maar wel unstaged** → `git add -A`, dan stap 2
- **Geen wijzigingen** → meld "Niets te committen" en stop

### 2. Bepaal commitbericht

Volg deze volgorde:

1. **Als `$ARGUMENTS` opgegeven** → gebruik als commitbericht
2. **Als eerder in dit gesprek een bericht voorgesteld** → gebruik dat
3. **Anders** → genereer bericht:
   - Lees `.claude/rules/workflow.md` (commits sectie)
   - Run `git diff --staged`
   - Kies het juiste prefix (ADD/CHG/FIX/DEL/TXT/DOC)
   - Schrijf een beknopte beschrijving (~70 tekens)

### 3. Commit

```bash
git commit -m "$(cat <<'EOF'
PREFIX: beschrijving
EOF
)"
```

**Voeg geen `Co-Authored-By` of AI-attributie toe.**

### 4. Push

```bash
git push origin HEAD
```

**Als push mislukt:**
- Bij remote-conflict → `git pull --rebase origin HEAD` dan opnieuw pushen
- Bij andere fout → meld de fout en stop

Rapporteer succes met commithashe.

## Task

$ARGUMENTS
