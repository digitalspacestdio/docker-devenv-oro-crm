#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

if [ "$1" = 'php-fpm' ] || [ "$1" = 'php' ] || [ "$1" = 'bin/console' ] || [ "$1" = 'symfony' ]; then
	# Install the project the first time PHP is started
	if [ -f composer.json ] && [ "$APP_ENV" != 'prod' ]; then
		composer install --prefer-dist --no-progress --no-interaction
	fi

	# if grep -q ^DATABASE_URL= .env; then
	# 	# After the installation, the following block can be deleted
	# 	if [ "$CREATION" = "1" ]; then
	# 		echo "To finish the installation please press Ctrl+C to stop Docker Compose and run: docker compose up --build"
	# 		sleep infinity
	# 	fi

	# 	echo "Waiting for db to be ready..."
	# 	ATTEMPTS_LEFT_TO_REACH_DATABASE=60
	# 	until [ $ATTEMPTS_LEFT_TO_REACH_DATABASE -eq 0 ] || DATABASE_ERROR=$(bin/console dbal:run-sql "SELECT 1" 2>&1); do
	# 		if [ $? -eq 255 ]; then
	# 			# If the Doctrine command exits with 255, an unrecoverable error occurred
	# 			ATTEMPTS_LEFT_TO_REACH_DATABASE=0
	# 			break
	# 		fi
	# 		sleep 1
	# 		ATTEMPTS_LEFT_TO_REACH_DATABASE=$((ATTEMPTS_LEFT_TO_REACH_DATABASE - 1))
	# 		echo "Still waiting for db to be ready... Or maybe the db is not reachable. $ATTEMPTS_LEFT_TO_REACH_DATABASE attempts left"
	# 	done

	# 	if [ $ATTEMPTS_LEFT_TO_REACH_DATABASE -eq 0 ]; then
	# 		echo "The database is not up or not reachable:"
	# 		echo "$DATABASE_ERROR"
	# 		exit 1
	# 	else
	# 		echo "The db is now ready and reachable"
	# 	fi

	# 	if [ "$( find ./migrations -iname '*.php' -print -quit )" ]; then
	# 		bin/console doctrine:migrations:migrate --no-interaction
	# 	fi
	# fi

	setfacl -R -m u:developer:rwX -m u:"$(whoami)":rwX var
	setfacl -dR -m u:developer:rwX -m u:"$(whoami)":rwX var
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
