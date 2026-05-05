#!/bin/sh
# Generate PHP config from environment variables

# Dev-mode guard. Deze container draait alleen in dev. Weiger te starten
# als APP_ENV niet 'dev' is (override-bestand .env.dev ontbreekt of is leeg)
# of als SMTP_HOST naar een externe host wijst. Voorkomt dat het dev-
# contactformulier via een echte SMTP-server mailt.
if [ "${APP_ENV:-}" != "dev" ]; then
    echo "DEV-GUARD: APP_ENV='${APP_ENV:-unset}' is niet 'dev'." >&2
    echo "Deze container draait alleen in dev. Zorg dat .env.dev geladen wordt." >&2
    exit 1
fi

case "${SMTP_HOST:-}" in
    mailcatcher|localhost|127.0.0.1|*.local) ;;
    *)
        echo "DEV-GUARD: SMTP_HOST='${SMTP_HOST:-unset}' is geen mailcatcher-doel." >&2
        echo "Toegestaan in dev: mailcatcher, localhost, 127.0.0.1, *.local." >&2
        exit 1 ;;
esac

CONFIG_DIR="/var/www/private"
CONFIG_FILE="$CONFIG_DIR/contact-mail.config.php"

mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_FILE" << EOF
<?php
/**
 * Groeiwijze Contact Form - Mail Configuration
 * Auto-generated from environment variables
 */

return [
    // SMTP Settings
    'smtp_host'        => '${SMTP_HOST:-mail.groeiwijze.nl}',
    'smtp_port'        => ${SMTP_PORT:-587},
    'smtp_user'        => '${SMTP_USER}',
    'smtp_pass'        => '${SMTP_PASS}',
    'smtp_secure'      => '${SMTP_SECURE-}',
    'smtp_skip_verify' => ${SMTP_SKIP_VERIFY:-false},

    // Mail Settings
    'mail_from'        => '${MAIL_FROM}',
    'mail_from_name'   => '${MAIL_FROM_NAME:-Groeiwijze}',
    'mail_to'          => '${MAIL_TO}',

    // Security
    'rate_limit_salt'  => '${RATE_LIMIT_SALT:-groeiwijze_ratelimit_2024}',
];
EOF

chown www-data:www-data "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"

echo "Config generated at $CONFIG_FILE"
