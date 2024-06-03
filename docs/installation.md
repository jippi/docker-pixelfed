# Pixelfed + Docker installtion

::: tip If anything is confusing, unclear, missing, or maybe even wrong on this page, then *please* let us know [by submitting a bug report](https://github.com/pixelfed/pixelfed/issues/new) :heart:
:::

Connect via SSH to your server and decide where you want to install Pixelfed.

::: info
In this guide, I will assume you will install Pixelfed in `/data/pixelfed` and that the [Docker Prerequisites](prerequisites.md) are met.

You can change the installation path; update the commands below to fit your setup.
:::

## Initial set up

### Create the directory

```bash
mkdir -p /data
```

### Clone the Pixelfed project

```bash
git clone \
    --branch jippi-fork \
    https://github.com/jippi/pixelfed.git \
    /data/pixelfed
```

### Change directory

```bash
cd /data/pixelfed
```

## Configuring your site

### Copy the example file

Pixelfed contains a default configuration file (`.env.docker`) you should use as a starter; however, before editing anything, make a copy of it and put it in the *right* place (`.env`).

Run the following command to copy the file:

```bash
cp .env.docker .env
```

### Modify config file

The configuration file is *quite* long, but the good news is that you can ignore *most* of it; most of the *server-specific* settings are configured for you out of the box.

The minimum required settings you **must** change is:

* (required) `APP_DOMAIN`, which is the hostname you plan to run your Pixelfed server on (e.g., `pixelfed.social`) - must **not** include `http://` or a trailing slash (`/`)!
* (required) `DB_PASSWORD`, which is the database password; you can use a service like [pwgen.io](https://pwgen.io/en/) to generate a secure one.
* (optional) `ENFORCE_EMAIL_VERIFICATION` should be set to `"false"` if you don't plan to send e-mails.
* (optional) `MAIL_DRIVER` and related `MAIL_*` settings if you plan to use an [E-mail/SMTP provider](prerequisites.md#smtp-provider-optional) - See [E-mail variables documentation](https://docs.pixelfed.org/running-pixelfed/installation/#email-variables).
* (optional) `PF_ENABLE_CLOUD` / `FILESYSTEM_CLOUD` if you plan to use an [Object Storage provider](prerequisites.md#object-storage-optional).

See the [`Configure environment variables`](https://docs.pixelfed.org/running-pixelfed/installation/#app-variables) documentation for details!

You need to mainly focus on the following sections.

* [App variables](https://docs.pixelfed.org/running-pixelfed/installation/#app-variables)
* [Email variables](https://docs.pixelfed.org/running-pixelfed/installation/#email-variables)

You can skip the following sections since they are already configured/automated for you:

* `Redis`
* `Database` (except for `DB_PASSWORD`)
* `One-time setup tasks`

### Starting the service

With everything in place and (hopefully) well-configured, we can now go ahead and start our services by running:

```shell
docker compose up -d
```

This will download all the required Docker images, start the containers, and begin the automatic setup.

You can follow the logs by running `docker compose logs` - you might want to scroll to the top to logs from the start.

You can use the CLI flag `--tail=100` to only see each container's most recent (`100` in this example) log lines.

You can use the CLI flag `--follow` to continue to see log output from the containers.

You can combine `--tail=100` and `--follow` like this `docker compose logs --tail=100 --follow`.

If you only care about specific containers, you can add them to the end of the command like this `docker-compose logs web worker proxy.`

### Done

You made it to the end of the installation tutorial and *hopefully* you have fully functional Pixelfed instance.

We recommend your next steps is to [check out how to customize your Pixelfed instance](customize.md)

::: tip If anything was confusing, unclear, or maybe even wrong on this page, then *please* let us know [by submitting a bug report](https://github.com/pixelfed/pixelfed/issues/new) :heart:
:::
