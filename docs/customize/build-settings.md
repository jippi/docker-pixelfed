# Build settings

!!! tip "If anything is confusing, unclear, missing, or maybe even wrong on this page, then *please* let us know [by submitting a bug report](https://github.com/jippi/docker-pixelfed/issues/new) :heart:"

!!! tip "Most of these build arguments is configurable in your `.env` file when using the `docker-compose.yml` from Pixelfed!"

The Pixelfed Dockerfile utilizes [Docker Multi-stage builds](https://docs.docker.com/build/building/multi-stage/) and [Build arguments](https://docs.docker.com/build/guide/build-args/).

Using *build arguments* allows us to create a flexible and more maintainable Dockerfile, supporting [multiple runtimes](./runtimes.md) ([FPM](./runtimes.md#fpm), [Nginx](./runtimes.md#nginx-fpm), [Apache + mod_php](./runtimes.md#apache)) and end-user flexibility without having to fork or copy the Dockerfile.

*Build arguments* can be configured using `--build-arg 'name=value'` for `docker build`, `docker compose build` and `docker buildx build`. For `docker-compose.yml`, the `args` key for [`build`](https://docs.docker.com/compose/compose-file/compose-file-v3/#build) can be used.

!!! warning "Most settings have two names in the title. The first one is the build arg name (`--build-arg`) and the second is the name in your `.env` file when using Docker Compose"

## `PHP_VERSION`

The `PHP` version to use when building the runtime container.

Any valid Docker Hub PHP version is acceptable here, as long as it's [published to Docker Hub](https://hub.docker.com/_/php/tags)

**Example values**:

* `8` will use the latest version of PHP 8
* `8.1` will use the latest version of PHP 8.1
* `8.2.14` will use PHP 8.2.14
* `latest` will use whatever is the latest PHP version

**Default value**: `8.1`

## `PHP_PECL_EXTENSIONS` <Badge type="warning" text="not available in your .env file" />

PECL extensions to install via `pecl install`

Use [PHP_PECL_EXTENSIONS_EXTRA](#php_pecl_extensions_extra) if you want to add *additional* extenstions.

Only change this setting if you want to change the baseline extensions.

See the [`PECL extensions` documentation on Docker Hub](https://hub.docker.com/_/php) for more information.

**Default value**: `imagick redis`

## `PHP_PECL_EXTENSIONS_EXTRA` <Badge type="tip" text="DOCKER_APP_PHP_PECL_EXTENSIONS_EXTRA in your .env file" />

Extra PECL extensions (separated by space) to install via `pecl install`

See the [`PECL extensions` documentation on Docker Hub](https://hub.docker.com/_/php) for more information.

**Default value**: `""`

## `PHP_EXTENSIONS` <Badge type="warning" text="not available in your .env file" />

PHP Extensions to install via `docker-php-ext-install`.

**NOTE:** use [`PHP_EXTENSIONS_EXTRA`](#php_extensions_extra) if you want to add *additional* extensions; only override this if you're going to change the baseline extensions.

See the [`How to install more PHP extensions` documentation on Docker Hub](https://hub.docker.com/_/php) for more information

**Default value**: `intl bcmath zip pcntl exif curl gd`

## `PHP_EXTENSIONS_EXTRA` <Badge type="tip" text="DOCKER_APP_PHP_EXTENSIONS_EXTRA in your .env file" />

Extra PHP Extensions (separated by space) to install via `docker-php-ext-install`.

See the [`How to install more PHP extensions` documentation on Docker Hub](https://hub.docker.com/_/php) for more information.

**Default value**: `""`

## `PHP_EXTENSIONS_DATABASE` <Badge type="warning" text="not available in your .env file" />

PHP database extensions to install.

By default, we install both `pgsql` and `mysql` since they're more convenient (and add very little build time! But it can be overwritten here if desired.

**Default value**: `pdo_pgsql pdo_mysql pdo_sqlite`

## `COMPOSER_VERSION` <Badge type="warning" text="not available in your .env file" />

The version of Composer to install.

For valid values, please see the [Docker Hub `composer` page](https://hub.docker.com/_/composer).

**Default value**: `2.6`

## `APT_PACKAGES_EXTRA` <Badge type="tip" text="DOCKER_APP_APT_PACKAGES_EXTRA in your .env file" />

Extra APT packages (separated by space) that should be installed inside the image by `apt-get install`

**Default value**: `""`

## `NGINX_VERSION` <Badge type="warning" text="not available in your .env file" />

The version of `nginx` to use when targeting [`nginx-runtime`](./runtimes.md#nginx-fpm).

Please see the [Docker Hub `nginx` page](https://hub.docker.com/_/nginx) for available versions.

**Default value**: `1.25.3`

## `FOREGO_VERSION` <Badge type="warning" text="not available in your .env file" />

The version of [`forego`](https://github.com/ddollar/forego) to install.

**Default value**: `0.17.2`

## `GOMPLATE_VERSION` <Badge type="warning" text="not available in your .env file" />

The version of [`goplate`](https://github.com/hairyhenderson/gomplate) to install.

**Default value**: `v3.11.6`

## `DOTENV_LINTER_VERSION` <Badge type="warning" text="not available in your .env file" />

Version of [`dotenv-linter`](https://github.com/dotenv-linter/dotenv-linter) to install.

**Default value**: `v3.2.0`

## `PHP_BASE_TYPE` <Badge type="tip" text="DOCKER_APP_BASE_TYPE in your .env file" />

The `PHP` base image layer to use when building the runtime container.

When targeting

* [`apache-runtime`](./runtimes.md#apache) use `apache`
* [`fpm-runtime`](./runtimes.md#fpm) use `fpm`
* [`nginx-runtime`](./runtimes.md#nginx-fpm) use `fpm`

**Valid values**:

* `apache`
* `fpm`
* `cli`

**Default value**: `apache`

## `PHP_DEBIAN_RELEASE` <Badge type="tip" text="DOCKER_APP_DEBIAN_RELEASE in your .env file" />

The `Debian` Operation System version to use.

**Valid values**:

* `bullseye`
* `bookworm`

**Default value**: `bullseye`
