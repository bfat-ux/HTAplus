# Fix Nginx Domain Configuration

## Problem
Your Nginx config has `server_name _;` but it should have `server_name htaplus.com www.htaplus.com;`

## Solution: Update Nginx Config

**On your Pi**, run these commands:

### Option 1: Edit with nano (Recommended for beginners)

```bash
# Open the config file
sudo nano /etc/nginx/sites-available/hta-site
```

**Find this line:**
```
server_name _;
```

**Change it to:**
```
server_name htaplus.com www.htaplus.com;
```

**Save and exit:**
- Press `Ctrl + X`
- Press `Y` to confirm
- Press `Enter` to save

### Option 2: Use sed (Quick one-liner)

```bash
sudo sed -i 's/server_name _;/server_name htaplus.com www.htaplus.com;/' /etc/nginx/sites-available/hta-site
```

## Verify the Change

```bash
# Check the server_name line
sudo cat /etc/nginx/sites-available/hta-site | grep server_name
```

Should now show:
```
server_name htaplus.com www.htaplus.com;
```

## Test and Restart Nginx

```bash
# Test the configuration (check for errors)
sudo nginx -t
```

If it says "syntax is ok", restart Nginx:

```bash
sudo systemctl restart nginx
```

## Verify It's Working

```bash
# Check Nginx status
sudo systemctl status nginx

# Test your site
curl -I http://htaplus.com
```

You should now see your site content instead of a default page!
