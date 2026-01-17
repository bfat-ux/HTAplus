# SSH Troubleshooting for Raspberry Pi

Since ping is working, the Pi is reachable. The issue is with SSH. Try these steps:

## On Your Pi (in the remote shell):

### 1. Check if SSH is running:
```bash
sudo systemctl status ssh
```

### 2. If SSH is not running, start it:
```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```

### 3. Check if SSH is listening on port 22:
```bash
sudo netstat -tlnp | grep :22
```
or
```bash
sudo ss -tlnp | grep :22
```

### 4. Check firewall (if you have one):
```bash
sudo ufw status
```

If firewall is active, allow SSH:
```bash
sudo ufw allow ssh
```

### 5. Verify SSH service is enabled:
```bash
sudo systemctl is-enabled ssh
```

## Alternative: Try SSH connection first

On your Mac Terminal, try connecting with SSH:
```bash
ssh bernardfatoye@192.168.1.154
```

This will help us see the exact error message.

## If SSH still doesn't work:

You might need to enable SSH via Raspberry Pi configuration:
```bash
sudo raspi-config
```
Then navigate to: Interface Options → SSH → Enable
