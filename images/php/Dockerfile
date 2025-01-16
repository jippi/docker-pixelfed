# syntax=docker/dockerfile:1
# See https://hub.docker.com/r/docker/dockerfile

#######################################################
# Configuration
#######################################################

# See: https://github.com/composer/composer
#
# renovate: datasource=github-releases depName=composer/composer
ARG COMPOSER_VERSION="2.8.4"

###
# PHP base configuration
###

# See: https://hub.docker.com/_/php/tags
#
# renovate: datasource=docker depName=php versioning=semver-coerced
ARG PHP_VERSION="8.3"

# See: https://github.com/docker-library/docs/blob/master/php/README.md#image-variants
ARG PHP_BASE_TYPE="apache"
ARG PHP_DEBIAN_RELEASE="bookworm"

ARG RUNTIME_UID=33 # often called 'www-data'
ARG RUNTIME_GID=33 # often called 'www-data'

# APT extra packages
ARG APT_PACKAGES_EXTRA=

# PHP extensions installed via [pecl install]
ARG PHP_PECL_EXTENSIONS=""
ARG PHP_PECL_EXTENSIONS_EXTRA=

# PHP extensions installed via https://deb.sury.org/
# ! NOTE: Must not include the "php8.x-" prefix for packages
# !       so [php8.3-bcmath] should just be [bcmath] here
ARG PHP_EXTENSIONS="intl bcmath zip curl gd yaml redis imagick xml"
ARG PHP_EXTENSIONS_EXTRA=""
ARG PHP_EXTENSIONS_DATABASE="pgsql mysql sqlite"

#######################################################
# Base image
#######################################################

FROM debian:${PHP_DEBIAN_RELEASE}

ENV DEBIAN_FRONTEND="noninteractive"

ARG RUNTIME_GID
ARG RUNTIME_UID
ARG TARGETPLATFORM

# Ensure we run all scripts through 'bash' rather than 'sh'
SHELL ["/bin/bash", "-c"]

# Set www-data to be RUNTIME_UID/RUNTIME_GID
RUN set -ex \
    && groupmod --gid ${RUNTIME_GID} www-data \
    && usermod --uid ${RUNTIME_UID} --gid ${RUNTIME_GID} www-data

RUN set -ex \
    && mkdir -pv /var/www/ \
    && chown -R ${RUNTIME_UID}:${RUNTIME_GID} /var/www

WORKDIR /var/www/

ARG PHP_VERSION
ARG PHP_DEBIAN_RELEASE
ARG APT_PACKAGES_EXTRA
ENV APT_PACKAGES_EXTRA=${APT_PACKAGES_EXTRA}

# Copy the base layer installer into the image
COPY rootfs/docker/install/base.sh /docker/install/base.sh

RUN --mount=type=cache,id=pixelfed-apt-${PHP_VERSION}-${PHP_DEBIAN_RELEASE}-${TARGETPLATFORM},sharing=locked,target=/var/lib/apt \
    --mount=type=cache,id=pixelfed-apt-cache-${PHP_VERSION}-${PHP_DEBIAN_RELEASE}-${TARGETPLATFORM},sharing=locked,target=/var/cache/apt \
    /docker/install/base.sh

#######################################################
# PHP: extensions
#######################################################

ARG COMPOSER_VERSION
ARG PHP_EXTENSIONS
ARG PHP_EXTENSIONS_DATABASE
ARG PHP_EXTENSIONS_EXTRA
ARG PHP_PECL_EXTENSIONS
ARG PHP_PECL_EXTENSIONS_EXTRA
ARG PHP_BASE_TYPE

# Copy the PHP layer installer into the image
COPY rootfs/docker/install/php.sh /docker/install/php.sh

RUN --mount=type=cache,id=pixelfed-pear-${PHP_VERSION}-${PHP_DEBIAN_RELEASE}-${TARGETPLATFORM},sharing=locked,target=/tmp/pear \
    --mount=type=cache,id=pixelfed-apt-${PHP_VERSION}-${PHP_DEBIAN_RELEASE}-${TARGETPLATFORM},sharing=locked,target=/var/lib/apt \
    --mount=type=cache,id=pixelfed-apt-cache-${PHP_VERSION}-${PHP_DEBIAN_RELEASE}-${TARGETPLATFORM},sharing=locked,target=/var/cache/apt \
    IPE_KEEP_SYSPKG_CACHE=1 \
    COMPOSER_VERSION=${COMPOSER_VERSION} \
    PHP_EXTENSIONS_DATABASE=${PHP_EXTENSIONS_DATABASE} \
    PHP_EXTENSIONS_EXTRA=${PHP_EXTENSIONS_EXTRA} \
    PHP_EXTENSIONS=${PHP_EXTENSIONS} \
    PHP_PECL_EXTENSIONS_EXTRA=${PHP_PECL_EXTENSIONS_EXTRA} \
    PHP_PECL_EXTENSIONS=${PHP_PECL_EXTENSIONS} \
    PHP_BASE_TYPE=${PHP_BASE_TYPE} \
    /docker/install/php.sh

# Copy everything else there might be in the rootfs into the container
COPY rootfs/ /

#######################################################
# PHP: composer
#######################################################

# Make sure composer cache is targeting our cache mount later
ENV COMPOSER_CACHE_DIR="/cache/composer"

# Don't enforce any memory limits for composer
ENV COMPOSER_MEMORY_LIMIT=-1

# Disable interactvitity from composer
ENV COMPOSER_NO_INTERACTION=1

#######################################################
# Baseline image
#######################################################

ENV RUNTIME_UID=${RUNTIME_UID}
ENV RUNTIME_GID=${RUNTIME_GID}

#! Changing user to runtime user
USER ${RUNTIME_UID}:${RUNTIME_GID}
