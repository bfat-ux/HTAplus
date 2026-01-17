# Fix CORS Issue - Step by Step Guide

## What We're Doing
We need to update your nginx configuration file on your Pi 5 to fix the CORS blocking issue.

## Step 1: Connect to Your Pi 5
Open your terminal and SSH into your Pi 5 (if you're not already there):
```bash
ssh bernardfatoye@YOUR_PI_IP
```

## Step 2: Edit the Nginx Config File
Open the nginx config file in a text editor:
```bash
sudo nano /etc/nginx/sites-available/hta-site
```

## Step 3: Find and Update the Proxy Line
Look for this section in the file:
```
location /api/ {
    proxy_pass http://localhost:3000/;
    ...
}
```

**Change it to:**
```
location /api/ {
    proxy_pass http://localhost:3000/api/;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Origin $scheme://$host;
}
```

**What changed:**
- Changed `proxy_pass http://localhost:3000/;` to `proxy_pass http://localhost:3000/api/;`
- Added the line `proxy_set_header Origin $scheme://$host;`

## Step 4: Save and Exit
- Press `Ctrl + X` to exit
- Press `Y` to confirm saving
- Press `Enter` to confirm the filename

## Step 5: Test the Config
Make sure there are no errors:
```bash
sudo nginx -t
```

You should see: `nginx: configuration file /etc/nginx/nginx.conf test is successful`

## Step 6: Restart Nginx
```bash
sudo systemctl restart nginx
```

## Step 7: Restart Your Backend
```bash
sudo systemctl restart hta-backend
```

## Step 8: Test It!
Try submitting the contact form on your website. It should work now!

## If Something Goes Wrong

**Check nginx logs:**
```bash
sudo tail -f /var/log/nginx/error.log
```

**Check backend logs:**
```bash
sudo journalctl -u hta-backend -f
```

**If nginx test fails**, go back to step 2 and double-check your changes.
