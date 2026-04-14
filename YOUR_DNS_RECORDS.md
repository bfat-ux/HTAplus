# DNS Records for htaplus.com

> **Updated April 14, 2026.** The site architecture changed: the static
> site now lives on GitHub Pages, and only the backend API runs on the
> Pi at `api.htaplus.com`. The old instructions below (pointing the
> whole domain at the Pi) are no longer how things are set up.

## Current layout

| Record        | Name  | Value                                   | Purpose |
|---------------|-------|-----------------------------------------|---------|
| A             | `@`   | `185.199.108.153`                       | GitHub Pages |
| A             | `@`   | `185.199.109.153`                       | GitHub Pages |
| A             | `@`   | `185.199.110.153`                       | GitHub Pages |
| A             | `@`   | `185.199.111.153`                       | GitHub Pages |
| CNAME         | `www` | `bfat-ux.github.io.`                    | GitHub Pages |
| A             | `api` | `<current home public IP>`              | Pi backend |
| NS / SOA / MX | —     | (managed by GoDaddy / Google Workspace) | leave alone |

The `api` A record is the only one that needs to track your home IP.
See `hta-backend/ddns/SETUP.md` for the auto-updater that keeps that
record in sync whenever your residential IP rotates.

## If you ever need to recover the api record manually

1. Find the Pi's current public IP:
   ```bash
   curl -s https://api.ipify.org
   ```
2. In GoDaddy DNS management for htaplus.com, edit the `A | api`
   record and set its Data to that IP.
3. Propagation is usually < 5 min.

## Historical notes (for reference only)

Before Feb 2026 the whole site was served from the Pi at a single
public IP (at one point `97.178.74.125`, later `97.178.1.154`, now
`97.178.110.128`, and it will keep changing — which is exactly why the
DDNS updater exists). The original Nginx + certbot setup docs are in
`hta-backend/NGINX_SETUP.md`; they still work if you ever want to
serve the static site from the Pi again, but you'd also need to move
DNS for `@` and `www` away from GitHub Pages.

## Port forwarding reminder

For `api.htaplus.com` to be reachable from the open internet, your
home router must forward **port 80** and **port 443** to the Pi's LAN
IP. This was set up once; it doesn't normally need touching, but if
you ever swap routers, this is the first thing to re-do.
