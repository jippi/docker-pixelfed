# syntax=docker/dockerfile:1
# See https://hub.docker.com/r/docker/dockerfile

#######################################################
# Configuration
#######################################################

# See: https://nginx.org/
ARG NGINX_VERSION="1.25.3"

# See: https://github.com/ddollar/forego
ARG FOREGO_VERSION="0.17.2"

# See: https://github.com/hairyhenderson/gomplate
ARG GOMPLATE_VERSION="v3.11.8"

# See: https://github.com/jippi/dottie
ARG DOTTIE_VERSION="v0.13.1"

###
# PHP base configuration
###

# See: https://hub.docker.com/_/php/tags
ARG PHP_VERSION="8.3"

# See: https://github.com/docker-library/docs/blob/master/php/README.md#image-variants
ARG PHP_BASE_TYPE="apache"
ARG PHP_DEBIAN_RELEASE="bookworm"

# The image to use as "php" pre-build source
ARG PHP_IMAGE="ghcr.io/jippi/docker-pixelfed-php:branch-main-${PHP_VERSION}-${PHP_BASE_TYPE}-${PHP_DEBIAN_RELEASE}"

# GPG key for nginx apt repository
ARG NGINX_GPGKEY="573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62"

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

# Forego is a Procfile "runner" that makes it trival to run multiple
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
FROM ${PHP_IMAGE} AS gomplate-image

ARG TARGETARCH
ARG TARGETOS
ARG GOMPLATE_VERSION

USER root

RUN set -ex \
    && curl \
        --silent \
        --show-error \
        --location \
        --output /usr/local/bin/gomplate \
        https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_VERSION}/gomplate_${TARGETOS}-${TARGETARCH} \
    && chmod +x /usr/local/bin/gomplate \
    && /usr/local/bin/gomplate --version

#######################################################
# Base image
#######################################################

FROM ${PHP_IMAGE} AS base

#######################################################
# Node: Build frontend
#######################################################

# NOTE: Since the nodejs build is CPU architecture agnostic,
# we only want to build once and cache it for other architectures.
# We force the (CPU) [--platform] here to be architecture
# of the "builder"/"server" and not the *target* CPU architecture
# (e.g.) building the ARM version of Pixelfed on AMD64.
FROM --platform=${BUILDARCH} node:lts AS frontend-build

ARG BUILDARCH
ARG BUILD_FRONTEND=0
ARG RUNTIME_UID

ARG NODE_ENV=production
ENV NODE_ENV=$NODE_ENV

WORKDIR /var/www/

SHELL [ "/usr/bin/bash", "-c" ]

# Install NPM dependencies
RUN --mount=type=cache,id=pixelfed-node-${BUILDARCH},sharing=locked,target=/tmp/cache \
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

FROM ${PHP_IMAGE} AS composer-and-src

ARG PHP_VERSION

# Install composer dependencies
# NOTE: we skip the autoloader generation here since we don't have all files avaliable (yet)
RUN --mount=type=cache,id=pixelfed-composer-${PHP_VERSION},sharing=locked,target=/cache/composer \
    --mount=type=bind,source=src/composer.json,target=/var/www/composer.json \
    --mount=type=bind,source=src/composer.lock,target=/var/www/composer.lock \
    set -ex \
    && composer install --prefer-dist --no-autoloader --ignore-platform-reqs

# Copy all other files over
COPY --chown=${RUNTIME_UID}:${RUNTIME_GID} src/ /var/www/

#######################################################
# Runtime: base
#######################################################

FROM ${PHP_IMAGE} AS shared-runtime

ARG RUNTIME_GID
ARG RUNTIME_UID

ENV RUNTIME_UID=${RUNTIME_UID}
ENV RUNTIME_GID=${RUNTIME_GID}

USER root

COPY --link --from=forego-image /usr/local/bin/forego /usr/local/bin/forego
COPY --link --from=dottie-image /usr/local/bin/dottie /usr/local/bin/dottie
COPY --link --from=gomplate-image /usr/local/bin/gomplate /usr/local/bin/gomplate

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

#! Changing to root user
USER root

COPY images/pixelfed/rootfs/shared/root /

ENTRYPOINT ["/docker/entrypoint.sh"]

#######################################################
# Runtime: apache
#######################################################

FROM shared-runtime AS apache-runtime

COPY images/pixelfed/rootfs/apache/root /

RUN set -ex \
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
ARG TARGETPLATFORM

# Install nginx dependencies
RUN --mount=type=cache,id=pixelfed-apt-lists-${PHP_VERSION}-${PHP_DEBIAN_RELEASE}-${TARGETPLATFORM},sharing=locked,target=/var/lib/apt/lists \
    --mount=type=cache,id=pixelfed-apt-cache-${PHP_VERSION}-${PHP_DEBIAN_RELEASE}-${TARGETPLATFORM},sharing=locked,target=/var/cache/apt \
    set -ex \
    && gpg1 --keyserver "hkp://keyserver.ubuntu.com:80" --keyserver-options timeout=10 --recv-keys "${NGINX_GPGKEY}" \
    && gpg1 --export "$NGINX_GPGKEY" > "$NGINX_GPGKEY_PATH" \
    && echo "deb [signed-by=${NGINX_GPGKEY_PATH}] https://nginx.org/packages/mainline/debian/ ${PHP_DEBIAN_RELEASE} nginx" >> /etc/apt/sources.list.d/nginx.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nginx=${NGINX_VERSION}*

# copy docker entrypoints from the *real* nginx image directly
COPY --link --from=nginx-image /docker-entrypoint.d /docker/entrypoint.d/
COPY images/pixelfed/rootfs/nginx/root /

STOPSIGNAL SIGQUIT

CMD ["forego", "start", "-r"]
