# Check HTTPS Setup

## Current Status

✅ **server_name is correct**: `htaplus.com www.htaplus.com`
✅ **HTTP redirects to HTTPS**: Working (301 redirect)
⚠️ **certbot not installed**: But HTTPS is working somehow

## Possible Explanations

1. **SSL is handled by a proxy/CDN** (like Cloudflare)
2. **SSL was set up manually** (not using certbot)
3. **SSL is configured in a different way**

## Next Steps: Verify Your Site is Working

### 1. Test if Your Content is Being Served

```bash
# Check if your HTML content appears
curl -L https://htaplus.com | grep -i "HTA" | head -5

# Or see the full HTML (first 50 lines)
curl -L https://htaplus.com | head -50
```

**What to look for:**
- Should see "HTA Advisory" or "HTA+" in the output
- Should see your site's HTML structure

### 2. Check Nginx SSL Configuration

```bash
# See if there's SSL config in Nginx
sudo cat /etc/nginx/sites-available/hta-site | grep -A 10 "listen 443"

# Or see the full config
sudo cat /etc/nginx/sites-available/hta-site
```

### 3. Check if Using Cloudflare or Proxy

```bash
# Check DNS records (might show Cloudflare nameservers)
# This would be visible in your domain registrar's DNS settings
```

### 4. Test from Browser

**Most Important Test:**
1. Visit: `https://htaplus.com`
2. Check if you see your HTA+ website
3. Check browser address bar - does it show a padlock? 🔒
4. Click the padlock to see certificate details

### 5. Check Backend CORS

```bash
# Check current CORS settings
cat /home/bernardfatoye/HTAplus/hta-backend/.env | grep CORS_ORIGIN
```

**Should be:**
```
CORS_ORIGIN=https://htaplus.com,https://www.htaplus.com
```

**If it's different, update it:**
```bash
nano /home/bernardfatoye/HTAplus/hta-backend/.env
```

Change to:
```
CORS_ORIGIN=https://htaplus.com,https://www.htaplus.com
```

Then restart:
```bash
sudo systemctl restart hta-backend
```

### 6. Check Backend is Running

```bash
sudo systemctl status hta-backend
```

### 7. Test Contact Form

1. Visit `https://htaplus.com`
2. Scroll to contact form
3. Try submitting a test message
4. Check browser console (F12) for errors

## If Site Shows Wrong Content

### Check Nginx Root Directory

```bash
# Verify files are in the right place
ls -la /home/bernardfatoye/HTAplus/

# Check Nginx root setting
sudo cat /etc/nginx/sites-available/hta-site | grep root
```

Should show: `root /home/bernardfatoye/HTAplus;`

### Check File Permissions

```bash
sudo chmod -R 755 /home/bernardfatoye/HTAplus
```

### Check Nginx Logs

```bash
# Error logs
sudo tail -20 /var/log/nginx/error.log

# Access logs
sudo tail -20 /var/log/nginx/access.log
```

## If You Want to Set Up certbot (Optional)

If you want to manage SSL with certbot:

```bash
# Install certbot
sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d htaplus.com -d www.htaplus.com
```

**But if HTTPS is already working, you might not need this!**

## Quick Verification Checklist

Run these in order:

```bash
# 1. Test site content
curl -L https://htaplus.com | grep -i "HTA" | head -3

# 2. Check Nginx config
sudo cat /etc/nginx/sites-available/hta-site | grep -E "(server_name|root|listen)"

# 3. Check backend CORS
cat /home/bernardfatoye/HTAplus/hta-backend/.env | grep CORS

# 4. Check backend status
sudo systemctl status hta-backend

# 5. Test API endpoint
curl -X POST https://htaplus.com/api/contact -H "Content-Type: application/json" -d '{"name":"test","email":"test@test.com","message":"test"}'
```
