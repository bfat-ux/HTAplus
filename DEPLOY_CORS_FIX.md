# Deploy CORS Fix to Pi - Quick Steps

## Step 1: Transfer Updated Backend Code to Pi

**On your Mac**, open Terminal and run:

```bash
# Replace 192.168.1.154 with your actual Pi IP (or use the IP from your transfer-command.sh)
scp "/Users/berna/HTA Project/hta-backend/index.js" bernardfatoye@192.168.1.154:/home/bernardfatoye/HTAplus/hta-backend/
```

Or if you want to transfer everything:
```bash
rsync -avz --progress "/Users/berna/HTA Project/hta-backend/" bernardfatoye@192.168.1.154:/home/bernardfatoye/HTAplus/hta-backend/
```

## Step 2: On Your Pi - Check and Update .env File

**On your Pi terminal**, run:

```bash
cd /home/bernardfatoye/HTAplus/hta-backend
nano .env
```

Make sure it has (update with your actual domain):
```
EMAIL=your_email@gmail.com
PASS=your_app_password
CORS_ORIGIN=https://htaplus.com,https://www.htaplus.com
```

**Important:** Since you're using `htaplus.com`, use `https://` (not `http://`) if you have SSL set up.

If you don't have SSL yet, use:
```
CORS_ORIGIN=http://htaplus.com,http://www.htaplus.com
```

Save and exit: `Ctrl+X`, then `Y`, then `Enter`

## Step 3: Restart Backend Service

```bash
sudo systemctl restart hta-backend
```

## Step 4: Check Backend Logs

```bash
sudo journalctl -u hta-backend -f
```

Look for any CORS error messages. If you see "CORS blocked origin: ...", that tells us what origin needs to be added.

## Step 5: Test the Form

Try submitting the contact form again on your website.
