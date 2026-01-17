# Port Forwarding Guide - Different Router Types

Router interfaces vary. Use this guide to find the right section.

## Common Router Brands & Where to Find Port Forwarding

### Netgear
- **Location**: Advanced → Advanced Setup → Port Forwarding/Port Triggering
- **Or**: Advanced → WAN Setup → Port Forwarding

### Linksys
- **Location**: Connectivity → Router Settings → Port Forwarding
- **Or**: Smart Wi-Fi Tools → Port Forwarding

### TP-Link
- **Location**: Advanced → NAT Forwarding → Virtual Servers
- **Or**: Advanced → Forwarding → Virtual Servers

### ASUS
- **Location**: WAN → Virtual Server/Port Forwarding
- **Or**: Advanced Settings → WAN → Virtual Server/Port Forwarding

### D-Link
- **Location**: Advanced → Port Forwarding
- **Or**: Firewall → Virtual Server

### Google Nest / Google WiFi
- **Location**: Network & General → Advanced networking → Port management → Port forwarding

### Eero
- **Location**: Settings → Network Settings → Port Forwarding

### Orbi (Netgear)
- **Location**: Advanced → Advanced Setup → Port Forwarding

## What You're Looking For

You need to find a section that lets you:
1. **Map an external port** (like 80) **to an internal IP and port**
2. **Add a new rule/entry**

## Step-by-Step: What Information You Need

Before you start, get this info from your Pi:

```bash
# On your Pi - get local IP
hostname -I
```

**Write down your Pi's local IP:** `___________`

## Common Interface Patterns

### Pattern 1: Simple Form
You might see fields like:
- **Service Name** or **Name**: `HTA-HTTP` (you can name it anything)
- **External Port** or **Public Port**: `80`
- **Internal IP** or **IP Address**: `[Your Pi's IP]`
- **Internal Port** or **Private Port**: `80`
- **Protocol**: `TCP` or `Both`

### Pattern 2: Table/List View
You might see a table where you click "Add" or "New" button, then fill in:
- Port range or single port
- IP address
- Protocol

### Pattern 3: Application-Based
Some routers have "Applications" or "Gaming" sections. Look for:
- "Add Custom Service" or "Add Application"
- Then fill in port and IP

## What to Enter (Two Rules Needed)

### Rule 1: HTTP (Port 80)
- **Name/Service**: `HTA-HTTP` (or any name)
- **External/WAN Port**: `80`
- **Internal/LAN IP**: `[Your Pi's IP from hostname -I]`
- **Internal/LAN Port**: `80`
- **Protocol**: `TCP`

### Rule 2: HTTPS (Port 443)
- **Name/Service**: `HTA-HTTPS` (or any name)
- **External/WAN Port**: `443`
- **Internal/LAN IP**: `[Your Pi's IP from hostname -I]`
- **Internal/LAN Port**: `443`
- **Protocol**: `TCP`

## If You Can't Find Port Forwarding

### Alternative Names to Look For:
- Virtual Server
- Port Mapping
- NAT Forwarding
- Port Triggering
- Applications & Gaming
- Firewall Rules
- Advanced Settings → NAT
- Network → Port Forwarding

### Check These Sections:
1. **Advanced** or **Advanced Settings**
2. **Network** or **Network Settings**
3. **Firewall** or **Security**
4. **WAN** or **Internet Settings**
5. **Applications** or **Gaming**

## Still Can't Find It?

### Option 1: Router Manual
- Google: "[Your Router Model] port forwarding"
- Check router's manual/help section

### Option 2: Universal Plug and Play (UPnP)
Some routers have UPnP that can auto-configure. Check if your router has:
- UPnP settings (usually in Advanced)
- Enable it (less secure, but easier)

### Option 3: Screenshot Help
If you can describe what you see or share a screenshot (blur sensitive info), I can help identify the right section.

## Quick Test After Setting Up

Once you've added the rules:

**From your phone (using mobile data, NOT WiFi):**
- Visit: `http://97.178.74.125`
- Should show your site (or at least connect, not timeout)

**Or use online tool:**
- Visit: https://www.yougetsignal.com/tools/open-ports/
- Enter IP: `97.178.74.125`
- Check ports 80 and 443
- Should show "Open"

## Common Issues

### "Port Already in Use"
- Another device might be using port 80
- Check what's using it: `sudo netstat -tlnp | grep :80` (on Pi)
- Or change external port to something else (like 8080)

### "Invalid IP Address"
- Make sure you're using your Pi's local IP (from `hostname -I`)
- Not your public IP (97.178.74.125)
- Usually looks like: `192.168.x.x` or `10.0.x.x`

### Changes Don't Save
- Some routers require you to click "Apply" or "Save" separately
- Some need you to restart the router

## What Does Your Router Interface Look Like?

Describe what you see:
- What's the main menu/sidebar?
- What sections are available?
- Any search function in the admin panel?

This will help me guide you to the exact location!
