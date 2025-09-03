# syntax=docker/dockerfile:1
# See https://hub.docker.com/r/docker/dockerfile

#######################################################
# Configuration
#######################################################

# See: https://nginx.org/
#
# renovate: datasource=docker depName=nginx versioning=semver
ARG NGINX_VERSION="1.29.0"

# See: https://github.com/ddollar/forego
#
# renovate: datasource=docker depName=nginxproxy/forego
ARG FOREGO_VERSION="0.18.3"

# See: https://github.com/hairyhenderson/gomplate
#
# renovate: datasource=github-releases depName=hairyhenderson/gomplate
ARG GOMPLATE_VERSION="4.3.2"

# See: https://github.com/jippi/dottie
#
# renovate: datasource=docker depName=ghcr.io/jippi/dottie
ARG DOTTIE_VERSION="v0.16.0"

# See: https://github.com/composer/composer
#
# renovate: datasource=github-releases depName=composer/composer
ARG COMPOSER_VERSION="2.8.9"

ARG RUNTIME_UID=33 # often called 'www-data'
ARG RUNTIME_GID=33 # often called 'www-data'

###
# PHP base configuration
###

# See: https://hub.docker.com/_/php/tags
#
# renovate: datasource=docker depName=php versioning=semver-coerced
ARG PHP_VERSION="8.4"

# See: https://github.com/docker-library/docs/blob/master/php/README.md#image-variants
ARG PHP_BASE_TYPE="apache"
ARG PHP_DEBIAN_RELEASE="trixie"
ARG APT_PACKAGES_EXTRA=

# PHP extensions installed via [pecl install]
ARG PHP_PECL_EXTENSIONS=""
ARG PHP_PECL_EXTENSIONS_EXTRA=

# PHP extensions installed via https://deb.sury.org/
# ! NOTE: Must not include the "php8.x-" prefix for packages
# !       so [php8.3-bcmath] should just be [bcmath] here
ARG PHP_EXTENSIONS="bcmath curl gd imagick intl mbstring redis vips xml yaml zip"
ARG PHP_EXTENSIONS_EXTRA=""
ARG PHP_EXTENSIONS_DATABASE="pgsql mysql sqlite"

# GPG key for nginx apt repository
ARG NGINX_GPGKEY="2FD21310B49F6B46"

# GPP key path for nginx apt repository
ARG NGINX_GPGKEY_PATH="/usr/share/keyrings/nginx-archive-keyring.gpg"

#######################################################
# Docker "copy from" images
#######################################################

# nginx webserver from Docker Hub.
# Used to copy some docker-entrypoint files for [nginx-runtime]
#
# NOTE: Docker will *not* pull this image unless it's referenced (via build target)
FROM nginx:${NGINX_VERSION} AS nginx-image

# Forego is a Procfile "runner" that makes it trivial to run multiple
# processes under a simple init / PID 1 process.
#
# NOTE: Docker will *not* pull this image unless it's referenced (via build target)
#
# See: https://github.com/nginx-proxy/forego
FROM nginxproxy/forego:${FOREGO_VERSION}-debian AS forego-image

# Dottie makes working with .env files easier and safer
#
# NOTE: Docker will *not* pull this image unless it's referenced (via build target)
#
# See: https://github.com/jippi/dottie
FROM ghcr.io/jippi/dottie:${DOTTIE_VERSION} AS dottie-image

# gomplate-image grabs the gomplate binary from GitHub releases
#
# It's in its own layer so it can be fetched in parallel with other build steps
FROM alpine/curl AS gomplate-image

ARG GOMPLATE_VERSION
ARG TARGETARCH
ARG TARGETOS

USER root

RUN set -ex \
    && curl \
        --silent \
        --show-error \
        --location \
        --output /usr/local/bin/gomplate \
        https://github.com/hairyhenderson/gomplate/releases/download/v${GOMPLATE_VERSION}/gomplate_${TARGETOS}-${TARGETARCH} \
    && chmod +x /usr/local/bin/gomplate \
    && /usr/local/bin/gomplate --version

#######################################################
# Base image
#######################################################

FROM debian:${PHP_DEBIAN_RELEASE} AS base

ENV DEBIAN_FRONTEND="noninteractive"

# Ensure we run all scripts through 'bash' rather than 'sh'
SHELL ["/bin/bash", "-c"]

ARG APT_PACKAGES_EXTRA
ARG PHP_DEBIAN_RELEASE
ARG RUNTIME_GID
ARG RUNTIME_UID
ARG TARGETARCH

# Copy the base layer installer into the image
COPY docker/rootfs/shared/docker/install/base.sh /docker/install/base.sh

