# Troubleshooting 500 Error

A 500 error means Nginx is running but can't serve the files. Common causes:

1. **File permissions** - Nginx can't read the files
2. **Wrong file path** - Files aren't where Nginx expects them
3. **Missing index.html** - The file doesn't exist
4. **Backend connection** - API proxy issue

## Quick Fixes:

### 1. Check Nginx error logs:
```bash
sudo tail -n 20 /var/log/nginx/error.log
```

### 2. Check file permissions:
```bash
ls -la /home/bernardfatoye/HTAplus/
ls -la /home/bernardfatoye/HTAplus/index.html
```

### 3. Fix permissions if needed:
```bash
sudo chmod -R 755 /home/bernardfatoye/HTAplus
sudo chown -R bernardfatoye:bernardfatoye /home/bernardfatoye/HTAplus
```

### 4. Verify files exist:
```bash
ls -la /home/bernardfatoye/HTAplus/index.html
ls -la /home/bernardfatoye/HTAplus/styles.css
ls -la /home/bernardfatoye/HTAplus/script.js
```

### 5. Test Nginx config:
```bash
sudo nginx -t
```

### 6. Check if Nginx can access the directory:
```bash
sudo -u www-data ls -la /home/bernardfatoye/HTAplus/
```

If this fails, it's a permissions issue.
