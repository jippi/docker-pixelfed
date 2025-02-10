#!/bin/bash
set -ex -o errexit -o nounset -o pipefail

# Ensure we keep apt cache around in a Docker environment
rm -f /etc/apt/apt.conf.d/docker-clean
echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache

# Don't install recommended packages by default
echo 'APT::Install-Recommends "false";' >>/etc/apt/apt.conf

# Don't install suggested packages by default
echo 'APT::Install-Suggests "false";' >>/etc/apt/apt.conf

declare -a packages=()

# Standard packages
packages+=(
    apt-utils
    bzip2 # needed for backup/db dumper
    ca-certificates
    curl
    git
    gnupg1
    gosu
    locales
    locales-all
    lsb-release
    moreutils
    nano
    procps
    unzip
    wget
    tzdata
    zip
)

# Image Optimization
packages+=(
    gifsicle
    jpegoptim
    optipng
    pngquant
)

# Video Processing
packages+=(
    ffmpeg
)

# Database
packages+=(
    mariadb-client
    postgresql-client
)

readarray -d ' ' -t -O "${#packages[@]}" packages < <(echo -n "${APT_PACKAGES_EXTRA:-}")

apt-get update
apt-get upgrade --yes
apt-get install --yes "${packages[@]}"

locale-gen
update-locale

# Set www-data to be RUNTIME_UID/RUNTIME_GID
groupmod --gid "${RUNTIME_GID?:missing}" www-data
usermod --uid "${RUNTIME_UID?:missing}" --gid "${RUNTIME_GID}" www-data

mkdir -pv /var/www/
chown -R "${RUNTIME_UID}:${RUNTIME_GID}" /var/www
