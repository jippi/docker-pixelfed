#!/bin/bash
set -ex -o errexit -o nounset -o pipefail

declare -a pecl_extensions=()
readarray -d ' ' -t pecl_extensions < <(echo -n "${PHP_PECL_EXTENSIONS:-}")
readarray -d ' ' -t -O "${#pecl_extensions[@]}" pecl_extensions < <(echo -n "${PHP_PECL_EXTENSIONS_EXTRA:-}")

declare -a php_extensions=()
readarray -d ' ' -t php_extensions < <(echo -n "${PHP_EXTENSIONS:-}")
readarray -d ' ' -t -O "${#php_extensions[@]}" php_extensions < <(echo -n "${PHP_EXTENSIONS_EXTRA:-}")
readarray -d ' ' -t -O "${#php_extensions[@]}" php_extensions < <(echo -n "${PHP_EXTENSIONS_DATABASE:-}")

# PECL + PHP extensions
exec install-php-extensions "${pecl_extensions[@]}" "${php_extensions[@]}" "@composer-${COMPOSER_VERSION:-2}"
