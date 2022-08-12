ARG PHP_VERSION=8.1

# Prod image
FROM php:${PHP_VERSION}-fpm-alpine AS app_php

# Allow to use development versions of Symfony
ARG STABILITY="stable"
ENV STABILITY ${STABILITY}

ARG NODE_VERSION=16.16.0
ENV APP_ENV=prod

ARG PHP_UID=1000
ARG PHP_GID=1000
ARG PHP_USER_NAME=developer
ARG PHP_USER_GROUP=developer

ARG EXT_APCU_VERSION=5.1.21
ARG EXT_REDIS_VERSION=5.3.7 
ARG EXT_IGBINARY_VERSION=3.2.7
ARG EXT_MONGODB_VERSION=1.14.0
ARG EXT_XDEBUG_VERSION=3.1.5

# persistent / runtime deps
RUN apk add --no-cache \
    acl \
    fcgi \
    file \
    gettext \
    git \
    bash \
    curl \
    msmtp-openrc \
    jpegoptim \
    pngquant \
    optipng \
    gifsicle \
  ;

RUN set -eux; \
  apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    icu-data-full \
    icu-dev \
    libzip-dev \
    zlib-dev \
    libxml2-dev \
    libxslt-dev \
    postgresql-dev \
    openldap-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    gmp-dev \
    tidyhtml-dev \
    imap-dev \
    oniguruma-dev \
  ; \
  \
  docker-php-source extract; \
  docker-php-ext-configure zip; \
  docker-php-ext-configure imap --with-imap --with-imap-ssl; \
  docker-php-ext-configure gd --with-freetype --with-webp --with-jpeg; \
  \
  mkdir -p /usr/src/php/ext/apcu; \
  curl -fsSL https://github.com/krakjoe/apcu/archive/v$EXT_APCU_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/apcu --strip 1; \
  docker-php-ext-install -j$(printf "2\n$(nproc)" | sort -g | head -n1) apcu; \
  \
  mkdir -p /usr/src/php/ext/igbinary; \
  curl -fsSL curl -fsSL https://github.com/igbinary/igbinary/archive/$EXT_IGBINARY_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/igbinary --strip 1; \
  docker-php-ext-install -j$(printf "2\n$(nproc)" | sort -g | head -n1) igbinary; \
  \
  mkdir -p /usr/src/php/ext/redis; \
  curl -fsSL curl -fsSL https://github.com/phpredis/phpredis/archive/$EXT_REDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1; \
  docker-php-ext-configure redis --enable-redis-igbinary; \
  docker-php-ext-install -j$(printf "2\n$(nproc)" | sort -g | head -n1) redis; \
  \
  mkdir -p /usr/src/php/ext/mongodb; \
  git clone --recursive --branch $EXT_MONGODB_VERSION --depth 1 https://github.com/mongodb/mongo-php-driver.git /usr/src/php/ext/mongodb; \
  docker-php-ext-configure mongodb; \
  docker-php-ext-install -j$(printf "2\n$(nproc)" | sort -g | head -n1) mongodb; \
  \
  mkdir -p /usr/src/php/ext/xdebug; \
  curl -fsSL curl -fsSL https://github.com/xdebug/xdebug/archive/refs/tags/$EXT_XDEBUG_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/xdebug --strip 1; \
  docker-php-ext-configure xdebug; \
  docker-php-ext-install -j$(printf "2\n$(nproc)" | sort -g | head -n1) xdebug; \
  \
  docker-php-ext-install -j$(printf "2\n$(nproc)" | sort -g | head -n1) \
    pdo_pgsql \
    pdo_mysql \
    intl \
    zip \
    soap \
    ldap \
    gd \
    gmp \
    xsl \
    tidy \
    pcntl \
    imap \
    sockets \
    bcmath \
    mbstring \
    opcache \
  ; \
  docker-php-source delete; \
  \
  runDeps="$( \
    scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
      | tr ',' '\n' \
      | sort -u \
      | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
  )"; \
  apk add --no-cache --virtual .app-phpexts-rundeps $runDeps; \
  \
  apk del .build-deps

RUN addgroup -g $PHP_GID ${PHP_USER_GROUP} \
    && adduser -u $PHP_UID -G ${PHP_USER_GROUP} -s /bin/sh -D ${PHP_USER_NAME};

