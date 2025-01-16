# FAQ

!!! info "If anything is confusing, unclear, missing, or maybe even wrong on this page, then *please* let us know [by submitting a bug report](https://github.com/jippi/docker-pixelfed/issues/new) :heart:"

## How do I use my own Proxy server?

No problem! All you have to do is:

1. Change the `DOCKER_PROXY_PROFILE` key/value pair in your `.env` file to `"disabled"`.
    * This disables the `proxy` *and* `proxy-acme` services in `compose.yaml`.
    * The setting is near the bottom of the file.
1. Point your proxy upstream to the exposed `web` port (**Default**: `8080`).
    * The port is controlled by the `DOCKER_WEB_PORT_EXTERNAL_HTTP` key in `.env`.
    * The setting is near the bottom of the file.
1. Run `docker compose up -d --remove-orphans` to apply the configuration

## How do I use my own SSL certificate?

No problem! All you have to do is:

1. Change the `DOCKER_PROXY_ACME_PROFILE` key/value pair in your `.env` file to `"disabled"`.
    * This disabled the `proxy-acme` service in `compose.yaml`.
    * It does *not* disable the `proxy` service.
1. Put your certificates in `${DOCKER_ALL_HOST_CONFIG_ROOT_PATH}/proxy/certs` (e.g. `./docker-compose/config/proxy/certs`)
    * You may need to create this folder manually if it does not exist.
    * The following files are expected to exist in the directory for the proxy to detect and use them automatically (this is the same directory and file names as LetsEncrypt uses)
        1. `${APP_DOMAIN}.cert.pem`
        1. `${APP_DOMAIN}.chain.pem`
        1. `${APP_DOMAIN}.fullchain.pem`
        1. `${APP_DOMAIN}.key.pem`
    * See the [`nginx-proxy` configuration file for name patterns](https://github.com/nginx-proxy/nginx-proxy/blob/main/nginx.tmpl#L659-L670)
1. Run `docker compose up -d --remove-orphans` to apply the configuration

## How do I change the container name prefix?

Change the `DOCKER_ALL_CONTAINER_NAME_PREFIX` key/value pair in your `.env` file.
