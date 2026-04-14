# api.htaplus.com Setup (Pi backend behind GitHub Pages frontend)

**Goal:** keep the static site on GitHub Pages (fast, reliable, free) while
exposing the Pi's Node/Express backend at `https://api.htaplus.com/contact`
so the contact form can reach it.

Before you start, confirm:

1. Your home public IP. Run this on the Pi or any machine at home:
   ```bash
   curl -s https://api.ipify.org; echo
   ```
   If it's still `97.178.74.125`, the DNS record in `YOUR_DNS_RECORDS.md`
   is still valid. If it's changed, use the new one — and consider a
   Dynamic DNS service (e.g., Cloudflare + a cron that updates the
   record) so this doesn't bite you again.

2. Port forwarding on your router. Ports **80** and **443** must forward
   to the Pi's LAN IP. You can verify with:
   ```bash
   curl -I http://<your-public-ip>
   ```
   If you get a response, forwarding is fine.

3. The backend is running on the Pi:
   ```bash
   sudo systemctl status hta-backend
   curl http://localhost:3000/api/health
   ```

---

## Step 1 — DNS

At your DNS provider (where you manage htaplus.com), add an A record:

```
Type: A
Name: api
Value: <your-home-public-IP>    # e.g., 97.178.74.125
TTL: 3600
```

Wait a few minutes, then verify:

```bash
dig +short api.htaplus.com
```

Should return your public IP. DNS propagation is usually fast (< 5 min)
but can take up to an hour.

---

## Step 2 — Nginx server block for api.htaplus.com

SSH into the Pi and create a new site config:

```bash
sudo tee /etc/nginx/sites-available/api-htaplus > /dev/null << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name api.htaplus.com;

    # Let certbot validate via HTTP-01 before SSL is issued
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name api.htaplus.com;

    # Certs populated by certbot in Step 3
    ssl_certificate /etc/letsencrypt/live/api.htaplus.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.htaplus.com/privkey.pem;

    # Proxy everything to the Node backend on localhost:3000
    location / {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/api-htaplus /etc/nginx/sites-enabled/api-htaplus
```

**Important:** if Nginx complains about the `ssl_certificate` files not
existing, comment out the whole `server { listen 443 ... }` block
temporarily, reload Nginx, then run certbot (Step 3), then uncomment
and reload again. Certbot can often do this automatically if you use
`--nginx` — see Step 3.

---

## Step 3 — SSL cert with Let's Encrypt

```bash
# If certbot isn't installed yet
sudo apt-get install -y certbot python3-certbot-nginx

# Issue and auto-configure cert for the subdomain
sudo certbot --nginx -d api.htaplus.com

# Test the renewal hook
sudo certbot renew --dry-run
```

Certbot should rewrite the Nginx config to point to the new cert paths
and reload Nginx automatically.

---

## Step 4 — Verify from the open internet

From your phone on cellular data (NOT on your home wifi — that defeats
the test):

```
https://api.htaplus.com/api/health
```

Should return `{"status":"ok","timestamp":"..."}`.

If it hangs or fails:
- Check `sudo nginx -t` for config errors
- Check `sudo tail -f /var/log/nginx/error.log` while making the request
- Check `sudo journalctl -u hta-backend -f` to see if Node is receiving traffic

---

## Step 5 — Backend CORS

The `.env` file should already include `https://htaplus.com` and
`https://www.htaplus.com` in `CORS_ORIGIN`. Verify:

```bash
cat /home/bernardfatoye/HTAplus/hta-backend/.env
```

If you need to change it, restart the backend:

```bash
sudo systemctl restart hta-backend
```

---

## Step 6 — Push the frontend change

The form in `index.html` now posts to `https://api.htaplus.com/contact`
(both `data-endpoint` and `action` are set). The script.js version query
string is bumped to bust caches.

From your Mac:

```bash
cd ~/HTAplus         # or wherever you keep this repo
git add index.html
git commit -m "Point contact form at api.htaplus.com"
git push
```

GitHub Pages will redeploy in ~30 seconds. Visit https://htaplus.com in
an incognito window and submit the form.

---

## Troubleshooting checklist

If the form still fails after all of the above:

- Open DevTools → Network tab, submit the form, look at the POST to
  `api.htaplus.com/contact`. The status code and response body tell
  you exactly where it's failing.
- `CORS error` in console → CORS_ORIGIN isn't matching; double-check the
  origin you're coming from (watch for `www.` vs apex).
- `net::ERR_NAME_NOT_RESOLVED` → DNS hasn't propagated yet.
- `net::ERR_CONNECTION_REFUSED` / timeout → port forwarding, firewall,
  or Pi is down.
- `502 Bad Gateway` → Nginx is up but Node isn't running; check the
  service.
- `500` with `{"error": "Failed to send message..."}` → Gmail SMTP
  issue (app password expired, or 2FA/security settings changed).
