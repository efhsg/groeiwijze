#!/bin/sh
# Generate PHP config from environment variables

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
    'smtp_secure'      => '${SMTP_SECURE:-tls}',
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
