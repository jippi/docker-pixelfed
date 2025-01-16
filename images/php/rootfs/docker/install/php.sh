#!/bin/bash
set -ex -o errexit -o nounset -o pipefail

#############################################
# Setup PHP package source
#############################################

curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb
dpkg -i /tmp/debsuryorg-archive-keyring.deb
sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
apt-get update
rm -f /tmp/debsuryorg-archive-keyring.deb

#############################################
# Install PHP (binary) packages
#############################################

declare -a php_extensions=(cli)

if [[ $PHP_BASE_TYPE == 'fpm' ]]; then
    php_extensions+=(fpm)
fi

readarray -d ' ' -t php_extensions < <(echo -n "${PHP_EXTENSIONS:-}")
readarray -d ' ' -t -O "${#php_extensions[@]}" php_extensions < <(echo -n "${PHP_EXTENSIONS_EXTRA:-}")
readarray -d ' ' -t -O "${#php_extensions[@]}" php_extensions < <(echo -n "${PHP_EXTENSIONS_DATABASE:-}")

# join the strings and prefix them with [php${version}-], so [gd] turns into [php8.3-gd]
php_extensions_string="${php_extensions[*]/#/php${PHP_VERSION}-}"

if [[ $PHP_BASE_TYPE == 'apache' ]]; then
    php_extensions_string+=" libapache2-mod-php${PHP_VERSION}"
fi

# shellcheck disable=SC2086
apt-get install -y ${php_extensions_string}

#############################################
# Install Composer
#############################################

curl -o composer-setup.php https://getcomposer.org/installer
php composer-setup.php --version="${COMPOSER_VERSION:-2}" --filename=composer --install-dir=/usr/local/bin
rm composer-setup.php

#############################################
# Install PECL extensions
#############################################

declare -a pecl_extensions=()
readarray -d ' ' -t pecl_extensions < <(echo -n "${PHP_PECL_EXTENSIONS:-}")
readarray -d ' ' -t -O "${#pecl_extensions[@]}" pecl_extensions < <(echo -n "${PHP_PECL_EXTENSIONS_EXTRA:-}")
