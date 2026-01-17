# Check Domain Status - htaplus.com

## ✅ DNS Status: WORKING!

Your domain is correctly pointing to your IP:
- **Domain**: htaplus.com
- **IP Address**: 97.178.74.125 ✓

## Current Status

From your test, `curl -I http://htaplus.com` shows:
```
HTTP/1.1 301 Moved Permanently
Location: https://htaplus.com/
```

This means:
- ✅ DNS is working
- ✅ Domain is reachable
- ⚠️ HTTP is redirecting to HTTPS (SSL might already be set up, or needs to be configured)

## Next Steps: Verify Your Setup

### 1. Check if SSL is Already Configured

**On your Pi**, run:
```bash
# Check if certbot/SSL is installed
which certbot

# Check SSL certificate status
sudo certbot certificates

# Check Nginx SSL configuration
sudo cat /etc/nginx/sites-available/hta-site | grep -A 5 "listen 443"
```

### 2. Check Nginx Configuration

**On your Pi**, verify Nginx is configured for your domain:
```bash
# View current Nginx config
sudo cat /etc/nginx/sites-available/hta-site

# Check if it's enabled
ls -la /etc/nginx/sites-enabled/

# Test Nginx config
sudo nginx -t
```

### 3. Test Your Site

**From your Mac or Pi:**
```bash
# Test HTTP (should redirect or show site)
curl -L http://htaplus.com

# Test HTTPS (if SSL is set up)
curl -L https://htaplus.com

# Test from browser
# Visit: https://htaplus.com
```

### 4. Check Backend CORS

**On your Pi**, verify backend allows your domain:
```bash
cat /home/bernardfatoye/HTAplus/hta-backend/.env | grep CORS_ORIGIN
```

Should show:
```
CORS_ORIGIN=https://htaplus.com,https://www.htaplus.com
```

### 5. Check Port Forwarding

Make sure your router is forwarding:
- Port 80 (HTTP) → Your Pi's local IP → Port 80
- Port 443 (HTTPS) → Your Pi's local IP → Port 443

**Find your Pi's local IP:**
```bash
hostname -I
```

## What to Do Next

### If SSL is NOT set up:

1. **Install Certbot:**
   ```bash
   sudo apt-get update
   sudo apt-get install -y certbot python3-certbot-nginx
   ```

2. **Get SSL certificate:**
   ```bash
   sudo certbot --nginx -d htaplus.com -d www.htaplus.com
   ```

3. **Update backend CORS** (if not done):
   ```bash
   nano /home/bernardfatoye/HTAplus/hta-backend/.env
   ```
   Set: `CORS_ORIGIN=https://htaplus.com,https://www.htaplus.com`

4. **Restart services:**
   ```bash
   sudo systemctl restart nginx
   sudo systemctl restart hta-backend
   ```

### If SSL IS already set up:

1. **Verify Nginx config** has your domain name
2. **Update backend CORS** to use HTTPS
3. **Test the contact form** on your site
4. **Check browser console** for any errors

## Quick Test Commands

**On your Pi:**
```bash
# Check if site is serving your content
curl -L http://htaplus.com | head -20

# Check backend is running
sudo systemctl status hta-backend

# Check Nginx is running
sudo systemctl status nginx

# Check Nginx logs for errors
sudo tail -20 /var/log/nginx/error.log
```

## Troubleshooting

### Site shows default page or wrong content:
- Check Nginx `root` directory points to `/home/bernardfatoye/HTAplus`
- Verify files are in the right location: `ls -la /home/bernardfatoye/HTAplus/`

### HTTPS shows certificate error:
- SSL might not be properly configured
- Run: `sudo certbot --nginx -d htaplus.com -d www.htaplus.com`

### Contact form doesn't work:
- Check backend CORS settings
- Check backend is running: `sudo systemctl status hta-backend`
- Check backend logs: `sudo journalctl -u hta-backend -f`
