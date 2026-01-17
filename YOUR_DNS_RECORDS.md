# DNS Records for htaplus.com

## Your IP Addresses

- **IPv4**: `97.178.74.125` ← **Use this for your A record**
- **IPv6**: `2600:100d:a0ed:1bba:2ecf:67ff:fee6:a681` (optional)

## DNS Records to Add

Go to your domain registrar (where you bought htaplus.com) and add these records:

### Required: IPv4 Records (A Records)

```
Type: A
Name: @ (or leave blank)
Value: 97.178.74.125
TTL: 3600 (or default)

Type: A
Name: www
Value: 97.178.74.125
TTL: 3600 (or default)
```

### Optional: IPv6 Records (AAAA Records)

If your registrar supports IPv6 and you want maximum compatibility:

```
Type: AAAA
Name: @ (or leave blank)
Value: 2600:100d:a0ed:1bba:2ecf:67ff:fee6:a681
TTL: 3600 (or default)

Type: AAAA
Name: www
Value: 2600:100d:a0ed:1bba:2ecf:67ff:fee6:a681
TTL: 3600 (or default)
```

## After Adding DNS Records

1. **Wait 15-30 minutes** for DNS to propagate
2. **Test DNS** (on your Mac or Pi):
   ```bash
   nslookup htaplus.com
   ```
   Should show: `97.178.74.125`

3. **Continue with Step 3** in `DOMAIN_SETUP.md` (Update Nginx)

## Important: Port Forwarding

Since you're on a home network, you MUST set up port forwarding on your router:

1. Find your Pi's local IP:
   ```bash
   hostname -I
   ```
   (Should show something like `192.168.1.100`)

2. On your router admin page, forward:
   - Port 80 → Your Pi's local IP → Port 80
   - Port 443 → Your Pi's local IP → Port 443

See `DOMAIN_SETUP.md` for detailed port forwarding instructions.
