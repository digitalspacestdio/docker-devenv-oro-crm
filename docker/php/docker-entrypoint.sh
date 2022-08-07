#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

if [ "$1" = 'php-fpm' ] || [ "$1" = 'php' ] || [ "$1" = 'bin/console' ] || [ "$1" = 'symfony' ]; then
	setfacl -R -m u:developer:rwX -m u:"$(whoami)":rwX /var/www
	setfacl -dR -m u:developer:rwX -m u:"$(whoami)":rwX /var/www
fi

chown developer:developer /var/www 2> /dev/null || true
chown developer:developer /home/developer/.composer 2> /dev/null || true
chown developer:developer /home/developer/.npm 2> /dev/null || true
chown developer:developer /proc/self/fd/1
chown developer:developer /proc/self/fd/2

for i in "$@"; do
    i="${i//\\/\\\\}"
    i="${i//$/\\$}"
    C="$C \"${i//\"/\\\"}\""
done

HOME=/home/developer su -p developer -- -c "exec docker-php-entrypoint $C"
