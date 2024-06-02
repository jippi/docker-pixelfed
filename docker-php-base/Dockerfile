# syntax=docker/dockerfile:1
# See https://hub.docker.com/r/docker/dockerfile

#######################################################
# Configuration
#######################################################

# See: https://github.com/mlocati/docker-php-extension-installer
ARG DOCKER_PHP_EXTENSION_INSTALLER_VERSION="2.1.80"

# See: https://github.com/composer/composer
ARG COMPOSER_VERSION="2.6"

###
# PHP base configuration
###

# See: https://hub.docker.com/_/php/tags
ARG PHP_VERSION="8.3"

# See: https://github.com/docker-library/docs/blob/master/php/README.md#image-variants
ARG PHP_BASE_TYPE="apache"
ARG PHP_DEBIAN_RELEASE="bullseye"

ARG RUNTIME_UID=33 # often called 'www-data'
ARG RUNTIME_GID=33 # often called 'www-data'

# APT extra packages
ARG APT_PACKAGES_EXTRA=

# Extensions installed via [pecl install]
# ! NOTE: imagick is installed from [master] branch on GitHub due to 8.3 bug on ARM that haven't
# ! been released yet (after +10 months)!
# ! See: https://github.com/Imagick/imagick/pull/641
ARG PHP_PECL_EXTENSIONS="redis https://codeload.github.com/Imagick/imagick/tar.gz/28f27044e435a2b203e32675e942eb8de620ee58"
ARG PHP_PECL_EXTENSIONS_EXTRA=

# Extensions installed via [docker-php-ext-install]
ARG PHP_EXTENSIONS="intl bcmath zip pcntl exif curl gd"
ARG PHP_EXTENSIONS_EXTRA=""
ARG PHP_EXTENSIONS_DATABASE="pdo_pgsql pdo_mysql pdo_sqlite"

#######################################################
# Docker "copy from" images
#######################################################

# Composer docker image from Docker Hub
#
# NOTE: Docker will *not* pull this image unless it's referenced (via build target)
FROM composer:${COMPOSER_VERSION} AS composer-image

# php-extension-installer image from Docker Hub
#
# NOTE: Docker will *not* pull this image unless it's referenced (via build target)
FROM mlocati/php-extension-installer:${DOCKER_PHP_EXTENSION_INSTALLER_VERSION} AS php-extension-installer

#######################################################
# Base image
#######################################################

FROM php:${PHP_VERSION}-${PHP_BASE_TYPE}-${PHP_DEBIAN_RELEASE}

ARG BUILDKIT_SBOM_SCAN_STAGE="true"

ARG APT_PACKAGES_EXTRA
ARG PHP_DEBIAN_RELEASE
ARG PHP_EXTENSIONS
ARG PHP_EXTENSIONS_DATABASE
ARG PHP_EXTENSIONS_EXTRA
ARG PHP_PECL_EXTENSIONS
ARG PHP_PECL_EXTENSIONS_EXTRA
ARG PHP_VERSION
ARG RUNTIME_GID
ARG RUNTIME_UID
ARG TARGETPLATFORM

ENV DEBIAN_FRONTEND="noninteractive"

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

ENV APT_PACKAGES_EXTRA=${APT_PACKAGES_EXTRA}

# Install and configure base layer
COPY rootfs/ /

RUN --mount=type=cache,id=pixelfed-apt-${PHP_VERSION}-${PHP_DEBIAN_RELEASE}-${TARGETPLATFORM},sharing=locked,target=/var/lib/apt \
    --mount=type=cache,id=pixelfed-apt-cache-${PHP_VERSION}-${PHP_DEBIAN_RELEASE}-${TARGETPLATFORM},sharing=locked,target=/var/cache/apt \
    /docker/install/base.sh

#######################################################
# PHP: extensions
#######################################################

COPY --from=php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN --mount=type=cache,id=pixelfed-pear-${PHP_VERSION}-${PHP_DEBIAN_RELEASE}-${TARGETPLATFORM},sharing=locked,target=/tmp/pear  \
    --mount=type=cache,id=pixelfed-apt-${PHP_VERSION}-${PHP_DEBIAN_RELEASE}-${TARGETPLATFORM},sharing=locked,target=/var/lib/apt \
    --mount=type=cache,id=pixelfed-apt-cache-${PHP_VERSION}-${PHP_DEBIAN_RELEASE}-${TARGETPLATFORM},sharing=locked,target=/var/cache/apt \
    PHP_EXTENSIONS=${PHP_EXTENSIONS} \
    PHP_EXTENSIONS_DATABASE=${PHP_EXTENSIONS_DATABASE} \
    PHP_EXTENSIONS_EXTRA=${PHP_EXTENSIONS_EXTRA} \
    PHP_PECL_EXTENSIONS=${PHP_PECL_EXTENSIONS} \
    PHP_PECL_EXTENSIONS_EXTRA=${PHP_PECL_EXTENSIONS_EXTRA} \
    /docker/install/php-extensions.sh

#######################################################
# PHP: composer
#######################################################

# Make sure composer cache is targeting our cache mount later
ENV COMPOSER_CACHE_DIR="/cache/composer"

# Don't enforce any memory limits for composer
ENV COMPOSER_MEMORY_LIMIT=-1

# Disable interactvitity from composer
ENV COMPOSER_NO_INTERACTION=1

# Copy composer from https://hub.docker.com/_/composer
COPY --link --from=composer-image /usr/bin/composer /usr/bin/composer

#######################################################
# Baseline image
#######################################################

ENV RUNTIME_UID=${RUNTIME_UID}
ENV RUNTIME_GID=${RUNTIME_GID}

#! Changing user to runtime user
USER ${RUNTIME_UID}:${RUNTIME_GID}
