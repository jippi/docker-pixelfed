# Pixelfed + Docker container runtimes

::: tip If anything is confusing, unclear, missing, or maybe even wrong on this page, then *please* let us know [by submitting a bug report](https://github.com/pixelfed/pixelfed/issues/new) :heart:
:::

The Pixelfed Dockerfile support multiple target *runtimes* ([Apache](#apache), [Nginx + FPM](#nginx-fpm), and [FPM](#fpm)).

You can consider a *runtime* target as individual Dockerfiles, but instead, all of them are built from the same optimized Dockerfile, sharing +90% of their configuration and packages.

::: info What runtime is right for me?
If you are unsure of which runtime to choose, please use the [Apache runtime](#apache); it's the most straightforward one and also the default.
:::

## Apache  <Badge type="tip" text="Recommended" />

::: tip RECOMMENDED
This is the default *and* recommended runtime for almost all single-server Pixelfed instances, as it has fewer moving parts, simplified operational model, and strikes a good balance between performance, features, and convenience.
:::

Building a custom Pixelfed Docker image using `Apache` + `mod_php` can be achieved the following way.

### docker build (Apache)

```shell
docker build \
 -f Dockerfile \
 --target apache-runtime \
 --tag <docker hub user>/<docker hub repo> \
 .
```

### docker compose (Apache)

:::info This is already configured if you use the default Pixelfed `docker-compose.yml`

Instead you control the target runtime via your `.env` file

```shell
DOCKER_APP_BASE_TYPE="apache"
DOCKER_APP_RUNTIME="apache"
```

:::

```yaml
version: "3"

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: apache-runtime
```

## Nginx + FPM <Badge type="warning" text="Advanced" />

:::info ADVANCED USAGE
Nginx + FPM has more moving parts than the default (and recommended) [Apache runtime](#apache).

Only select this runtime if you have valid *technical* reasons to do so.
:::

Building a custom Pixelfed Docker image using nginx + FPM can be achieved the following way.

### docker build (Nginx)

```shell
docker build \
 -f Dockerfile \
 --target nginx-runtime \
 --build-arg 'PHP_BASE_TYPE=fpm' \
 --tag <docker hub user>/<docker hub repo> \
 .
```

### docker compose (Nginx)

:::info This is already configured if you use the default Pixelfed `docker-compose.yml`

Instead you control the target runtime via your `.env` file

```shell
DOCKER_APP_BASE_TYPE="fpm"
DOCKER_APP_RUNTIME="nginx"
```

:::

```yaml
version: "3"

services:
 app:
  build:
   context: .
   dockerfile: Dockerfile
   target: nginx-runtime
   args:
     PHP_BASE_TYPE: fpm
```

## FPM <Badge type="warning" text="Advanced" />

::: warning ADVANCED USAGE
The FPM runtime is for advanced users that want to run their PHP processes in a different container (or even server) from their webserver.

This is mostly used in horizontal scaling or advanced setups
:::

Building a custom Pixelfed Docker image using FPM (only) can be achieved the following way.

### docker build (FPM)

```shell
docker build \
 -f Dockerfile \
 --target fpm-runtime \
 --build-arg 'PHP_BASE_TYPE=fpm' \
 --tag <docker hub user>/<docker hub repo> \
 .
```

### docker compose (FPM)

:::info This is already configured if you use the default Pixelfed `docker-compose.yml`

Instead you control the target runtime via your `.env` file

```shell
DOCKER_APP_BASE_TYPE="fpm"
DOCKER_APP_RUNTIME="fpm"
```

:::

```yaml
version: "3"

services:
 app:
  build:
   context: .
   dockerfile: Dockerfile
   target: fpm-runtime
   args:
     PHP_BASE_TYPE: fpm
```
