#!/bin/bash
set -e
#set -x

HOST_MACHINE_IP=$(getent hosts host.docker.internal | awk '{print $1}' || echo '172.17.0.1')
HOST_MACHINE_IP=${HOST_MACHINE_IP:-'172.17.0.1'}
cd $(readlink /home/linuxbrew/.linuxbrew/etc/php/current)
sed 's/xdebug.client_host=.*/xdebug.client_host='$HOST_MACHINE_IP'/g' php.ini.dist > php.ini
sed -i 's/apc.enabled=.*/apc.enabled=0/g' /home/linuxbrew/.linuxbrew/etc/php/current/conf.d/ext-apcu.ini
sed -i 's/apc.enable_cli=.*/apc.enable_cli=0/g' /home/linuxbrew/.linuxbrew/etc/php/current/conf.d/ext-apcu.ini

cd /var/www

chown linuxbrew:linuxbrew /var/www 2> /dev/null || true
chown linuxbrew:linuxbrew /home/linuxbrew/.composer 2> /dev/null || true
chown linuxbrew:linuxbrew /home/linuxbrew/.npm 2> /dev/null || true

#if [[ -f /var/www/config/parameters.yml ]]; then
#  sed -i 's/database_driver:.*/database_driver: '${ORO_DB_DRIVER}'/g' /var/www/config/parameters.yml
#fi

for i in "$@"; do
    i="${i//\\/\\\\}"
    i="${i//$/\\$}"
    C="$C \"${i//\"/\\\"}\""
done

HOME=/home/linuxbrew su -p linuxbrew -- -c "exec $C"
