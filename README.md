# OroCommerce|OroCRM|OroPlatform Docker Environment

## Installation
### Homebrew (MacOs/Linux/Windows)
Install Homebrew by following guide https://docs.brew.sh/Installation

### Formula
Just install by the command
```bash
brew install digitalspacestdio/docker-compose-oroplatform/docker-compose-oroplatform
```

## Usage
You will need to configure auth token for docker compose, would be better to store it in your rc file (`.bashrc` or `.zshrc`)
```bash
export COMPOSE_PROJECT_COMPOSER_AUTH='{
    "http-basic": {
        "repo.example.com": {
            "username": "xxxxxxxxxxxx",
            "password": "yyyyyyyyyyyy"
        }
    },
    "github-oauth": {
        "github.com": "xxxxxxxxxxxx"
    },
    "gitlab-token": {
        "example.org": "xxxxxxxxxxxx"
    }
}'

```
If you want use specific php version just export environment variable:
```bash
export COMPOSE_PROJECT_PHP_VERSION=8.1
```
> following versions are supported: 7.2, 7.3, 7.4, 8.0, 8.1, 8.2

Clone the source code and change to the directory
```bash
git clone --single-branch --branch 5.0.5 git@github.com:oroinc/orocommerce-application.git ~/orocommerce-application
cd ~/orocommerce-application
```

Install dependencies
```bash
docker-compose-oroplatform composer install -o --no-interaction
```

Install the application
```bash
docker-compose-oroplatform bin/console --env=prod --timeout=1800 oro:install --language=en --formatting-code=en_US --organization-name='Acme Inc.'  --user-name=admin --user-email=admin@example.com --user-firstname=John --user-lastname=Doe --user-password='$ecretPassw0rd' --application-url='http://localhost:30180/' --sample-data=y
```

Start the stack in the background mode
```bash
docker-compose-oroplatform up -d
```

Start the stack in the foreground mode
```bash
docker-compose-oroplatform up
```

> Application should be available by following link: http://localhost:30180/

Stop the stack
```bash
docker-compose-oroplatform down
```

Destroy the whole data
```bash
docker-compose-oroplatform down -v
```

## Supported Environment Variables
* `COMPOSE_PROJECT_MODE` - (`mutagen`|`default`)
* `COMPOSE_PROJECT_PHP_VERSION` - (`7.1`|`7.2`|`7.3`|`7.4`|`8.0`|`8.1`|`8.2`)
* `COMPOSE_PROJECT_NODE_VERSION` - (`12.22.12`|`14.19.3`|`16.16.0`) see https://nodejs.org/dist/ for available versions
* `COMPOSE_PROJECT_MYSQL_IMAGE` - `mysql:8.0-oracle` by default
* `COMPOSE_PROJECT_POSTGRES_VERSION` - `9.6.24` by default
* `COMPOSE_PROJECT_ELASTICSEARCH_VERSION` - `7.10.2` by default
* `COMPOSE_PROJECT_NAME` - by default the project directory will be used
* `COMPOSE_PROJECT_PORT_PREFIX` - `302` by default
