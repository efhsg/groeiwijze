#!/usr/bin/env bash
#
# Publish groeiwijze.nl naar shared hosting (mijn.host / DirectAdmin) via
# het AI-runner publish-contract uit PromptManager.
#
# Architectuur:
#   - .env is single source of truth voor host/port/user/key/remote-paden.
#   - .publish/metadata/<target>.json wordt elke run regenereerd uit .env zodat
#     het runner-contract z'n preflight-check kan doen — geen dubbele admin.
#   - Transfer gebeurt via lftp over puur SFTP (mijn.host is SFTP-only,
#     rsync-over-ssh werkt daar niet — `exec request failed on channel 0`).
#   - Alleen key-auth. Password-fallback bewust niet ondersteund.
#
# Vereist:
#   - Draait IN pma_yii (web) of pma_queue (worker). Niet in pma_quick — het
#     runner-contract weigert die rol met `missing_publish_key`.
#   - .env compleet ingevuld met PUBLISH_* en SMTP_*/MAIL_* vars.
#   - SSH-key bestaat op pad PUBLISH_KEY (relatief aan project-root of absoluut).
#   - Public key is door DirectAdmin geautoriseerd op mijn.host.
#
# Gebruik:
#   ./scripts/publish.sh                          # default: --dry-run --target=production
#   ./scripts/publish.sh --live                   # echte publish naar production
#   ./scripts/publish.sh --target=staging --live  # ander target (vereist eigen key)
#
# Exit codes:
#   0   succes
#   64  argumentfout / ontbrekende env-vars
#   65  preflight blokkeerde of key/metadata-probleem
#   66  lftp-fout tijdens transfer

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ID="groeiwijze.nl"
TARGET_ID="production"
MODE="dry-run"

# ──────────────────────────────────────────────────────────────────
# 1. Argumenten
# ──────────────────────────────────────────────────────────────────

for arg in "$@"; do
    case "$arg" in
        --target=*) TARGET_ID="${arg#*=}" ;;
        --dry-run)  MODE="dry-run" ;;
        --live)     MODE="live" ;;
        *) echo "Unknown arg: $arg" >&2; exit 64 ;;
    esac
done

# ──────────────────────────────────────────────────────────────────
# 2. Environment laden + valideren
# ──────────────────────────────────────────────────────────────────

ENV_FILE="${PROJECT_DIR}/.env"
[[ -f "$ENV_FILE" ]] || { echo "missing .env at $ENV_FILE" >&2; exit 64; }

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

# Runner-context (zelf gezet door de container)
: "${AI_RUNNER_ROLE:?AI_RUNNER_ROLE not set — run inside an AI-runner container}"

# Publish-config (uit .env)
: "${PUBLISH_HOST:?missing in .env}"
: "${PUBLISH_PORT:?missing in .env}"
: "${PUBLISH_USER:?missing in .env}"
: "${PUBLISH_KEY:?missing in .env (absoluut of relatief aan project-root)}"
: "${PUBLISH_REMOTE_BASE:?missing in .env (b.v. domains/groeiwijze.nl)}"
: "${PUBLISH_REMOTE_DOCROOT:?missing in .env (b.v. public_html)}"

# SMTP/MAIL (voor contact-mail.config.php)
: "${SMTP_USER:?missing in .env}"
: "${SMTP_PASS:?missing in .env}"
: "${MAIL_FROM:?missing in .env}"
: "${MAIL_TO:?missing in .env}"

OWNER_ID="${PUBLISH_OWNER_ID:-1}"

# ──────────────────────────────────────────────────────────────────
# 3. Paden afleiden
# ──────────────────────────────────────────────────────────────────

