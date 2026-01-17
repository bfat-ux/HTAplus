# Fix SSL Certificate Issue

## Problem
You're getting: `SSL certificate problem: self-signed certificate in certificate chain`

This means your site is using a self-signed certificate (not trusted by browsers/curl).

## Quick Test (Bypass SSL for Testing)

```bash
# Test with SSL verification disabled (just to see if content is there)
curl -k -L https://htaplus.com | grep -i "HTA" | head -5
```

The `-k` flag tells curl to ignore certificate errors (for testing only).

## Check Current SSL Configuration

```bash
# See full Nginx config
sudo cat /etc/nginx/sites-available/hta-site

# Check for SSL certificate paths
sudo cat /etc/nginx/sites-available/hta-site | grep -E "(ssl_certificate|listen 443)"
```

## Solution: Set Up Proper SSL with Let's Encrypt

### Step 1: Install Certbot

```bash
sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx
```

### Step 2: Get SSL Certificate

```bash
sudo certbot --nginx -d htaplus.com -d www.htaplus.com
```

Certbot will:
1. Ask for your email (for renewal notices)
2. Ask you to agree to terms
3. Automatically configure Nginx for HTTPS
4. Set up automatic renewal

### Step 3: Verify It Works

```bash
# Test without -k flag (should work now)
curl -L https://htaplus.com | grep -i "HTA" | head -5

# Check certificate
sudo certbot certificates
```

### Step 4: Test Auto-Renewal

```bash
# Test renewal process (dry run)
sudo certbot renew --dry-run
```

## Alternative: If Certbot Fails

If certbot has issues, you might need to:

1. **Temporarily disable SSL redirect** to get certificate:
   ```bash
   sudo nano /etc/nginx/sites-available/hta-site
   ```
   Comment out or remove the SSL redirect, then:
   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   ```

2. **Run certbot again**
3. **Re-enable redirect**

## Check What's Currently Serving HTTPS

```bash
# Check if there's another service handling SSL
sudo netstat -tlnp | grep :443

# Check Nginx error logs
sudo tail -20 /var/log/nginx/error.log
```

## After Setting Up Let's Encrypt

1. **Update backend CORS** (if not done):
   ```bash
   nano /home/bernardfatoye/HTAplus/hta-backend/.env
   ```
   Set: `CORS_ORIGIN=https://htaplus.com,https://www.htaplus.com`

2. **Restart backend:**
   ```bash
   sudo systemctl restart hta-backend
   ```

3. **Test in browser:**
   - Visit: `https://htaplus.com`
   - Should show padlock icon 🔒
   - Should show your HTA+ website

## Troubleshooting

### Port 80/443 Not Accessible

If certbot fails with "connection refused", check:
- Port forwarding on router (ports 80 and 443)
- Firewall settings
- Nginx is listening on port 80

### Certificate Already Exists

If you get "certificate already exists", you can:
- View existing: `sudo certbot certificates`
- Renew: `sudo certbot renew`
- Or delete and recreate: `sudo certbot delete --cert-name htaplus.com`
