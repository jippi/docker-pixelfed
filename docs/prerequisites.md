# Pixelfed + Docker Prerequisites

::: tip If anything is confusing, unclear, missing, or maybe even wrong on this page, then *please* let us know [by submitting a bug report](https://github.com/pixelfed/pixelfed/issues/new) :heart:
:::

This guide will help you install and run Pixelfed on **your** server using [Docker Compose](https://docs.docker.com/compose/).

Recommendations and requirements for hardware and software needed to run Pixelfed using Docker Compose.

You should have *some* experience with Linux (e.g., Ubuntu or Debian), SSH, and lightweight server administration.

## Server

A Virtual Private Server (VPS) or Dedicated Server (also known as `root server`) you can SSH into, for example:

* [linode.com VPS](https://www.linode.com/)
* [DigitalOcean VPS](https://digitalocean.com/)
* [Hetzner](https://www.hetzner.com/)

### Hardware

Hardware requirements depend on the number of users you have (or plan to have) and how active they are.

A safe starter/small instance hardware for ~25 users and below are:

* **CPU/vCPU** `2` cores.
* **RAM** `2-4 GB` As your instance grows, memory requirements will increase for the database.
* **Storage** `20-50 GB` HDD is fine, but ideally, SSD or NVMe, *especially* for the database.
* **Network** `100 Mbit/s` or faster.

### Software

Required software to be installed on your server

* `git` can be installed with `apt-get install git` on Debian/Ubuntu
* `docker` can be installed by [following the official Docker documentation](https://docs.docker.com/engine/install/)

### Network

* Port `80` (HTTP) and `443` (HTTPS) ports forwarded to the server.
  * Example for Ubuntu using [`ufw`](https://help.ubuntu.com/community/UFW) for port `80`: `ufw allow 80`
  * Example for Ubuntu using [`ufw`](https://help.ubuntu.com/community/UFW) for port `443`: `ufw allow 443`

## Domain and DNS

* A **Domain** (or subdomain) is needed for the Pixelfed server (for example, `pixelfed.social` or `pixelfed.mydomain.com`)
* Having the required `A`/`CNAME` DNS records for your domain (above) pointing to your server.
  * Typically, an `A` record for the root (sometimes shown as `@`) record for `mydomain.com`
  * Possibly an `A` record for `www.` subdomain.

## SMTP provider (Optional)

::: info What is this?
An **E-mail/SMTP provider** is used for sending e-mails to your users, such as e-mail confirmation and notifications.
:::

::: warning
If you don't plan to use an e-mail/SMTP provider, then make sure to set `ENFORCE_EMAIL_VERIFICATION="false"` in your `.env` file!
:::

There are *many* providers out there with wildly different pricing structures, features, and reliability.

It's beyond the scope of this document to detail which provider to pick or how to correctly configure them. Still, some providers that are known to be working well - with generous free tiers and affordable packages - are included for your convince (*in no particular order*) below:

* [Simple Email Service (SES)](https://aws.amazon.com/ses/) by Amazon Web Services (AWS) is pay-as-you-go with a cost of $0.10/1000 emails.
* [Brevo](https://www.brevo.com/) (formerly SendInBlue) has a Free Tier with 300 e-mails/day.
* [Postmark](https://postmarkapp.com/) has a Free Tier with 100 e-mails/month.
* [Forward Email](https://forwardemail.net/en/private-business-email?pricing=true) has a $3/mo/domain plan with both sending and receiving included.
* [Mailtrap](https://mailtrap.io/email-sending/) has a 1000 e-mails/month free tier (their `E-mail Sending` product, *not* the `E-mail Testing` one).

## Object Storage (Optional)

::: info What is this?
An **Object Storage** provider stores all media content remotely rather than locally on your server. It's *often* cheaper to use an Object Storage service than to have media files stored directly on the HDD, ***especially*** for medium to large data volumes.
:::

::: tip
This is *entirely* optional - by default, Pixelfed will store all uploads (videos, images, etc.) directly on your servers' storage.
:::

> Object storage is a technology that stores and manages data in an unstructured format called objects. Modern organizations create and analyze large volumes of unstructured data such as photos, videos, e-mail, web pages, sensor data, and audio files.
>
> -- [*What is object storage?*](https://aws.amazon.com/what-is/object-storage/) by Amazon Web Services

It's beyond the scope of this document to detail which provider to pick or how to correctly configure them. Still, some providers that are known to be working well - with generous free tiers and affordable packages - are included for your convince (*in no particular order*) below:

* [R2](https://www.cloudflare.com/developer-platform/r2/) by Cloudflare has cheap storage, free *egress* (e.g., people downloading images), and included (and free) Content Delivery Network (CDN).
* [B2 cloud storage](https://www.backblaze.com/cloud-storage) by Backblaze.
* [Simple Storage Service (S3)](https://aws.amazon.com/s3/) by Amazon Web Services.
