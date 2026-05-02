# Triage Review: `.claude/design/live-reload-setup.md`

## Verdict: Document is accurate — script has minor robustness gaps

The design document faithfully describes the implemented `dev-reload.sh` script. Architecture, ports, options, and usage instructions all match the actual code. Below are the findings.

---

## Verified (correct)

| Claim in design doc | Actual code | Status |
|---|---|---|
| browser-sync proxies to Docker on `:8001` | `--proxy "localhost:8001"` | OK |
| Watches `website/**/*.{html,css,js}` | `--files "website/**/*.html, website/**/*.css, website/**/*.js"` | OK |
| browser-sync on port 3000 | `--port 3000` | OK |
| Tailscale serve `:3443` → `:3000` | `tailscale serve --bg --https=3443 http://localhost:3000` | OK |
| Docker check looks for "groeiwijze" | `docker compose ps --status running \| grep -q groeiwijze` | OK |
| `--no-open`, `--no-notify` flags | Present in script | OK |
| Requirements: Node, Docker, Tailscale, jq | All used in script | OK |
| Architecture diagram (3-tier proxy chain) | Matches implementation | OK |

---

## Issues found

### 1. Tailscale serve not cleaned up on exit (documented but unresolved)
**File:** `dev-reload.sh`
The doc warns that `tailscale serve --bg` survives Ctrl+C, but the script has no `trap` to clean up. A stale Tailscale serve binding can cause port conflicts on next run.

**Suggestion:** Add a cleanup trap:
```bash
trap 'tailscale serve --https=3443 off 2>/dev/null; echo "Tailscale serve stopped."' EXIT
```

### 2. `npx browser-sync` has no version pinning
**File:** `dev-reload.sh:33`
No `package.json` or lock file exists. `npx browser-sync` will either:
- Use a cached version (potentially outdated)
- Prompt interactively to install (breaking non-interactive use)
- Pull a different major version with breaking changes

**Suggestion:** Pin with `npx browser-sync@3` or add a minimal `package.json`.

### 3. No dependency checks before use
**File:** `dev-reload.sh`
`set -e` is present, but the script doesn't verify `tailscale`, `jq`, or `npx` exist. Failures produce cryptic errors like `jq: command not found` mid-execution (after Docker may already have been started).

**Suggestion:** Add upfront checks:
```bash
for cmd in docker tailscale jq npx; do
  command -v "$cmd" >/dev/null || { echo "Missing: $cmd"; exit 1; }
done
```

### 4. Docker detection is fragile
**File:** `dev-reload.sh:9`
`docker compose ps --status running | grep -q groeiwijze` greps service output for a string. If the service is renamed in `docker-compose.yml`, this silently fails and starts a duplicate container.

**Note:** The design doc says "containernaam met groeiwijze" but `docker compose ps` shows *service* names, not container names. Minor doc inaccuracy.

### 5. PHP and asset changes don't trigger reload
**File:** `dev-reload.sh:35`
Only `*.html`, `*.css`, `*.js` are watched. Changes to:
- `contact-submit.php` (form handler)
- `website/assets/img/*` (images, SVGs)

...won't trigger reload. This is likely intentional (PHP runs in Docker, images rarely change during dev), but the design doc doesn't explicitly state this scope limitation.

---

## Summary

| Category | Finding |
|---|---|
| **Doc accuracy** | Matches implementation — no misleading claims |
| **Architecture** | Sound. Proxy chain is clean and non-invasive |
| **Robustness** | Script lacks cleanup trap, dependency checks, version pinning |
| **Scope** | PHP/asset changes not watched (undocumented) |
| **Security** | No credentials exposed; Tailscale provides network isolation |

The design document is well-written and reliable. The script works but would benefit from the robustness improvements listed above. None of the issues are blocking — they're quality-of-life improvements for edge cases.
