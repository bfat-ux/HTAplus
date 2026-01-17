# Transfer Files to Raspberry Pi

This guide will help you transfer your HTA Project files from your Mac to your Raspberry Pi.

## Option 1: Using SCP (Simple Copy) - Recommended for First Time

**On your Mac**, open Terminal and run:

```bash
# Replace YOUR_PI_IP with your actual Pi IP address
# Replace bernardfatoye with your Pi username if different

scp -r "/Users/berna/HTA Project"/* bernardfatoye@YOUR_PI_IP:/home/bernardfatoye/HTAplus/
```

**Example:**
```bash
scp -r "/Users/berna/HTA Project"/* bernardfatoye@192.168.1.100:/home/bernardfatoye/HTAplus/
```

This will:
- Copy all files from your Mac to `/home/bernardfatoye/HTAplus/` on your Pi
- Create the `HTAplus` directory if it doesn't exist

## Option 2: Using RSYNC (Better for Updates)

**On your Mac**, open Terminal and run:

```bash
# This is better if you need to update files later
rsync -avz --progress "/Users/berna/HTA Project/" bernardfatoye@YOUR_PI_IP:/home/bernardfatoye/HTAplus/
```

**Example:**
```bash
rsync -avz --progress "/Users/berna/HTA Project/" bernardfatoye@192.168.1.100:/home/bernardfatoye/HTAplus/
```

## Option 3: Using Git (If You Have a Repository)

If your project is in a git repository:

**On your Pi:**
```bash
cd /home/bernardfatoye
git clone YOUR_REPO_URL HTAplus
cd HTAplus
```

## Step-by-Step Instructions

### 1. Find Your Pi's IP Address

**On your Pi**, run:
```bash
hostname -I
```

This will show your Pi's IP address (e.g., `192.168.1.100`)

### 2. Create the Directory on Pi (if needed)

**On your Pi**, run:
```bash
mkdir -p /home/bernardfatoye/HTAplus
```

### 3. Transfer Files from Mac

**On your Mac**, open Terminal and run:

```bash
# Replace 192.168.1.100 with your actual Pi IP
scp -r "/Users/berna/HTA Project"/* bernardfatoye@192.168.1.100:/home/bernardfatoye/HTAplus/
```

You'll be prompted for your Pi password.

### 4. Verify Files Were Transferred

**On your Pi**, run:
```bash
ls -la /home/bernardfatoye/HTAplus/
```

You should see:
- `index.html`
- `script.js`
- `styles.css`
- `hta-backend/` directory

### 5. Check Backend Directory

```bash
ls -la /home/bernardfatoye/HTAplus/hta-backend/
```

You should see:
- `index.js`
- `package.json`
- `hta-backend.service`
- `TESTING_GUIDE.md`
- etc.

## Troubleshooting

### "Permission denied" error
- Make sure the directory exists on Pi: `mkdir -p /home/bernardfatoye/HTAplus`
- Check permissions: `chmod 755 /home/bernardfatoye/HTAplus`

### "Connection refused" error
- Make sure SSH is enabled on your Pi: `sudo systemctl enable ssh`
- Check if you can ping your Pi: `ping YOUR_PI_IP`

### "No such file or directory" on Mac
- Make sure you're using the correct path with quotes: `"/Users/berna/HTA Project"`
- The space in "HTA Project" requires quotes

## After Transfer

Once files are transferred, continue with the testing guide:
```bash
cd /home/bernardfatoye/HTAplus/hta-backend
cat TESTING_GUIDE.md
```
