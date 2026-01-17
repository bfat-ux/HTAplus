# Fix Port Forwarding for SSL Certificate

## Problem
Certbot can't reach your Pi from the internet. This means port 80 (HTTP) is not accessible from outside your network.

## Why This Happens
Let's Encrypt needs to verify you own the domain by accessing your server on port 80. If port forwarding isn't set up, the internet can't reach your Pi.

## Solution: Set Up Port Forwarding

### Step 1: Find Your Pi's Local IP Address

**On your Pi**, run:
```bash
hostname -I
```

This will show your Pi's local IP (e.g., `192.168.1.100` or `192.168.0.50`).

**Write it down:** `___________`

### Step 2: Access Your Router Admin Page

1. **Find your router's IP:**
   ```bash
   # On your Pi
   ip route | grep default
   ```
   Usually shows something like `default via 192.168.1.1` or `192.168.0.1`

2. **Open router admin in browser:**
   - Usually: `http://192.168.1.1` or `http://192.168.0.1`
   - Or check your router's manual for the admin URL

3. **Log in** (check router sticker or manual for default username/password)

### Step 3: Set Up Port Forwarding

**In your router admin panel**, find:
- "Port Forwarding" or
- "Virtual Server" or
- "NAT Forwarding" or
- "Applications & Gaming" (some routers)

**Add these two port forwarding rules:**

#### Rule 1: HTTP (Port 80)
- **Service Name**: `HTA-HTTP` (or any name)
- **External Port**: `80`
- **Internal IP**: `[Your Pi's local IP from Step 1]`
- **Internal Port**: `80`
- **Protocol**: `TCP` (or `Both`/`TCP/UDP`)
- **Status**: `Enabled`

#### Rule 2: HTTPS (Port 443)
- **Service Name**: `HTA-HTTPS` (or any name)
- **External Port**: `443`
- **Internal IP**: `[Your Pi's local IP from Step 1]`
- **Internal Port**: `443`
- **Protocol**: `TCP` (or `Both`/`TCP/UDP`)
- **Status**: `Enabled`

**Save/Apply** the changes.

### Step 4: Verify Port Forwarding Works

**From outside your network** (use mobile data, not WiFi):
```bash
# Test if port 80 is accessible
curl -I http://htaplus.com

# Should get HTTP response, not timeout
```

**Or use an online tool:**
- Visit: https://www.yougetsignal.com/tools/open-ports/
- Enter your public IP: `97.178.74.125`
- Check ports 80 and 443
- Should show "Open"

### Step 5: Check Firewall on Pi

**On your Pi**, make sure firewall allows ports 80 and 443:

```bash
# Check if ufw is active
sudo ufw status

# If active, allow ports
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload
```

### Step 6: Verify Nginx is Listening

**On your Pi:**
```bash
# Check if Nginx is listening on ports 80 and 443
sudo netstat -tlnp | grep -E ":(80|443)"
```

Should show Nginx listening on both ports.

### Step 7: Retry Certbot

Once port forwarding is set up:

```bash
# Try certbot again
sudo certbot --nginx -d htaplus.com -d www.htaplus.com
```

## Alternative: Use Standalone Mode (If Port Forwarding is Complex)

If setting up port forwarding is difficult, you can temporarily stop Nginx and use standalone mode:

```bash
# Stop Nginx temporarily
sudo systemctl stop nginx

# Run certbot in standalone mode
sudo certbot certonly --standalone -d htaplus.com -d www.htaplus.com

# Start Nginx again
sudo systemctl start nginx

# Configure Nginx to use the certificate
sudo certbot --nginx -d htaplus.com -d www.htaplus.com
```

**Note**: This still requires port 80 to be accessible, but certbot handles it differently.

## Troubleshooting

### Can't Access Router Admin

- Check router manual for default IP
- Try common IPs: `192.168.1.1`, `192.168.0.1`, `10.0.0.1`
- Check router sticker for admin URL

### Port Forwarding Doesn't Work

1. **Check Pi's local IP hasn't changed:**
   ```bash
   hostname -I
   ```
   If it changed, update port forwarding rules

2. **Check if Pi has static IP:**
   - Consider setting static IP in router's DHCP settings
   - Or reserve IP for your Pi's MAC address

3. **Test from outside network:**
   - Use mobile data (not WiFi)
   - Visit: `http://97.178.74.125` (your public IP)
   - Should show your site

### Still Getting Timeout

1. **Check ISP blocks port 80:**
   - Some ISPs block port 80
   - Try port forwarding to a different external port (e.g., 8080)
   - Then use certbot with `--http-01-port` option

2. **Check for double NAT:**
   - If you have multiple routers, port forward on both

3. **Contact ISP:**
   - Some ISPs require you to request port 80/443 to be opened

## Quick Checklist

- [ ] Found Pi's local IP: `___________`
- [ ] Logged into router admin
- [ ] Added port forwarding for port 80
- [ ] Added port forwarding for port 443
- [ ] Saved/Applied changes
- [ ] Tested port 80 from outside network
- [ ] Ran certbot again

## After Port Forwarding is Working

Once certbot succeeds:

1. **Verify SSL:**
   ```bash
   sudo certbot certificates
   ```

2. **Test HTTPS:**
   ```bash
   curl -L https://htaplus.com | head -20
   ```

3. **Update backend CORS:**
   ```bash
   nano /home/bernardfatoye/HTAplus/hta-backend/.env
   ```
   Set: `CORS_ORIGIN=https://htaplus.com,https://www.htaplus.com`

4. **Restart backend:**
   ```bash
   sudo systemctl restart hta-backend
   ```
