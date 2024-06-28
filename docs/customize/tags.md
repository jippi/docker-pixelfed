# Docker and Pixelfed versions

!!! note "We do not build any `latest` tags"

    `latest` tags are typically pretty dangerous to use, especially in a fast-moving project such as Pixelfed where things might break in patch releases.

!!! info

    All Docker Images are published to [GitHub Package Registry](https://github.com/jippi/docker-pixelfed/pkgs/container/docker-pixelfed).

    **Example:** [`ghcr.io/jippi/docker-pixelfed:$tag`](https://github.com/jippi/docker-pixelfed/pkgs/container/docker-pixelfed)

## How it works

Your `.env` file contains a couple of settings that, when combined, constructs the final Docker tag for your Pixelfed instance.

* [`DOCKER_APP_RELEASE`](#pixelfed-version) for the Pixelfed version.
* [`DOCKER_APP_RUNTIME`](#runtime) for the runtime type.
* [`DOCKER_APP_PHP_VERSION`](#php-version) for the PHP version.
* [`DOCKER_APP_DEBIAN_RELEASE`](#debian-release) for the Debian release.
* [`DOCKER_APP_IMAGE`](settings.md#docker_app_image) for the Docker image name

They are then combined into a final Docker image like this

* `${DOCKER_APP_IMAGE}:${DOCKER_APP_RELEASE}-${DOCKER_APP_RUNTIME}-${DOCKER_APP_PHP_VERSION}-${DOCKER_APP_DEBIAN_RELEASE}`

For example

* `ghcr.io/jippi/docker-pixelfed:v0.12.1-docker13-apache-8.3-bookworm`
* `ghcr.io/jippi/docker-pixelfed:nightly-20240628-staging-nginx-8.3-bookworm`

## Pixelfed version

!!! info

    The [`DOCKER_APP_PHP_VERSION`](settings.md#docker_app_php_version) setting in your `.env` file control what Pixelfed version you will be running on your server.

!!! tip "About semantic versioning"

    Pixelfed loosely follows [Semantic Versioning](https://semver.org/), meaning that

    * [**Major** version](https://semver.org/#spec-item-4) is the first part in the versioning (`X.y.z`)
    * [**Minor** version](https://semver.org/#spec-item-7) is the second part of the versioning `(x.Y.z)`
    * [**Patch** version](https://semver.org/#spec-item-6) is the third part of the versioning `(x.y.Z)`

<div class="annotate" markdown>

| [`DOCKER_APP_PHP_VERSION`](settings.md#docker_app_php_version) | Pixelfed Version |
| ----------- | ---------------- |
| `v{major}(1).{minor}(2).{patch}(3)` <br /><br />**Example**<br /> `v0.12.1` | :white_check_mark: `0.12.1` <br /> :x: `0.12.4` <br /> :x: `0.15.4` <br /> :x: `1.0.0` <br /> :x: `2.0.0` |
| `v{major}.{minor}` <br /><br />**Example**<br /> `v0.12` | :white_check_mark: `0.12.1` <br /> :white_check_mark: `0.12.4` <br /> :x: `0.15.4` <br /> :x: `v.0.0` <br /> :x: `2.0.0` |
| `v{major}` <br /><br />**Example**<br /> `v0` | :white_check_mark: `0.12.1` <br /> :white_check_mark: `0.12.4` <br /> :white_check_mark: `0.15.4` <br /> :x: `1.0.0` <br /> :x: `2.0.0` |
| `nightly-{branch}(6)` <br /><br />**Example**<br />`nightly-dev-apache-8.3`<br />`nightly-staging-apache-8.3` | :x: N/A |
| `nightly-{YYYY-MM-DD}(7)-{branch}` <br /><br />**Example**<br />`nightly-2024-05-01-dev`<br />`nightly-2024-05-01-staging` | :x: N/A |
</div>

1. `{major}` is the first part in the versioning `(X.y.z)`.
2. `{minor}` is the second part of the versioning `(x.Y.z)`.
3. `{patch}` is the third part of the versioning `(x.y.Z)`.
4. `{runtime}` can be either `apache` or `nginx`. Please see [the Runtime Documentation](runtimes.md).
5. `{php_version}` Currently only supported `8.3` for the latest PHP 8.3 release.
6. `{branch}` is the `staging` or `dev` branch that Pixelfed is developed from.
7. `{YYYY-MM-DD}` is a date format, e.x., `2024-09-14`, where
    * `YYYY => 2024`
    * `MM => 09`
    * `DD => 14`

### Semantic releases

`v{major}`

: *For example `v0` will always point to the *latest* `0.x` release of Pixelfed, using PHP 8.3 and Apache.
: This tag is **mutable** when any new `0.x.y` release is created from Pixelfed (e.g. `0.15.4`).
: This tag is **mutable** if a new `docker-pixelfed` release is cut for any `0.x.y` Pixelfed release.

`v{major}.{minor}`

: *For example `v0.12` will always point to the *latest* `0.12.x` release of Pixelfed, using PHP 8.3 and Apache.
: This tag is **mutable** when any new `0.12.x` release is created from Pixelfed (e.g. `0.12.4`).
: This tag is **mutable** if a new `docker-pixelfed` release is cut for any `0.12.x` Pixelfed release.

`v{major}.{minor}.{patch}`

: For example `v0.12.1`  will always point to the *latest* `0.12.1` release of Pixelfed, using PHP 8.3 and Apache.
: This tag is **immutable** to any Pixelfed code changes.
: This tag is **mutable** if a new `docker-pixelfed` release is cut for this Pixelfed release.

`v{tag}`

: For example `v0.12.1-docker1` will always point to exactly the `0.12.1` release of Pixelfed with `docker1` (this projects changes).
: This tag is **immutable** across Pixelfed and `docker-pixelfed` changes.

### Nightly releases

!!! info

    All Docker Images are published to [GitHub Package Registry](https://github.com/jippi/docker-pixelfed/pkgs/container/docker-pixelfed).

    **Example:** [`ghcr.io/jippi/docker-pixelfed:$tag`](https://github.com/jippi/docker-pixelfed/pkgs/container/docker-pixelfed)

We will now automatically create *nightly* builds of Pixelfed from the `dev` and `staging` branches.

`nightly-dev`

: Always points to the latest Pixelfed commit on `staging` at the time of building the image (~8am UTC).
: For example `nightly-dev` will always point to the latest commit on `dev` branch on the most recent build date.

`nightly-staging`

: Always points to the latest Pixelfed commit on `staging` at the time of building the image (~8am UTC).
: For example `nightly-staging` will always point to the latest commit on `staging` branch on the most recent build date.

`nightly-{YYYY-MM-DD}-dev`

: Points to the latest Pixelfed commit on `staging` at the specific date, at the time of building the image (~8am UTC).
: For example `nightly-2024-05-01-dev` will always point to the latest commit on `dev` branch at `2024-05-01` (May 1st 2024)

`nightly-{YYYY-MM-DD}-staging`

: Points to the latest Pixelfed commit on `staging` at the specific date, at the time of building the image (~8am UTC).
: For example `nightly-2024-05-01-staging` will always point to the latest commit on `staging` branch at `2024-05-01` (May 1st 2024)

## Runtime

!!! info

    See the [dedicated `Runtimes` documentation for more information](runtimes.md)

## PHP version

!!! info

    The [`DOCKER_APP_PHP_VERSION`](settings.md#docker_app_php_version) setting controls what version of PHP is being used

We currently only support a single PHP release:

* `8.3`

## Debian release

!!! info

    The [`DOCKER_APP_DEBIAN_RELEASE`](settings.md#docker_app_debian_release) setting controls what version of Debian is being used

We currently only support a single Debian release:

* `bookworm`
