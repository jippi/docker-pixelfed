# Entrypoint

!!! tip "If anything is confusing, unclear, missing, or maybe even wrong on this page, then *please* let us know [by submitting a bug report](https://github.com/jippi/docker-pixelfed/issues/new) :heart:"

!!! tip

    Most, if not all, configuration options for both Pixelfed and Docker is included and documented in the `.env.docker` (or `.env` file once you copied it during the installation)
    It's highly recommended to give it a read from top to bottom, or trying to search it for the thing you would like to change.

    We of course aim for this page to cover *everything*, and if we missed anything, please submit a Pull Request or a ticket for us :heart:

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

!!! tip

    With the default Pixelfed `docker-compose.yml` the `overrides` bind mount is enabled by default for both `web` and `worker` service.

    The `overrides` folder on the host machine is in `./docker-compose-state/overrides` and can be changed via `DOCKER_APP_HOST_OVERRIDES_PATH` in the `.env` file.

If you mount a bind volume (can be read-only) in `/docker/overrides` then all files and directories within that directory will be copied on top of `/`.

This enables you to create or override *anything* within the container during container startup.

The copy operation happens as one of the first things in the `ENTRYPOINT` so you can put even override [templates](#templating) and the [included `ENTRYPOINT` scripts](#run-script-on-startup-entrypoint) - or add new ones!

Of course it can also be used to override `php.ini`, `index.php` or any other config/script files you would want to.

### Override examples

1. To override `/usr/local/etc/php/php.ini` in the container, put the source file in `./docker-compose-state/overrides/usr/local/etc/php/php.ini`.
1. To create `/a/fantastic/example.txt` in the container put the source file in `./docker-compose-state/overrides/a/fantastic/example.txt`.
1. To override the default `/docker/templates/php.ini` template, put the source file in `./docker-compose-state/overrides/docker/templates/php.ini`.
1. To override `/a/path/inside/the/container`, put the source file in `./docker-compose-state/overrides/a/path/inside/the/container`.

## Fixing ownership on startup

You can set the environment variable `DOCKER_APP_ENSURE_OWNERSHIP_PATHS` to a list of paths that should have their `$USER` and `$GROUP` ownership changed to the configured runtime user and group during container bootstrapping.

The variable is a space-delimited list shown below and accepts both relative and absolute paths:

* `DOCKER_APP_ENSURE_OWNERSHIP_PATHS="./storage ./bootstrap"`
* `DOCKER_APP_ENSURE_OWNERSHIP_PATHS="/some/other/folder"`

## One-time setup tasks

!!! tip "The script stores `lock` files in the `storage/docker/once` folder to ensure that these tasks are only run once, so for new Pixelfed servers, you do not need to disable this behavior!"

The Docker container will by default try to run the required [One-time setup tasks](../../generic/installation.md#one-time-setup-tasks) for you on startup.

If your Pixelfed server already have run these tasks, you must disable this by setting `DOCKER_APP_RUN_ONE_TIME_SETUP_TASKS=0` in your `.env` file.

## Automatic database migrations

The init script will by default only *detect* if there are new database migrations - but not apply them - as these can potentially be destructive or take a long time to apply.

By setting `DB_APPLY_NEW_MIGRATIONS_AUTOMATICALLY=1` in your `.env` file, the script will automatically apply new migrations when they are detected.