# ! NOTE: we don't include PHP in the cache here, since its not touching PHP
RUN --mount=type=cache,id=pixelfed-apt-${PHP_DEBIAN_RELEASE}-${TARGETARCH},target=/var/lib/apt \
    --mount=type=cache,id=pixelfed-apt-cache-${PHP_DEBIAN_RELEASE}-${TARGETARCH},target=/var/cache/apt \
    APT_PACKAGES_EXTRA=${APT_PACKAGES_EXTRA} \
    RUNTIME_GID=${RUNTIME_GID} \
    RUNTIME_UID=${RUNTIME_UID} \
    /docker/install/base.sh

WORKDIR /var/www/

#######################################################
# PHP: extensions
#######################################################

ARG COMPOSER_VERSION
ARG PHP_VERSION
ARG PHP_EXTENSIONS
ARG PHP_EXTENSIONS_DATABASE
ARG PHP_EXTENSIONS_EXTRA
ARG PHP_PECL_EXTENSIONS
ARG PHP_PECL_EXTENSIONS_EXTRA
ARG PHP_BASE_TYPE

# Copy the PHP layer installer into the image
COPY docker/rootfs/shared/docker/install/php.sh /docker/install/php.sh

RUN --mount=type=cache,id=pixelfed-pear-${PHP_VERSION}-${PHP_DEBIAN_RELEASE}-${TARGETARCH},target=/tmp/pear \
    --mount=type=cache,id=pixelfed-apt-${PHP_VERSION}-${PHP_DEBIAN_RELEASE}-${TARGETARCH},target=/var/lib/apt \
    --mount=type=cache,id=pixelfed-apt-cache-${PHP_VERSION}-${PHP_DEBIAN_RELEASE}-${TARGETARCH},target=/var/cache/apt \
    COMPOSER_VERSION=${COMPOSER_VERSION} \
    PHP_EXTENSIONS_DATABASE=${PHP_EXTENSIONS_DATABASE} \
    PHP_EXTENSIONS_EXTRA=${PHP_EXTENSIONS_EXTRA} \
    PHP_EXTENSIONS=${PHP_EXTENSIONS} \
    PHP_PECL_EXTENSIONS_EXTRA=${PHP_PECL_EXTENSIONS_EXTRA} \
    PHP_PECL_EXTENSIONS=${PHP_PECL_EXTENSIONS} \
    PHP_BASE_TYPE=${PHP_BASE_TYPE} \
    /docker/install/php.sh

#######################################################
# PHP: composer
#######################################################

# Make sure composer cache is targeting our cache mount later
ENV COMPOSER_CACHE_DIR="/cache/composer"

# Don't enforce any memory limits for composer
ENV COMPOSER_MEMORY_LIMIT=-1

# Disable interactivity from composer
ENV COMPOSER_NO_INTERACTION=1

#######################################################
# Baseline image
#######################################################

ENV RUNTIME_UID=${RUNTIME_UID}
ENV RUNTIME_GID=${RUNTIME_GID}

#! Changing user to runtime user
USER ${RUNTIME_UID}:${RUNTIME_GID}

#######################################################
# Node: Build frontend
#######################################################

# NOTE: Since the nodejs build is CPU architecture agnostic,
# we only want to build once and cache it for other architectures.
# We force the (CPU) [--platform] here to be architecture
# of the "builder"/"server" and not the *target* CPU architecture
# (e.g.) building the ARM version of Pixelfed on AMD64.
FROM --platform=${BUILDARCH} node:lts AS frontend-build

ARG BUILD_FRONTEND=0
ARG BUILDARCH
ARG RUNTIME_GID
ARG RUNTIME_UID
ARG TARGETARCH

ARG NODE_ENV=production
ENV NODE_ENV=$NODE_ENV

WORKDIR /var/www/

SHELL [ "/usr/bin/bash", "-c" ]

# Install NPM dependencies
RUN --mount=type=cache,id=pixelfed-node-${TARGETARCH},sharing=locked,target=/tmp/cache \
    --mount=type=bind,source=src/package.json,target=/var/www/package.json \
    --mount=type=bind,source=src/package-lock.json,target=/var/www/package-lock.json \
<<EOF
    if [[ $BUILD_FRONTEND -eq 1 ]];
    then
        npm install --cache /tmp/cache --no-save --dev
    else
        echo "Skipping [npm install] as --build-arg [BUILD_FRONTEND] is not set to '1'"
    fi
EOF

# Copy the frontend source into the image before building
COPY --chown=${RUNTIME_UID}:${RUNTIME_GID} src/ /var/www

# Build the frontend with "mix" (See package.json)
RUN \
<<EOF
    if [[ $BUILD_FRONTEND -eq 1 ]];
    then
        npm run production
    else
        echo "Skipping [npm run production] as --build-arg [BUILD_FRONTEND] is not set to '1'"
    fi
EOF

#######################################################
# PHP: composer and source code
#######################################################

FROM base AS composer-and-src