RUN apk add --no-cache \
        libstdc++ \
    && NODEJS_DOWNLOAD_BASEURL="https://unofficial-builds.nodejs.org/download/release/" \
    && NODEJS_DOWNLOAD_FILENAME_SUFFIX="-musl" \
    && ARCH= && alpineArch="$(apk --print-arch)" \
      && case "${alpineArch##*-}" in \
        aarch64) \
          ARCH='arm64' \
          CHECKSUM="$(curl -sL ${NODEJS_DOWNLOAD_BASEURL}/v${NODE_VERSION}/SHASUMS256.txt | grep 'node-v${NODE_VERSION}-linux-${ARCH}${NODEJS_DOWNLOAD_FILENAME_SUFFIX}.tar.xz' | awk '{print \$1}')" \
          ;; \
        x86_64) \
          ARCH='x64' \
          CHECKSUM="$(curl -sL ${NODEJS_DOWNLOAD_BASEURL}/v${NODE_VERSION}/SHASUMS256.txt | grep 'node-v${NODE_VERSION}-linux-${ARCH}${NODEJS_DOWNLOAD_FILENAME_SUFFIX}.tar.xz' | awk '{print \$1}')" \
          ;; \
        *) ;; \
      esac \
  && if [ -n "${CHECKSUM}" ]; then \
    set -eu; \
    curl -fsSLO --compressed "${NODEJS_DOWNLOAD_BASEURL}/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH}${NODEJS_DOWNLOAD_FILENAME_SUFFIX}.tar.xz"; \
    echo "$CHECKSUM node-v${NODE_VERSION}-linux-${ARCH}${NODEJS_DOWNLOAD_FILENAME_SUFFIX}.tar.xz" | sha256sum -c - \
      && tar -xJf "node-v${NODE_VERSION}-linux-${ARCH}${NODEJS_DOWNLOAD_FILENAME_SUFFIX}.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
      && ln -s /usr/local/bin/node /usr/local/bin/nodejs; \
      && rm -f "node-v${NODE_VERSION}-linux-${ARCH}${NODEJS_DOWNLOAD_FILENAME_SUFFIX}.tar.xz" \
  else \
    echo "Building from source" \
    # backup build
    && apk add --no-cache --virtual .build-deps-full \
        binutils-gold \
        g++ \
        gcc \
        gnupg \
        libgcc \
        linux-headers \
        make \
        python3 \
    # gpg keys listed at https://github.com/nodejs/node#release-keys
    && for key in \
      4ED778F539E3634C779C87C6D7062848A1AB005C \
      141F07595B7B3FFE74309A937405533BE57C7D57 \
      94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
      74F12602B6F1C4E913FAA37AD3A89613643B6201 \
      71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
      61FC681DFB92A079F1685E77973F295594EC4689 \
      8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
      C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
      890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
      C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
      DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
      A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
      108F52B48DB57BB0CC439B2997B01419BD92F80A \
      B9E2F5981AA6E0CD28160D9FF13993A75599653C \
    ; do \
      gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
      gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
    done \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xf "node-v$NODE_VERSION.tar.xz" \
    && cd "node-v$NODE_VERSION" \
    && ./configure \
    && make -j$(getconf _printf "2\n$(nproc)" | sort -g | head -n1ESSORS_ONLN) V= \
    && make install \
    && apk del .build-deps-full \
    && cd .. \
    && rm -Rf "node-v$NODE_VERSION" \
    && rm "node-v$NODE_VERSION.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt; \
  fi \
  # smoke tests
  && node --version \
  && npm --version

WORKDIR /var/www

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN rm -rf /var/www/* && chown ${PHP_USER_NAME}:${PHP_USER_GROUP} /var/www

COPY conf.d/app.ini $PHP_INI_DIR/conf.d/
COPY conf.d/app.prod.ini $PHP_INI_DIR/conf.d/

COPY php-fpm.conf /usr/local/etc/php-fpm.conf
RUN mkdir -p /var/run/php

COPY docker-healthcheck.sh /usr/local/bin/docker-healthcheck
RUN chmod +x /usr/local/bin/docker-healthcheck

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
CMD ["bash"]

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="${PATH}:/root/.composer/vendor/bin"

# Install composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install ofelia
COPY --from=mcuadros/ofelia:latest /usr/bin/ofelia /usr/bin/ofelia

RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.alpine.sh' | bash \
    && apk add symfony-cli

# Dev image
FROM app_php AS app_php_dev

RUN rm $PHP_INI_DIR/conf.d/app.prod.ini; \
  mv "$PHP_INI_DIR/php.ini" "$PHP_INI_DIR/php.ini-production"; \
  mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

COPY conf.d/app.dev.ini $PHP_INI_DIR/conf.d/

USER ${PHP_USER_NAME}
VOLUME "/home/php" "/root" '/var/www'
CMD [ "bash" ]