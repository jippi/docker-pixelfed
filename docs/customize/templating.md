# Templating

!!! tip "If anything is confusing, unclear, missing, or maybe even wrong on this page, then *please* let us know [by submitting a bug report](https://github.com/jippi/docker-pixelfed/issues/new) :heart:"

The Docker container can do some basic templating (more like variable replacement) as part of the entrypoint scripts via [gomplate](https://docs.gomplate.ca/).

Any file in the `/docker/templates/` directory will be templated and written to the proper directory.

## File path examples

1. To template `/usr/local/etc/php/php.ini` in the container, put the source file in `/docker/templates/usr/local/etc/php/php.ini`.
1. To template `/a/fantastic/example.txt` in the container put the source file in `/docker/templates/a/fantastic/example.txt`.
1. To template `/some/path/anywhere` in the container, put the source file in `/docker/templates/some/path/anywhere`.

## Available variables

Variables available for templating are sourced (in order, so *last* source takes precedence) like this:

1. `env:` in your `docker-compose.yml` or `-e` in your `docker run` / `docker compose run` commands.
1. Any exported variables in `.envsh` files loaded *before* `05-templating.sh` (e.g., any file with `04-`, `03-`, `02-`, `01-` or `00-` prefix).
1. All key and value pairs in `/var/www/.env.docker` (default values, you should not edit this file!)
1. All key and value pairs in `/var/www/.env`.

## Template guide 101

Please see the [`gomplate` documentation](https://docs.gomplate.ca/) for a comprehensive overview.

The most frequent use case you have is likely to print an environment variable (or a default value if it's missing), so this is how to do that:

* <code v-pre>{{ getenv "VAR_NAME" }}</code> print an environment variable and **fail** if the variable is not set. ([docs](https://docs.gomplate.ca/functions/env/#envgetenv))
* <code v-pre>{{ getenv "VAR_NAME" "default" }}</code> print an environment variable and print `default` if the variable is not set. ([docs](https://docs.gomplate.ca/functions/env/#envgetenv))

The script will *fail* if you reference a variable that does not exist (and doesn't have a default value) in a template.

Please see the

* [`gomplate` syntax documentation](https://docs.gomplate.ca/syntax/)
* [`gomplate` functions documentation](https://docs.gomplate.ca/functions/)
