# Domain Setup Guide for htaplus.com

This guide will help you link your domain `htaplus.com` to your HTA+ website running on your Raspberry Pi.

## Overview

To link your domain, you need to:
1. **Configure DNS** - Point your domain to your Pi's IP address
2. **Update Nginx** - Configure Nginx to recognize your domain
3. **Update CORS** - Allow your domain in the backend
4. **Set up SSL** - Enable HTTPS for security (recommended)

---

## Step 1: Find Your Raspberry Pi's Public IP Address

**Important**: Your domain needs to point to your **public IP address** (the one your internet provider gives you), not your Pi's local IP (like 192.168.x.x).

**Understanding the difference:**
- **Local IP** (e.g., `192.168.1.100`): Only works on your home network
- **Public IP** (e.g., `203.0.113.45`): The address the whole internet sees

If you're on a home network, all your devices share the same public IP. That's normal!

Your domain needs to point to your Pi's IP address. Here are several methods:

### Option A: Find Your Public IP Address

Your public IP is the address that the internet sees. Here are several ways to find it:

**Method 1: Using curl (if installed)**
```bash
curl ifconfig.me
# or get just IPv4:
curl -4 ifconfig.me
# or get just IPv6:
curl -6 ifconfig.me
```

**Method 2: Using wget (if curl doesn't work)**
```bash
# Use the /ip endpoint to get just the IP, not HTML
wget -qO- ifconfig.me/ip
# or for IPv4 only:
wget -qO- -4 ifconfig.me/ip
```

**Method 3: Using a different service**
```bash
curl icanhazip.com
# or
curl ipinfo.io/ip
# or
curl api.ipify.org
# or
curl -4 icanhazip.com  # IPv4 only
```

**Method 4: Get both IPv4 and IPv6**
```bash
# IPv4 address (most common for domains)
curl -4 ifconfig.me

# IPv6 address (if your ISP provides it)
curl -6 ifconfig.me
```

**Method 4: From your router (Most Reliable)**

If the above commands don't work, check your router's admin page:
1. Log into your router (usually `192.168.1.1` or `192.168.0.1`)
2. Look for "Internet Status", "WAN IP", or "Public IP"
3. This is your public IP address

**Method 6: From another device**

Visit one of these websites from any device on your network:
- https://whatismyipaddress.com
- https://www.whatismyip.com
- https://ipinfo.io

**Write down your public IP:** `___________`

**Important Notes:**
- **IPv4 vs IPv6**: You might get an IPv6 address (looks like `2600:100d:...`) or IPv4 (looks like `203.0.113.45`). For most domain setups, you'll use IPv4 (A record). IPv6 uses AAAA records.
- **If you got an IPv6 address**: Try `curl -4 ifconfig.me` to get your IPv4 address instead.
- **Shared IP**: If you're on a home network, your Pi shares the same public IP as all devices on your network. This is normal!

### Option B: Dynamic DNS (If IP Changes)

If your IP changes frequently, you'll need a Dynamic DNS service. This is more advanced - we'll cover the basic setup first.

---

## Step 2: Configure DNS Records

You need to log into your domain registrar (where you bought `htaplus.com`) and add DNS records.

### What is DNS?
DNS (Domain Name System) is like a phone book for the internet. It translates `htaplus.com` into an IP address that computers can understand.

### DNS Records to Add

1. **A Record** (Main record - points domain to IP):
   - **Type**: A
   - **Name**: `@` or leave blank (this means the root domain)
   - **Value**: Your Pi's public IP address (from Step 1)
   - **TTL**: 3600 (or default)

2. **A Record for www** (Optional - for www.htaplus.com):
   - **Type**: A
   - **Name**: `www`
   - **Value**: Your Pi's public IP address (same as above)
   - **TTL**: 3600 (or default)

### Example DNS Configuration

**Example 1: IPv4 only** (if your IP is `203.0.113.45`):
```
Type | Name | Value        | TTL
-----|------|--------------|-----
A    | @    | 203.0.113.45 | 3600
A    | www  | 203.0.113.45 | 3600
```

**Example 2: IPv6 only** (if your IP is `2600:100d:a0ed:1bba:2ecf:67ff:fee6:a681`):
```
Type | Name | Value                                    | TTL
-----|------|------------------------------------------|-----
AAAA | @    | 2600:100d:a0ed:1bba:2ecf:67ff:fee6:a681 | 3600
AAAA | www  | 2600:100d:a0ed:1bba:2ecf:67ff:fee6:a681 | 3600
```

**Example 3: Both IPv4 and IPv6** (best compatibility):
```
Type | Name | Value                                    | TTL
-----|------|------------------------------------------|-----
A    | @    | 203.0.113.45                             | 3600
A    | www  | 203.0.113.45                             | 3600
AAAA | @    | 2600:100d:a0ed:1bba:2ecf:67ff:fee6:a681 | 3600
AAAA | www  | 2600:100d:a0ed:1bba:2ecf:67ff:fee6:a681 | 3600
```

### Where to Add DNS Records

Common domain registrars:
- **Namecheap**: Dashboard → Domain List → Manage → Advanced DNS
- **GoDaddy**: My Products → DNS → Manage Zones
- **Google Domains**: DNS → Custom Records
- **Cloudflare**: DNS → Records (if using Cloudflare)

### DNS Propagation

After adding DNS records, it can take **15 minutes to 48 hours** for changes to propagate worldwide. Usually it's much faster (15-30 minutes).

**Test if DNS is working:**
```bash
# On your Mac or Pi
nslookup htaplus.com
# or
dig htaplus.com
```

You should see your Pi's IP address in the response.

---

## Step 3: Update Nginx Configuration

Once DNS is working, update Nginx to recognize your domain.

**On your Pi**, edit the Nginx config:
```bash
sudo nano /etc/nginx/sites-available/hta-site
```

Update the `server_name` line from `_` to your domain:

```nginx
server {
    listen 80;
    server_name htaplus.com www.htaplus.com;  # Changed from "_"

    # Root directory for frontend files
    root /home/bernardfatoye/HTAplus;
    index index.html;

    # Serve static files (HTML, CSS, JS, images)
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Proxy API requests to backend
    location /api/ {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**Save and exit** (Ctrl+X, then Y, then Enter in nano).

**Test the configuration:**
```bash
sudo nginx -t
```

If it says "syntax is ok", restart Nginx:
```bash
sudo systemctl restart nginx
```

---

## Step 4: Update Backend CORS Settings

Your backend needs to allow requests from your domain.

**On your Pi**, edit the backend `.env` file:
```bash
nano /home/bernardfatoye/HTAplus/hta-backend/.env
```

Update the `CORS_ORIGIN` line:

```
EMAIL=your_email@gmail.com
PASS=your_app_password
CORS_ORIGIN=https://htaplus.com,https://www.htaplus.com
```

**Note**: We're using `https://` even though we haven't set up SSL yet. This prepares for Step 5.

**Save and exit**, then restart the backend:
```bash
sudo systemctl restart hta-backend
```

---

## Step 5: Set Up SSL/HTTPS (Highly Recommended)

SSL certificates enable HTTPS, which:
- Encrypts data between users and your site
- Shows a padlock icon in browsers (builds trust)
- Is required for many modern web features

We'll use **Let's Encrypt** (free SSL certificates).

### Install Certbot

**On your Pi:**
```bash
sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx
```

### Get SSL Certificate

**On your Pi:**
```bash
sudo certbot --nginx -d htaplus.com -d www.htaplus.com
```

Certbot will:
1. Ask for your email (for renewal notices)
2. Ask you to agree to terms
3. Ask if you want to share email (optional)
4. Automatically configure Nginx for HTTPS
5. Set up automatic renewal

### Verify SSL is Working

After Certbot finishes, visit:
- `https://htaplus.com`
- `https://www.htaplus.com`

You should see a padlock icon in your browser!

### Auto-Renewal

Certbot automatically sets up renewal. Test it:
```bash
sudo certbot renew --dry-run
```

---

## Step 6: Update CORS for HTTPS

Now that you have HTTPS, update your backend `.env`:

**On your Pi:**
```bash
nano /home/bernardfatoye/HTAplus/hta-backend/.env
```

Make sure it has:
```
CORS_ORIGIN=https://htaplus.com,https://www.htaplus.com
```

Restart backend:
```bash
sudo systemctl restart hta-backend
```

---

## Step 7: Test Everything

1. **Visit your site**: `https://htaplus.com`
2. **Test the contact form**: Fill it out and submit
3. **Check browser console**: Press F12 → Console tab, look for errors
4. **Test API directly**: `https://htaplus.com/api/contact` (should return an error for GET, which is expected)

---

## Troubleshooting

### Domain Not Loading

1. **Check DNS propagation:**
   ```bash
   # On Pi (if nslookup not installed):
   host htaplus.com
   # or
   ping -c 1 htaplus.com
   
   # On Mac:
   nslookup htaplus.com
   ```
   Should show your Pi's IP (`97.178.74.125`).

2. **Check Nginx is running:**
   ```bash
   sudo systemctl status nginx
   ```

3. **Check Nginx logs:**
   ```bash
   sudo tail -f /var/log/nginx/error.log
   ```

### CORS Errors

If you see CORS errors in the browser console:

1. **Check backend `.env`** has the correct domain
2. **Restart backend:**
   ```bash
   sudo systemctl restart hta-backend
   ```
3. **Check backend logs:**
   ```bash
   sudo journalctl -u hta-backend -f
   ```

### SSL Certificate Issues

1. **Check certificate:**
   ```bash
   sudo certbot certificates
   ```

2. **Renew manually if needed:**
   ```bash
   sudo certbot renew
   ```

3. **Check Nginx SSL config:**
   ```bash
   sudo nginx -t
   ```

### Port Forwarding (If Behind Router)

If your Pi is behind a router, you need to forward ports:

1. **Port 80** (HTTP) → Your Pi's local IP
2. **Port 443** (HTTPS) → Your Pi's local IP

**On your router admin panel:**
- Find "Port Forwarding" or "Virtual Server"
- Add rules:
  - External Port: 80 → Internal IP: `192.168.x.x` (Pi's local IP) → Internal Port: 80
  - External Port: 443 → Internal IP: `192.168.x.x` → Internal Port: 443

---

## Summary Checklist

- [ ] Found Pi's public IP address
- [ ] Added A records in DNS (htaplus.com and www.htaplus.com)
- [ ] Waited for DNS propagation (checked with nslookup)
- [ ] Updated Nginx server_name to htaplus.com
- [ ] Updated backend CORS_ORIGIN in .env
- [ ] Restarted Nginx and backend
- [ ] Installed Certbot
- [ ] Obtained SSL certificate
- [ ] Tested site at https://htaplus.com
- [ ] Tested contact form
- [ ] Set up port forwarding (if needed)

---

## Next Steps

Once your domain is working:
- Consider setting up email forwarding (e.g., hello@htaplus.com)
- Monitor your site's uptime
- Set up backups
- Consider using Cloudflare for additional security and performance

---

## Need Help?

If you encounter issues:
1. Check the troubleshooting section above
2. Review Nginx logs: `sudo tail -f /var/log/nginx/error.log`
3. Review backend logs: `sudo journalctl -u hta-backend -f`
4. Test DNS: `nslookup htaplus.com`
5. Test connectivity: `curl -I https://htaplus.com`
