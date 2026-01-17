# Fix for "directory already exists" error

Since the directory already exists, you have two options:

## Option 1: Use the existing directory (if it has files)

Check what's in there:
```bash
cd /home/bernardfatoye/HTAplus
ls -la
```

If it already has your files, just update it:
```bash
cd /home/bernardfatoye/HTAplus
git checkout title-it-0ceec
git pull origin title-it-0ceec
```

## Option 2: Remove and re-clone (if directory is empty or old)

If the directory is empty or has old files:
```bash
cd /home/bernardfatoye
rm -rf HTAplus
git clone https://github.com/bfat-ux/HTAplus.git HTAplus
cd HTAplus
git checkout title-it-0ceec
cd hta-backend
npm install
```
