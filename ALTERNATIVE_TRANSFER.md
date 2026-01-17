# Alternative File Transfer Methods

Since SSH is timing out even though ping works, let's try alternative methods to get your files to the Pi.

## Option 1: Use Git (Recommended if you have a repo)

If your project is in a git repository:

**On your Pi:**
```bash
cd /home/bernardfatoye
git clone YOUR_REPO_URL HTAplus
cd HTAplus/hta-backend
npm install
```

## Option 2: Transfer via USB Drive

1. Copy files to a USB drive on your Mac
2. Plug USB into Pi
3. On Pi, mount and copy:
```bash
# Find USB drive (usually /media/username/DRIVE_NAME)
ls /media/bernardfatoye/
# Copy files
cp -r /media/bernardfatoye/HTA\ Project/* /home/bernardfatoye/HTAplus/
```

## Option 3: Use Raspberry Pi Remote Shell File Transfer

Since you're using the remote shell, check if it has a file upload feature in the web interface.

## Option 4: Check Network Configuration

The timeout might be because:
- Your Mac and Pi are on different networks
- Router firewall blocking port 22
- Pi's iptables blocking connections

**On your Pi, check iptables:**
```bash
sudo iptables -L -n
```

If there are blocking rules, you might need to allow SSH:
```bash
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
```

## Option 5: Use SFTP with different port (if router blocks 22)

If your router blocks port 22, you could configure SSH on a different port, but this is more complex.

## Quick Check: Are you on the same network?

On your Mac, check your network:
```bash
ifconfig | grep "inet "
```

Compare the network range (e.g., 192.168.1.x) - both should be on the same subnet.
