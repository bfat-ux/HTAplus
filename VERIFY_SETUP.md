# Verify Your Domain Setup

## Current Status

✅ **Nginx is running** - Good!
✅ **Domain is redirecting HTTP to HTTPS** - SSL appears to be configured
✅ **DNS is working** - Domain points to correct IP

## Next: Verify Everything is Working

### 1. Check server_name was updated

```bash
sudo cat /etc/nginx/sites-available/hta-site | grep server_name
```

Should show: `server_name htaplus.com www.htaplus.com;`

### 2. Check SSL Certificate Status

```bash
sudo certbot certificates
```

This will show if SSL certificates are installed for htaplus.com

### 3. Test HTTPS Site (Most Important!)

```bash
# Test if your site content is being served
curl -L https://htaplus.com | head -30
```

This should show your HTML content (the HTA+ website), not a default page.

### 4. Check Backend CORS

```bash
cat /home/bernardfatoye/HTAplus/hta-backend/.env | grep CORS_ORIGIN
```

Should show:
```
CORS_ORIGIN=https://htaplus.com,https://www.htaplus.com
```

### 5. Test from Browser

**Visit in your browser:**
- `https://htaplus.com`

**What to check:**
- Does it show your HTA+ website?
- Does the contact form work?
- Check browser console (F12) for any errors

### 6. Check Nginx is Serving Your Files

```bash
# Verify your files are in the right place
ls -la /home/bernardfatoye/HTAplus/

# Should see: index.html, script.js, styles.css, hta-backend/
```

### 7. Check Nginx Root Directory

```bash
sudo cat /etc/nginx/sites-available/hta-site | grep root
```

Should show: `root /home/bernardfatoye/HTAplus;`

## If Site Shows Wrong Content

### Check Nginx Config

```bash
# View full config
sudo cat /etc/nginx/sites-available/hta-site
```

### Check Nginx Logs

```bash
# Check for errors
sudo tail -20 /var/log/nginx/error.log

# Check access logs
sudo tail -20 /var/log/nginx/access.log
```

### Verify File Permissions

```bash
# Make sure Nginx can read your files
sudo chmod -R 755 /home/bernardfatoye/HTAplus
```

## If Contact Form Doesn't Work

### Check Backend is Running

```bash
sudo systemctl status hta-backend
```

### Check Backend Logs

```bash
sudo journalctl -u hta-backend -n 50
```

### Update CORS if Needed

```bash
nano /home/bernardfatoye/HTAplus/hta-backend/.env
```

Make sure it has:
```
CORS_ORIGIN=https://htaplus.com,https://www.htaplus.com
```

Then restart:
```bash
sudo systemctl restart hta-backend
```

## Quick Test Checklist

Run these commands to verify everything:

```bash
# 1. Check server_name
sudo cat /etc/nginx/sites-available/hta-site | grep server_name

# 2. Check SSL
sudo certbot certificates

# 3. Test HTTPS site content
curl -L https://htaplus.com | grep -i "HTA" | head -5

# 4. Check backend CORS
cat /home/bernardfatoye/HTAplus/hta-backend/.env | grep CORS

# 5. Check backend status
sudo systemctl status hta-backend
```
