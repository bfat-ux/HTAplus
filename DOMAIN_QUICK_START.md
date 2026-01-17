# Quick Start: Link htaplus.com Domain

## Quick Checklist (5 Steps)

### 1. Get Your Pi's Public IP

Run this to get your IPv4 address (needed for DNS):
```bash
curl -4 ifconfig.me
```

**Your IPv4 address:** `97.178.74.125` ← Use this for DNS A record

(You also have IPv6: `2600:100d:a0ed:1bba:2ecf:67ff:fee6:a681` - optional)

### 2. Configure DNS (At Your Domain Registrar)

Add these DNS records:
- **Type**: A | **Name**: `@` | **Value**: `[Your Pi IP]`
- **Type**: A | **Name**: `www` | **Value**: `[Your Pi IP]`

**Wait 15-30 minutes** for DNS to propagate.

**Test DNS (on your Pi):**
```bash
host htaplus.com
# or
ping -c 1 htaplus.com
```
Should show: `97.178.74.125`

### 3. Update Nginx (On Your Pi)

```bash
sudo nano /etc/nginx/sites-available/hta-site
```

Change line 16 to:
```nginx
server_name htaplus.com www.htaplus.com;
```

Then:
```bash
sudo nginx -t
sudo systemctl restart nginx
```

### 4. Update Backend CORS (On Your Pi)

```bash
nano /home/bernardfatoye/HTAplus/hta-backend/.env
```

Update to:
```
CORS_ORIGIN=https://htaplus.com,https://www.htaplus.com
```

Then:
```bash
sudo systemctl restart hta-backend
```

### 5. Set Up SSL (On Your Pi)

```bash
sudo apt-get install -y certbot python3-certbot-nginx
sudo certbot --nginx -d htaplus.com -d www.htaplus.com
```

**Done!** Visit `https://htaplus.com`

---

## Test DNS is Working

```bash
nslookup htaplus.com
```

Should show your Pi's IP address.

---

## Full Guide

See `DOMAIN_SETUP.md` for detailed explanations and troubleshooting.
