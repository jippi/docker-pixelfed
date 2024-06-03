# Pixelfed + Docker customization

::: tip If anything is confusing, unclear, missing, or maybe even wrong on this page, then *please* let us know [by submitting a bug report](https://github.com/pixelfed/pixelfed/issues/new) :heart:
:::

::: tip Most, if not all, configuration options for both Pixelfed and Docker is included and documented in the `.env.docker` (or `.env` file once you copied it during the installation)
It's highly recommended to give it a read from top to bottom, or trying to search it for the thing you would like to change.

We of course aim for this page to cover *everything*, and if we missed anything, please submit a Pull Request or a ticket for us :heart:
:::

## Run script on startup (ENTRYPOINT)

When a Pixelfed container starts up, the [`ENTRYPOINT`](https://docs.docker.com/engine/reference/builder/#entrypoint) script will

1. Search the `/docker/entrypoint.d/` directory for files and for each file (in lexical order).
1. Check if the file is executable.
    1. If the file is *not* executable, print an error and exit the container.
1. If the file has the extension `.envsh`, the file will be [sourced](https://superuser.com/a/46146).
1. If the file has the extension `.sh`, the file will be run like a regular script.
1. Any other file extension will log a warning and be ignored.

### Debugging

You can set the environment variable `DOCKER_APP_ENTRYPOINT_DEBUG=1` to show the verbose output of each `entrypoint.d` script is doing.

### Included scripts

* `01-permissions.sh` (optionally) ensures permissions for files are corrected (see [fixing ownership on startup](#fixing-ownership-on-startup)).
* `02-check-config.sh` Ensures your `.env` file is valid - like missing quotes or syntax errors.
* `04-defaults.envsh` calculates Docker container environment variables needed for [templating](#templating) configuration files.
* `05-templating.sh` renders [template](#templating) configuration files.
* `10-storage.sh` ensures Pixelfed storage related permissions and commands are run.
* `11-first-time-setup.sh` automatically runs all "one time setup" steps for a new Pixelfed server.
* `12-migrations.sh` optionally run database migrations on container start up.
* `20-horizon.sh` ensures [Laravel Horizon](https://laravel.com/docs/master/horizon) used by Pixelfed is configured.
* `30-cache.sh` ensures all Pixelfed caches (router, view, config) are primed.

### Disabling `ENTRYPOINT` or individual scripts

To disable the entire `ENTRYPOINT` you can set the variable `ENTRYPOINT_SKIP=1`.

To disable individual `ENTRYPOINT` scripts, you can add the filename to the space (`" "`) separated variable `ENTRYPOINT_SKIP_SCRIPTS`. (example: `ENTRYPOINT_SKIP_SCRIPTS="10-storage.sh 30-cache.sh"`)

## Override anything and everything

::: tip
With the default Pixelfed `docker-compose.yml` the `overrides` bind mount is enabled by default for both `web` and `worker` service.

The `overrides` folder on the host machine is in `./docker-compose-state/overrides` and can be changed via `DOCKER_APP_HOST_OVERRIDES_PATH` in the `.env` file.
:::

If you mount a bind volume (can be read-only) in `/docker/overrides` then all files and directories within that directory will be copied on top of `/`.

This enables you to create or override *anything* within the container during container startup.

The copy operation happens as one of the first things in the `ENTRYPOINT` so you can put even override [templates](#templating) and the [included `ENTRYPOINT` scripts](#run-script-on-startup-entrypoint) - or add new ones!

Of course it can also be used to override `php.ini`, `index.php` or any other config/script files you would want to.

### Override examples

1. To override `/usr/local/etc/php/php.ini` in the container, put the source file in `./docker-compose-state/overrides/usr/local/etc/php/php.ini`.
1. To create `/a/fantastic/example.txt` in the container put the source file in `./docker-compose-state/overrides/a/fantastic/example.txt`.
1. To override the default `/docker/templates/php.ini` template, put the source file in `./docker-compose-state/overrides/docker/templates/php.ini`.
1. To override `/a/path/inside/the/container`, put the source file in `./docker-compose-state/overrides/a/path/inside/the/container`.

## Templating

The Docker container can do some basic templating (more like variable replacement) as part of the entrypoint scripts via [gomplate](https://docs.gomplate.ca/).

Any file in the `/docker/templates/` directory will be templated and written to the proper directory.

### File path examples

1. To template `/usr/local/etc/php/php.ini` in the container, put the source file in `/docker/templates/usr/local/etc/php/php.ini`.
1. To template `/a/fantastic/example.txt` in the container put the source file in `/docker/templates/a/fantastic/example.txt`.
1. To template `/some/path/anywhere` in the container, put the source file in `/docker/templates/some/path/anywhere`.

### Available variables

Variables available for templating are sourced (in order, so *last* source takes precedence) like this:

1. `env:` in your `docker-compose.yml` or `-e` in your `docker run` / `docker compose run` commands.
1. Any exported variables in `.envsh` files loaded *before* `05-templating.sh` (e.g., any file with `04-`, `03-`, `02-`, `01-` or `00-` prefix).
1. All key and value pairs in `/var/www/.env.docker` (default values, you should not edit this file!)
1. All key and value pairs in `/var/www/.env`.

### Template guide 101

Please see the [`gomplate` documentation](https://docs.gomplate.ca/) for a comprehensive overview.

The most frequent use case you have is likely to print an environment variable (or a default value if it's missing), so this is how to do that:

* <code v-pre>{{ getenv "VAR_NAME" }}</code> print an environment variable and **fail** if the variable is not set. ([docs](https://docs.gomplate.ca/functions/env/#envgetenv))
* <code v-pre>{{ getenv "VAR_NAME" "default" }}</code> print an environment variable and print `default` if the variable is not set. ([docs](https://docs.gomplate.ca/functions/env/#envgetenv))

The script will *fail* if you reference a variable that does not exist (and doesn't have a default value) in a template.

Please see the

* [`gomplate` syntax documentation](https://docs.gomplate.ca/syntax/)
* [`gomplate` functions documentation](https://docs.gomplate.ca/functions/)

## Fixing ownership on startup

You can set the environment variable `DOCKER_APP_ENSURE_OWNERSHIP_PATHS` to a list of paths that should have their `$USER` and `$GROUP` ownership changed to the configured runtime user and group during container bootstrapping.

The variable is a space-delimited list shown below and accepts both relative and absolute paths:

* `DOCKER_APP_ENSURE_OWNERSHIP_PATHS="./storage ./bootstrap"`
* `DOCKER_APP_ENSURE_OWNERSHIP_PATHS="/some/other/folder"`

## One-time setup tasks

:::tip
The script stores `lock` files in the `storage/docker/once` folder to ensure that these tasks are only run once, so for new Pixelfed servers, you do not need to disable this behavior!
:::

The Docker container will by default try to run the required [One-time setup tasks](../generic/installation.md#one-time-setup-tasks) for you on startup.

If your Pixelfed server already have run these tasks, you must disable this by setting `DOCKER_APP_RUN_ONE_TIME_SETUP_TASKS=0` in your `.env` file.

## Automatic database migrations

The init script will by default only *detect* if there are new database migrations - but not apply them - as these can potentially be destructive or take a long time to apply.

By setting `DB_APPLY_NEW_MIGRATIONS_AUTOMATICALLY=1` in your `.env` file, the script will automatically apply new migrations when they are detected.

## Build settings (arguments)

::: tip Most of these build arguments is configurable in your `.env` file when using the `docker-compose.yml` from Pixelfed!
:::

The Pixelfed Dockerfile utilizes [Docker Multi-stage builds](https://docs.docker.com/build/building/multi-stage/) and [Build arguments](https://docs.docker.com/build/guide/build-args/).

Using *build arguments* allows us to create a flexible and more maintainable Dockerfile, supporting [multiple runtimes](runtimes.md) ([FPM](runtimes.md#fpm), [Nginx](runtimes.md#nginx-fpm), [Apache + mod_php](runtimes.md#apache)) and end-user flexibility without having to fork or copy the Dockerfile.

*Build arguments* can be configured using `--build-arg 'name=value'` for `docker build`, `docker compose build` and `docker buildx build`. For `docker-compose.yml`, the `args` key for [`build`](https://docs.docker.com/compose/compose-file/compose-file-v3/#build) can be used.

::: warning Most settings have two names in the title. The first one is the build arg name (`--build-arg`) and the second is the name in your `.env` file when using Docker Compose
:::

### `PHP_VERSION` <Badge type="tip" text="DOCKER_APP_PHP_VERSION in your .env file" />

The `PHP` version to use when building the runtime container.

Any valid Docker Hub PHP version is acceptable here, as long as it's [published to Docker Hub](https://hub.docker.com/_/php/tags)

**Example values**:

* `8` will use the latest version of PHP 8
* `8.1` will use the latest version of PHP 8.1
* `8.2.14` will use PHP 8.2.14
* `latest` will use whatever is the latest PHP version

**Default value**: `8.1`

### `PHP_PECL_EXTENSIONS` <Badge type="warning" text="not available in your .env file" />

PECL extensions to install via `pecl install`

Use [PHP_PECL_EXTENSIONS_EXTRA](#php_pecl_extensions_extra) if you want to add *additional* extenstions.

Only change this setting if you want to change the baseline extensions.

See the [`PECL extensions` documentation on Docker Hub](https://hub.docker.com/_/php) for more information.

**Default value**: `imagick redis`

### `PHP_PECL_EXTENSIONS_EXTRA` <Badge type="tip" text="DOCKER_APP_PHP_PECL_EXTENSIONS_EXTRA in your .env file" />

Extra PECL extensions (separated by space) to install via `pecl install`

See the [`PECL extensions` documentation on Docker Hub](https://hub.docker.com/_/php) for more information.

**Default value**: `""`

### `PHP_EXTENSIONS` <Badge type="warning" text="not available in your .env file" />

PHP Extensions to install via `docker-php-ext-install`.

**NOTE:** use [`PHP_EXTENSIONS_EXTRA`](#php_extensions_extra) if you want to add *additional* extensions; only override this if you're going to change the baseline extensions.

See the [`How to install more PHP extensions` documentation on Docker Hub](https://hub.docker.com/_/php) for more information

**Default value**: `intl bcmath zip pcntl exif curl gd`

### `PHP_EXTENSIONS_EXTRA` <Badge type="tip" text="DOCKER_APP_PHP_EXTENSIONS_EXTRA in your .env file" />

Extra PHP Extensions (separated by space) to install via `docker-php-ext-install`.

See the [`How to install more PHP extensions` documentation on Docker Hub](https://hub.docker.com/_/php) for more information.

**Default value**: `""`

### `PHP_EXTENSIONS_DATABASE` <Badge type="warning" text="not available in your .env file" />

PHP database extensions to install.

By default, we install both `pgsql` and `mysql` since they're more convenient (and add very little build time! But it can be overwritten here if desired.

**Default value**: `pdo_pgsql pdo_mysql pdo_sqlite`

### `COMPOSER_VERSION` <Badge type="warning" text="not available in your .env file" />

The version of Composer to install.

For valid values, please see the [Docker Hub `composer` page](https://hub.docker.com/_/composer).

**Default value**: `2.6`

### `APT_PACKAGES_EXTRA` <Badge type="tip" text="DOCKER_APP_APT_PACKAGES_EXTRA in your .env file" />

Extra APT packages (separated by space) that should be installed inside the image by `apt-get install`

**Default value**: `""`

### `NGINX_VERSION` <Badge type="warning" text="not available in your .env file" />

The version of `nginx` to use when targeting [`nginx-runtime`](runtimes.md#nginx-fpm).

Please see the [Docker Hub `nginx` page](https://hub.docker.com/_/nginx) for available versions.

**Default value**: `1.25.3`

### `FOREGO_VERSION` <Badge type="warning" text="not available in your .env file" />

The version of [`forego`](https://github.com/ddollar/forego) to install.

**Default value**: `0.17.2`

### `GOMPLATE_VERSION` <Badge type="warning" text="not available in your .env file" />

The version of [`goplate`](https://github.com/hairyhenderson/gomplate) to install.

**Default value**: `v3.11.6`

### `DOTENV_LINTER_VERSION` <Badge type="warning" text="not available in your .env file" />

Version of [`dotenv-linter`](https://github.com/dotenv-linter/dotenv-linter) to install.

**Default value**: `v3.2.0`

### `PHP_BASE_TYPE` <Badge type="tip" text="DOCKER_APP_BASE_TYPE in your .env file" />

The `PHP` base image layer to use when building the runtime container.

When targeting

* [`apache-runtime`](runtimes.md#apache) use `apache`
* [`fpm-runtime`](runtimes.md#fpm) use `fpm`
* [`nginx-runtime`](runtimes.md#nginx-fpm) use `fpm`

**Valid values**:

* `apache`
* `fpm`
* `cli`

**Default value**: `apache`

### `PHP_DEBIAN_RELEASE` <Badge type="tip" text="DOCKER_APP_DEBIAN_RELEASE in your .env file" />

The `Debian` Operation System version to use.

**Valid values**:

* `bullseye`
* `bookworm`

**Default value**: `bullseye`