# PUBLISH_KEY mag relatief zijn — resolve t.o.v. project-root
case "$PUBLISH_KEY" in
    /*) KEY_PATH="$PUBLISH_KEY" ;;
    *)  KEY_PATH="${PROJECT_DIR}/${PUBLISH_KEY}" ;;
esac

[[ -f "$KEY_PATH" ]] || { echo "private key not found: $KEY_PATH" >&2; exit 65; }
KEY_MODE=$(stat -c '%a' "$KEY_PATH" 2>/dev/null || stat -f '%Lp' "$KEY_PATH")
[[ "$KEY_MODE" == "600" ]] || echo "WARN: ${KEY_PATH} mode=${KEY_MODE} (expected 600)" >&2

PUBLISH_DIR="${PROJECT_DIR}/.publish"
KH_PATH="${PUBLISH_DIR}/known_hosts"
META_DIR="${PUBLISH_DIR}/metadata"
META_PATH="${META_DIR}/${TARGET_ID}.json"

install -d -m 0700 "$META_DIR"

# REMOTE_ROOT moet absoluut zijn (runner-contract preflight eist leading '/').
# mijn.host is NIET chrooted: SFTP landt in /home/${PUBLISH_USER}/ en
# PUBLISH_REMOTE_BASE is daar relatief aan. Vandaar de home-prefix.
# Voor andere hosters met afwijkende home-conventie: pas deze regel aan
# (bv. /srv/${PUBLISH_USER}/ of een PUBLISH_REMOTE_HOME env-var introduceren).
REMOTE_HOME="/home/${PUBLISH_USER}"
REMOTE_ROOT="${REMOTE_HOME}/${PUBLISH_REMOTE_BASE}/${PUBLISH_REMOTE_DOCROOT}"
REMOTE_PARENT="$(dirname "$REMOTE_ROOT")"

# ──────────────────────────────────────────────────────────────────
# 4. known_hosts populeren als nog leeg (TOFU bij eerste run)
# ──────────────────────────────────────────────────────────────────

if [[ ! -s "$KH_PATH" ]]; then
    echo "WARN: $KH_PATH leeg — eenmalig populeren via ssh-keyscan (TOFU)" >&2
    ssh-keyscan -p "$PUBLISH_PORT" -H "$PUBLISH_HOST" 2>/dev/null > "$KH_PATH"
    chmod 0600 "$KH_PATH"
    [[ -s "$KH_PATH" ]] || { echo "ssh-keyscan leverde geen entry op" >&2; exit 65; }
    echo "→ ${PUBLISH_HOST}:${PUBLISH_PORT} pinned in $KH_PATH" >&2
fi

# ──────────────────────────────────────────────────────────────────
# 5. metadata/<target>.json regenereren uit .env
# ──────────────────────────────────────────────────────────────────

FINGERPRINT=$(ssh-keygen -lf "${KEY_PATH}.pub" 2>/dev/null | awk '{print $2}' || echo "unknown")

cat > "$META_PATH" <<EOF
{
  "project_id": "${PROJECT_ID}",
  "target_id": "${TARGET_ID}",
  "key_id": "publish-${PROJECT_ID}-${TARGET_ID}",
  "fingerprint": "${FINGERPRINT}",
  "host": "${PUBLISH_HOST}",
  "port": ${PUBLISH_PORT},
  "remote_root": "${REMOTE_ROOT}"
}
EOF
chmod 0600 "$META_PATH"

# ──────────────────────────────────────────────────────────────────
# 6. Preflight via runner-contract
# ──────────────────────────────────────────────────────────────────

CTX=$(mktemp -t publish-ctx.XXXXXX.json)
trap 'rm -f "$CTX"' EXIT

cat > "$CTX" <<EOF
{
  "owner_id": ${OWNER_ID},
  "project_id": "${PROJECT_ID}",
  "target_id": "${TARGET_ID}",
  "runner_role": "${AI_RUNNER_ROLE}",
  "mode": "${MODE}",
  "remote_root": "${REMOTE_ROOT}",
  "host": "${PUBLISH_HOST}",
  "port": ${PUBLISH_PORT}
}
EOF

YII="/var/www/worktree/main/yii/yii"
PREFLIGHT_OUT=$("$YII" publish-runner/preflight --context="$CTX") || {
    echo "$PREFLIGHT_OUT" >&2
    PAYLOAD=$(printf '%s\n' "$PREFLIGHT_OUT" | grep -E '^\{' | tail -n1)
    CAT=$(printf '%s' "$PAYLOAD" | jq -r '.category // "unknown"')
    DET=$(printf '%s' "$PAYLOAD" | jq -r '.detail   // "unknown"')
    echo "preflight blocked: ${CAT} (${DET})" >&2
    exit 65
}
echo "preflight ok (mode=${MODE}, role=${AI_RUNNER_ROLE}, target=${TARGET_ID})"

# ──────────────────────────────────────────────────────────────────
# 7. Lokale build van PHPMailer vendor/
# ──────────────────────────────────────────────────────────────────

BUILD_ROOT="${PROJECT_DIR}/.build/${TARGET_ID}"
VENDOR_BUILD="${BUILD_ROOT}/vendor"
PRIVATE_BUILD="${BUILD_ROOT}/private"
COMPOSER_DIR="${PROJECT_DIR}/docker/groeiwijze"

mkdir -p "$BUILD_ROOT"
echo "→ composer install (PHPMailer)"
(cd "$COMPOSER_DIR" && composer install --no-dev --no-interaction --no-progress --quiet)
rm -rf "$VENDOR_BUILD"
cp -R "${COMPOSER_DIR}/vendor" "$VENDOR_BUILD"

# ──────────────────────────────────────────────────────────────────
# 8. Genereer private/contact-mail.config.php uit env (mode 0600 lokaal)
# ──────────────────────────────────────────────────────────────────

mkdir -p "$PRIVATE_BUILD"
cat > "${PRIVATE_BUILD}/contact-mail.config.php" <<EOF
<?php
return [
    'smtp_host'       => '${SMTP_HOST:-mail.groeiwijze.nl}',
    'smtp_port'       => ${SMTP_PORT:-587},
    'smtp_user'       => '${SMTP_USER}',
    'smtp_pass'       => '${SMTP_PASS}',
    'smtp_secure'     => 'tls',
    'mail_from'       => '${MAIL_FROM}',
    'mail_from_name'  => '${MAIL_FROM_NAME:-Groeiwijze}',
    'mail_to'         => '${MAIL_TO}',
    'rate_limit_salt' => '${RATE_LIMIT_SALT:-groeiwijze_ratelimit_2024}',
];
EOF
chmod 0600 "${PRIVATE_BUILD}/contact-mail.config.php"

# ──────────────────────────────────────────────────────────────────
# 9. Upload via lftp (drie mirror-calls met dezelfde SSH-config)
#
# DirectAdmin per-domein layout (mijn.host, GEEN chroot — SSH landt in
# /home/${PUBLISH_USER}/, paden onder PUBLISH_REMOTE_BASE zijn relatief
# aan die home en moeten naar absoluut worden geprefixt):
#   /home/${PUBLISH_USER}/domains/groeiwijze.nl/
#   ├── public_html/   ← website-mirror (= REMOTE_ROOT)
#   ├── vendor/        ← PHPMailer (sibling)
#   ├── private/       ← contact-mail.config.php (sibling)
#   ├── private_html/, public_ftp/, logs/, stats/  ← DirectAdmin-managed, niet aanraken
# ──────────────────────────────────────────────────────────────────

SSH_CMD="ssh -i ${KEY_PATH} -o UserKnownHostsFile=${KH_PATH} -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes -p ${PUBLISH_PORT}"

# lftp mirror flags. --reverse = lokaal naar remote (push). --delete = mirror semantiek.
LFTP_MIRROR_OPTS="--reverse --delete --verbose"
[[ "$MODE" == "dry-run" ]] && LFTP_MIRROR_OPTS="${LFTP_MIRROR_OPTS} --dry-run"

run_lftp_mirror() {
    local local_dir="$1"
    local remote_dir="$2"
    local extra_opts="${3:-}"

    lftp -c "
        set sftp:connect-program '${SSH_CMD}';
        set sftp:auto-confirm yes;
        open -u ${PUBLISH_USER}, sftp://${PUBLISH_HOST};
        mirror ${LFTP_MIRROR_OPTS} ${extra_opts} ${local_dir} ${remote_dir};
        bye
    " || { echo "lftp mirror failed: ${local_dir} → ${remote_dir}" >&2; exit 66; }
}

echo "→ mirror website/ → ${REMOTE_ROOT}/"
run_lftp_mirror "${PROJECT_DIR}/website" "${REMOTE_ROOT}"

echo "→ mirror vendor/ → ${REMOTE_PARENT}/vendor/"
run_lftp_mirror "${VENDOR_BUILD}" "${REMOTE_PARENT}/vendor"

# Voor private/ probeert lftp lokale 0600 te behouden — werkt op de meeste
# SFTP-servers, ook mijn.host's DirectAdmin-setup.
echo "→ mirror private/ → ${REMOTE_PARENT}/private/ (mode 0600 source)"
run_lftp_mirror "${PRIVATE_BUILD}" "${REMOTE_PARENT}/private"

if [[ "$MODE" == "dry-run" ]]; then
    echo "✓ dry-run complete (no remote writes performed)"
else
    echo "✓ live publish complete"
fi
