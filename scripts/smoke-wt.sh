#!/usr/bin/env bash
# Dev-only smoke-validatie voor worktree-routering.
# Draait een lijst curl-checks tegen http://localhost:8001/ en verifieert
# routing, fallback, headers, deny-rules en list-output.
#
# Exit 0 bij alle checks groen, niet-nul bij eerste falen met diagnostiek.

set -uo pipefail

BASE_URL="${SMOKE_BASE_URL:-http://localhost:8001}"
SIBLING_SUFFIX="${SMOKE_SIBLING:-feature-testing}"
PASS=0
FAIL=0

red() { printf '\033[31m%s\033[0m' "$1"; }
green() { printf '\033[32m%s\033[0m' "$1"; }
dim() { printf '\033[2m%s\033[0m' "$1"; }

# Voer een curl en check status + optionele header-pattern.
# Args: name url expected_status [header_pattern]
check() {
    local name="$1"
    local url="$2"
    local expected_status="$3"
    local header_pattern="${4:-}"

    local response
    response=$(curl -sS -o /dev/null -D - --max-time 5 "$url" 2>&1) || {
        printf '  %s %s — curl-fout\n' "$(red '✗')" "$name"
        FAIL=$((FAIL + 1))
        return
    }

    local actual_status
    actual_status=$(printf '%s' "$response" | head -n1 | awk '{print $2}')

    if [[ "$actual_status" != "$expected_status" ]]; then
        printf '  %s %s — verwacht status %s, kreeg %s\n' "$(red '✗')" "$name" "$expected_status" "$actual_status"
        FAIL=$((FAIL + 1))
        return
    fi

    if [[ -n "$header_pattern" ]] && ! printf '%s' "$response" | grep -qiE "$header_pattern"; then
        printf '  %s %s — header-pattern niet gevonden: %s\n' "$(red '✗')" "$name" "$header_pattern"
        FAIL=$((FAIL + 1))
        return
    fi

    printf '  %s %s\n' "$(green '✓')" "$name"
    PASS=$((PASS + 1))
}

# Voer een curl en check body-substring.
# Args: name url expected_status body_substring
check_body() {
    local name="$1"
    local url="$2"
    local expected_status="$3"
    local body_substring="$4"

    local body status
    body=$(curl -sS -o /tmp/smoke-body -w '%{http_code}' --max-time 5 "$url" 2>&1) || {
        printf '  %s %s — curl-fout\n' "$(red '✗')" "$name"
        FAIL=$((FAIL + 1))
        return
    }
    status="$body"

    if [[ "$status" != "$expected_status" ]]; then
        printf '  %s %s — verwacht status %s, kreeg %s\n' "$(red '✗')" "$name" "$expected_status" "$status"
        FAIL=$((FAIL + 1))
        return
    fi

    if ! grep -qF "$body_substring" /tmp/smoke-body; then
        printf '  %s %s — body bevat geen "%s"\n' "$(red '✗')" "$name" "$body_substring"
        FAIL=$((FAIL + 1))
        return
    fi

    printf '  %s %s\n' "$(green '✓')" "$name"
    PASS=$((PASS + 1))
}

printf 'Smoke worktree-routering tegen %s\n' "$(dim "$BASE_URL")"
printf '\n'

printf 'Routing & fallback\n'
check 'main /'                          "$BASE_URL/"                                200
check 'main /?wt= leeg gedraagt als main' "$BASE_URL/?wt="                          200
check 'sibling ?wt= geldig'             "$BASE_URL/?wt=$SIBLING_SUFFIX"             200
check 'fallback ?wt=onbestaand → 200'   "$BASE_URL/?wt=onbestaand"                  200
check 'fallback ?wt=invalid!chars → 200' "$BASE_URL/?wt=invalid%21chars"            200
check 'fallback ?wt=overflow → 200'     "$BASE_URL/?wt=$(printf 'a%.0s' {1..150})"  200

printf '\n_wt endpoints\n'
check 'list.php → 200 + json'           "$BASE_URL/_wt/list.php"                    200 'Content-Type:[[:space:]]*application/json'
check 'list.php → nosniff'              "$BASE_URL/_wt/list.php"                    200 'X-Content-Type-Options:[[:space:]]*nosniff'
check 'list.php → no-store'             "$BASE_URL/_wt/list.php"                    200 'Cache-Control:[[:space:]]*no-store'
check 'switcher.js → 200 + no-cache'    "$BASE_URL/_wt/switcher.js"                 200 'Cache-Control:[[:space:]]*no-cache'
check '_wt/willekeurig → 404'           "$BASE_URL/_wt/willekeurig"                 404
check '_wt/list.php.bak → 404'          "$BASE_URL/_wt/list.php.bak"                404

printf '\nDeny rules\n'
check '/private/foo → 404'              "$BASE_URL/private/foo"                     404
check 'PHP in worktree-content → 404'   "$BASE_URL/contact-submit.php.test"         404
check '/private/index.html → 404'       "$BASE_URL/private/index.html"              404

printf '\nCache-headers per context\n'
check 'main asset → immutable'          "$BASE_URL/css/style.css"                   200 'Cache-Control:[[:space:]]*public,[[:space:]]*immutable'
check 'worktree asset → no-store'       "$BASE_URL/css/style.css?wt=$SIBLING_SUFFIX" 200 'Cache-Control:[[:space:]]*no-store'

printf '\nList.php inhoud\n'
check_body 'list.php bevat sibling-suffix' "$BASE_URL/_wt/list.php" 200 "\"$SIBLING_SUFFIX\""

printf '\nSamenvatting: '
if [[ "$FAIL" -eq 0 ]]; then
    printf '%s (%d/%d)\n' "$(green 'alle checks groen')" "$PASS" "$((PASS + FAIL))"
    exit 0
fi

printf '%s — %d falen, %d groen\n' "$(red 'falen')" "$FAIL" "$PASS"
exit 1