ARG PHP_VERSION
ARG RUNTIME_GID
ARG RUNTIME_UID
ARG TARGETARCH

COPY --chown=${RUNTIME_UID}:${RUNTIME_GID} src/composer.* /var/www/

# Install composer dependencies
# NOTE: we skip the autoloader generation here since we don't have all files available (yet)
RUN --mount=type=cache,id=pixelfed-composer-${PHP_VERSION}-${TARGETARCH},uid=${RUNTIME_UID},gid=${RUNTIME_GID},sharing=locked,target=/cache/composer \
    set -ex \
    && composer install --prefer-dist --no-autoloader --ignore-platform-reqs

# Copy all other files over
COPY --chown=${RUNTIME_UID}:${RUNTIME_GID} src/ /var/www/

#######################################################
# Runtime: base
#######################################################

FROM base AS shared-runtime

ARG RUNTIME_UID
ARG RUNTIME_GID

ENV RUNTIME_UID=${RUNTIME_UID}
ENV RUNTIME_GID=${RUNTIME_GID}

USER root

#! Changing user to runtime user
USER ${RUNTIME_UID}:${RUNTIME_GID}

COPY --link --from=composer-and-src --chown=${RUNTIME_UID}:${RUNTIME_GID} /var/www /var/www
COPY --link --from=frontend-build --chown=${RUNTIME_UID}:${RUNTIME_GID} /var/www/public /var/www/public

# Generate optimized autoloader now that we have all files around
RUN set -ex \
    && ENABLE_CONFIG_CACHE=false composer dump-autoload --optimize

# for detail why storage is copied this way, pls refer to https://github.com/pixelfed/pixelfed/pull/2137#discussion_r434468862
RUN set -ex \
    && cp --recursive --link --preserve=all storage storage.skel \
    && rm -rf html && ln -s public html

COPY --link --from=forego-image /usr/local/bin/forego /usr/local/bin/forego
COPY --link --from=dottie-image /usr/local/bin/dottie /usr/local/bin/dottie
COPY --link --from=gomplate-image /usr/local/bin/gomplate /usr/local/bin/gomplate

#! Changing to root user
USER root

COPY docker/rootfs/shared /

ENTRYPOINT ["/docker/entrypoint.sh"]

#######################################################
# Runtime: apache
#######################################################

FROM shared-runtime AS apache-runtime

ARG PHP_DEBIAN_RELEASE
ARG PHP_VERSION
ARG TARGETARCH

# Install apache webserver
RUN --mount=type=cache,id=pixelfed-apt-${PHP_VERSION}-${PHP_DEBIAN_RELEASE}-${TARGETARCH},target=/var/lib/apt \
    --mount=type=cache,id=pixelfed-apt-cache-${PHP_VERSION}-${PHP_DEBIAN_RELEASE}-${TARGETARCH},target=/var/cache/apt \
    set -ex \
    && apt-get update \
    && apt-get install -y apache2

COPY docker/rootfs/apache /

RUN set -ex \
    && a2dismod mpm_event \
    && a2enmod php${PHP_VERSION} \
    && a2enmod rewrite remoteip proxy proxy_http \
    && a2enconf remoteip

CMD ["apache2-foreground"]


#######################################################
# Runtime: nginx
#######################################################

FROM shared-runtime AS nginx-runtime

ARG NGINX_GPGKEY
ARG NGINX_GPGKEY_PATH
ARG NGINX_VERSION
ARG PHP_DEBIAN_RELEASE
ARG PHP_VERSION
ARG TARGETARCH

# Install nginx dependencies
RUN --mount=type=cache,id=pixelfed-apt-${PHP_VERSION}-${PHP_DEBIAN_RELEASE}-${TARGETARCH},target=/var/lib/apt \
    --mount=type=cache,id=pixelfed-apt-cache-${PHP_VERSION}-${PHP_DEBIAN_RELEASE}-${TARGETARCH},target=/var/cache/apt \
    set -ex \
    && gpg1 --keyserver "hkp://keyserver.ubuntu.com:80" --keyserver-options timeout=10 --recv-keys "${NGINX_GPGKEY}" \
    && gpg1 --export "$NGINX_GPGKEY" > "$NGINX_GPGKEY_PATH" \
    && echo "deb [signed-by=${NGINX_GPGKEY_PATH}] https://nginx.org/packages/mainline/debian/ ${PHP_DEBIAN_RELEASE} nginx" >> /etc/apt/sources.list.d/nginx.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nginx=${NGINX_VERSION}*

# copy docker entrypoints from the *real* nginx image directly
COPY --link --from=nginx-image /docker-entrypoint.d /docker/entrypoint.d/

COPY docker/rootfs/nginx /

STOPSIGNAL SIGQUIT

CMD ["forego", "start", "-r"]
