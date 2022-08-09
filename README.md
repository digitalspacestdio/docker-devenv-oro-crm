# OroCommerce|OroCRM|OroPlatform Docker Environment

## Installation
### Homebrew (MacOs/Linux/Windows)
Install Homebrew by following guide https://docs.brew.sh/Installation

### Formula
Install via homebrew by following command
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

Clone the source code and change to the directory
```bash
git clone --single-branch --branch 5.0.5 https://github.com/oroinc/orocommerce-application.git ~/orocommerce-application
```

Navigate to the directory
```bash
cd ~/orocommerce-application
```
Install dependencies
```bash
docker-compose-oroplatform composer install -o --no-interaction
```

Install the application
```bash
docker-compose-oroplatform bin/console --env=prod --timeout=1800 oro:install --language=en --formatting-code=en_US --organization-name='Acme Inc.' --user-name=admin --user-email=admin@example.com --user-firstname=John --user-lastname=Doe --user-password='$ecretPassw0rd' --application-url='http://localhost:30180/' --sample-data=y
```

Warmup cache
```bash
docker-compose-oroplatform bin/console oro:entity-extend:cache:warmup
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

## Environment Variables
> Can be stored in the `.dockenv` or `.env` file in the project root
* `COMPOSE_PROJECT_MODE` - (`mutagen`|`default`)
* `COMPOSE_PROJECT_PHP_VERSION` - (`7.1`|`7.2`|`7.3`|`7.4`|`8.0`|`8.1`|`8.2`), the image will be built from a corresponding `fpm-alpine` image, see https://hub.docker.com/_/php/?tab=tags&page=1&name=fpm-alpine&ordering=name for more versions
* `COMPOSE_PROJECT_NODE_VERSION` - (`12.22.12`|`14.19.3`|`16.16.0`) see https://nodejs.org/dist/ for more versions
* `COMPOSE_PROJECT_MYSQL_IMAGE` - `mysql:8.0-oracle` see https://hub.docker.com/_/mysql/?tab=tags for more versions
* `COMPOSE_PROJECT_POSTGRES_VERSION` - `9.6.24` see https://hub.docker.com/_/postgres/?tab=tags for more versions
* `COMPOSE_PROJECT_ELASTICSEARCH_VERSION` - `7.10.2` see https://www.docker.elastic.co/r/elasticsearch/elasticsearch-oss for more versions
* `COMPOSE_PROJECT_NAME` - by default the working directory name will be used
* `COMPOSE_PROJECT_PORT_PREFIX` - `302` by default
