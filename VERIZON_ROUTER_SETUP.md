# Verizon Router Port Forwarding Setup

## Step-by-Step Instructions

### Step 1: Get Your Pi's Local IP

**On your Pi**, run:
```bash
hostname -I
```

**Write down the IP:** `___________` (usually looks like `192.168.1.100`)

### Step 2: Create Port 80 Rule (HTTP)

In the "Create Rule" section:

1. **Application**: `HTA-HTTP` ✓ (already filled)
2. **Original Port**: `80` ✓ (already filled)
3. **Protocol**: `TCP` ✓ (already selected)
4. **Fwd to Addr**: **Select your Pi's IP** from dropdown (NOT 127.0.0.1!)
   - This should be the IP from Step 1 (e.g., `192.168.1.100`)
5. **Fwd to Port**: Change `0000` to `80`
6. **Schedule**: Select `Always` (or leave default)
7. Click **"Add to list"**

### Step 3: Create Port 443 Rule (HTTPS)

Click in the "Create Rule" section again and fill:

1. **Application**: `HTA-HTTPS`
2. **Original Port**: `443`
3. **Protocol**: `TCP`
4. **Fwd to Addr**: **Select your Pi's IP** (same as Step 2)
5. **Fwd to Port**: `443`
6. **Schedule**: Select `Always` (or leave default)
7. Click **"Add to list"**

### Step 4: Apply Changes

Click the **"Apply Changes"** button at the top right.

### Step 5: Verify Rules

You should now see two new rules in the "Rules List":
- HTA-HTTP: Port 80 → Your Pi's IP → Port 80
- HTA-HTTPS: Port 443 → Your Pi's IP → Port 443

## Important Notes

⚠️ **Don't use 127.0.0.1** - That's localhost and won't work for external access!

✅ **Use your Pi's actual IP** from `hostname -I` command

## After Port Forwarding is Set Up

### Test Port Forwarding

**From your phone (using mobile data, NOT WiFi):**
- Visit: `http://97.178.74.125`
- Should connect to your site (or at least not timeout)

### Retry Certbot

**On your Pi:**
```bash
sudo certbot --nginx -d htaplus.com -d www.htaplus.com
```

Should work now!

## Troubleshooting

### Can't Find Your Pi's IP in Dropdown

1. Make sure your Pi is connected to the network
2. Check Pi's IP again: `hostname -I`
3. Refresh the router page
4. If still not there, you might need to:
   - Set a static IP for your Pi in router's DHCP settings
   - Or manually type the IP (if the interface allows)

### Changes Don't Save

- Make sure you click "Add to list" for each rule
- Then click "Apply Changes" at the top
- Some routers need a few seconds to apply

### Still Getting Timeout

1. **Wait 1-2 minutes** after applying changes
2. **Test from outside network** (mobile data)
3. **Check Pi's IP hasn't changed**: `hostname -I`
4. **Verify Nginx is running**: `sudo systemctl status nginx`
