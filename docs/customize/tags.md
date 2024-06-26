# Tags

!!! note "We do not build any `latest` tags"

    `latest` tags are typically pretty dangerous to use, especially in a fast-moving project such as Pixelfed where things might break in patch releases.

!!! tip "About semantic versioning"

    Pixelfed loosely follows [Semantic Versioning](https://semver.org/), meaning that

    * [**Major** version](https://semver.org/#spec-item-4) is the first part in the versioning (`X.y.z`)
    * [**Minor** version](https://semver.org/#spec-item-7) is the second part of the versioning `(x.Y.z)`
    * [**Patch** version](https://semver.org/#spec-item-6) is the third part of the versioning `(x.y.Z)`

!!! info

    All Docker Images are published to [GitHub Package Registry](https://github.com/jippi/docker-pixelfed/pkgs/container/docker-pixelfed).

    **Example:** [`ghcr.io/jippi/docker-pixelfed:$tag`](https://github.com/jippi/docker-pixelfed/pkgs/container/docker-pixelfed)

Instead, we now offer the following tags

<div class="annotate" markdown>

| Tag pattern | Pixelfed Version |
| ------- | ---------------- |
| `v{major}(1).{minor}(2).{patch}(3)-{runtime}(4)-{php_version}(5)` <br /><br />*Example*<br /> `v0.12.1-apache-8.3` | :white_check_mark: `0.12.1` <br /> :x: `0.12.4` <br /> :x: `0.15.4` <br /> :x: `1.0.0` <br /> :x: `2.0.0` |
| `v{major}.{minor}-{runtime}-{php_version}` <br /><br />*Example*<br /> `v0.12-apache-8.3` | :white_check_mark: `0.12.1` <br /> :white_check_mark: `0.12.4` <br /> :x: `0.15.4` <br /> :x: `v.0.0` <br /> :x: `2.0.0` |
| `v{major}-{runtime}-{php_version}` <br /><br />*Example*<br /> `v0-apache-8.3` | :white_check_mark: `0.12.1` <br /> :white_check_mark: `0.12.4` <br /> :white_check_mark: `0.15.4` <br /> :x: `1.0.0` <br /> :x: `2.0.0` |
| `nightly-{branch}(6)-{runtime}-{php_version}` <br /><br />*Example*<br /> `nightly-dev-apache-8.3` <br />`nightly-staging-apache-8.3` | :x: N/A |
| `nightly-{YYYYMMDD}(7)-{branch}-{runtime}-{php_version}` <br /><br />*Example*<br /> `nightly-20240501-dev-apache-8.3` <br />`nightly-20240501-staging-apache-8.3` | :x: N/A |
</div>

1. `{major}` is the first part in the versioning `(X.y.z)`.
2. `{minor}` is the second part of the versioning `(x.Y.z)`.
3. `{patch}` is the third part of the versioning `(x.y.Z)`.
4. `{runtime}` can be either `apache` or `nginx`. Please see [the Runtime Documentation](runtimes.md).
5. `{php_version}` Currently only supported `8.3` for the latest PHP 8.3 release.
6. `{branch}` is the `staging` or `dev` branch that Pixelfed is developed from.
7. `{YYYYMMDD}` is a date format, e.x., `20240914`, where
    * `YYYY => 2024`
    * `MM => 09`
    * `DD => 14`

## Semantic releases

`v{major}-{runtime}-{php_version}`

: *For example `v0-apache-8.3` will always point to the *latest* `0.x` release of Pixelfed, using PHP 8.3 and Apache.
: This tag is **mutable** when any new `0.x.y` release is created from Pixelfed (e.g. `0.15.4`).
: This tag is **mutable** if a new `docker-pixelfed` release is cut for any `0.x.y` Pixelfed release.

`v{major}.{minor}-{runtime}-{php_version}`

: *For example `v0.12-apache-8.3` will always point to the *latest* `0.12.x` release of Pixelfed, using PHP 8.3 and Apache.
: This tag is **mutable** when any new `0.12.x` release is created from Pixelfed (e.g. `0.12.4`).
: This tag is **mutable** if a new `docker-pixelfed` release is cut for any `0.12.x` Pixelfed release.

`v{major}.{minor}.{patch}-{runtime}-{php_version}`

: For example `v0.12.1-apache-8.3`  will always point to the *latest* `0.12.1` release of Pixelfed, using PHP 8.3 and Apache.
: This tag is **immutable** to any Pixelfed code changes.
: This tag is **mutable** if a new `docker-pixelfed` release is cut for this Pixelfed release.

`v{tag}`

: For example `v0.12.1-docker1-apache-8.3` will always point to exactly the `0.12.1` release of Pixelfed with `docker1` (this projects changes).
: This tag is **immutable** across Pixelfed and `docker-pixelfed` changes.

## Nightly

!!! info

    All Docker Images are published to [GitHub Package Registry](https://github.com/jippi/docker-pixelfed/pkgs/container/docker-pixelfed).

    **Example:** [`ghcr.io/jippi/docker-pixelfed:$tag`](https://github.com/jippi/docker-pixelfed/pkgs/container/docker-pixelfed)

We will now automatically create *nightly* builds of Pixelfed from the `dev` and `staging` branches.

`nightly-dev-{runtime}-{php_version}`

: Always points to the latest Pixelfed commit on `staging` at the time of building the image (~8am UTC).
: For example `nightly-dev-apache-8.3` will always point to the latest commit on `dev` branch on the most recent build date.

`nightly-staging-{runtime}-{php_version}`

: Always points to the latest Pixelfed commit on `staging` at the time of building the image (~8am UTC).
: For example `nightly-staging-apache-8.3` will always point to the latest commit on `staging` branch on the most recent build date.

`nightly-{YYYYMMDD}-dev-{runtime}-{php_version}`

: Points to the latest Pixelfed commit on `staging` at the specific date, at the time of building the image (~8am UTC).
: For example `nightly-20240501-dev-apache-8.3` will always point to the latest commit on `dev` branch at `2024-05-01` (May 1st 2024)

nightly-{YYYYMMDD}-staging-{runtime}-{php_version}`

: Points to the latest Pixelfed commit on `staging` at the specific date, at the time of building the image (~8am UTC).
: For example `nightly-20240501-staging-apache-8.3` will always point to the latest commit on `staging` branch at `2024-05-01` (May 1st 2024)
