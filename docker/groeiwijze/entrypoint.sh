#!/bin/sh
set -e

# Run config generation scripts
for script in /docker-entrypoint.d/*.sh; do
    if [ -x "$script" ]; then
        echo "Running $script..."
        "$script"
    fi
done

# Execute the main command
exec "$@"
