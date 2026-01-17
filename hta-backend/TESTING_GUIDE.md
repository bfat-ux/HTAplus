# Testing Guide for Raspberry Pi Deployment

This guide will help you test your HTA Advisory website on your Raspberry Pi.

## Prerequisites Checklist

Before testing, make sure you have:

- [ ] Node.js installed on your Pi (`node --version`)
- [ ] npm installed (`npm --version`)
- [ ] All dependencies installed (`npm install` in `hta-backend/` directory)
- [ ] `.env` file created with your email credentials
- [ ] Your Pi's IP address (run `hostname -I` to find it)

## Step 1: Transfer Files to Pi

If you haven't already, transfer your project files to your Pi:

```bash
# From your Mac, use scp or rsync
scp -r /Users/berna/HTA\ Project/* bernardfatoye@YOUR_PI_IP:/home/bernardfatoye/HTAplus/
```

Or use git if you have a repository:
```bash
# On your Pi
cd /home/bernardfatoye
git clone YOUR_REPO_URL HTAplus
```

## Step 2: Install Dependencies

On your Pi:

```bash
cd /home/bernardfatoye/HTAplus/hta-backend
npm install
```

## Step 3: Set Up Environment Variables

Create the `.env` file:

```bash
cd /home/bernardfatoye/HTAplus/hta-backend
nano .env
```

Add your credentials (replace with your actual values):
```
EMAIL=your_email@gmail.com
PASS=your_gmail_app_password
CORS_ORIGIN=http://YOUR_PI_IP
```

**Important:** Replace `YOUR_PI_IP` with your actual Pi IP address (e.g., `http://192.168.1.100`)

## Step 4: Test Backend Manually (Before Service Setup)

First, let's test if the backend runs correctly:

```bash
cd /home/bernardfatoye/HTAplus/hta-backend
node index.js
```

You should see: `Server running on port 3000`

**Test the API:**
Open another terminal and test:
```bash
curl -X POST http://localhost:3000/api/contact \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","message":"Test message","interest":"assessment"}'
```

If you get `{"success":true}`, the backend is working! Press `Ctrl+C` to stop it.

## Step 5: Set Up Backend as a Service

Copy the service file to systemd:

```bash
sudo cp /home/bernardfatoye/HTAplus/hta-backend/hta-backend.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable hta-backend
sudo systemctl start hta-backend
```

Check if it's running:
```bash
sudo systemctl status hta-backend
```

View logs:
```bash
sudo journalctl -u hta-backend -f
```

## Step 6: Set Up Nginx (If Not Already Done)

Follow the instructions in `NGINX_SETUP.md` to configure Nginx.

## Step 7: Test the Full Stack

1. **Find your Pi's IP address:**
   ```bash
   hostname -I
   ```

2. **Test Frontend:**
   - Open a browser on another device on the same network
   - Go to: `http://YOUR_PI_IP`
   - You should see the HTA Advisory website

3. **Test Contact Form:**
   - Scroll to the contact form
   - Fill it out and submit
   - Check your email (bernardfatoye@gmail.com) for the inquiry
   - The email should include the "Interested in" field if you selected a service

4. **Test API Directly:**
   ```bash
   curl -X POST http://YOUR_PI_IP/api/contact \
     -H "Content-Type: application/json" \
     -d '{"name":"Test User","email":"test@example.com","message":"Test message","interest":"strategy"}'
   ```

## Troubleshooting

### Backend won't start
- Check logs: `sudo journalctl -u hta-backend -n 50`
- Verify `.env` file exists and has correct values
- Check if port 3000 is already in use: `sudo lsof -i :3000`

### CORS errors
- Make sure `CORS_ORIGIN` in `.env` matches your Pi's IP (with `http://` prefix)
- Restart the service: `sudo systemctl restart hta-backend`

### Nginx errors
- Test config: `sudo nginx -t`
- Check logs: `sudo tail -f /var/log/nginx/error.log`
- Verify file permissions: `sudo chmod -R 755 /home/bernardfatoye/HTAplus`

### Email not sending
- Verify Gmail app password is correct
- Check backend logs for email errors
- Test email credentials separately

## Quick Commands Reference

```bash
# Start backend service
sudo systemctl start hta-backend

# Stop backend service
sudo systemctl stop hta-backend

# Restart backend service
sudo systemctl restart hta-backend

# View backend logs
sudo journalctl -u hta-backend -f

# Restart Nginx
sudo systemctl restart nginx

# Check backend status
sudo systemctl status hta-backend
```
