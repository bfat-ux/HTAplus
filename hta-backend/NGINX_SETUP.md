# Nginx Setup for HTA+ Frontend + Backend

## 1. Install Nginx on Pi

```bash
sudo apt-get update
sudo apt-get install -y nginx
```

## 2. Create Nginx Config

```bash
sudo tee /etc/nginx/sites-available/hta-site > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;  # Replace with your domain if you have one

    # Root directory for frontend files
    root /home/bernardfatoye/HTAplus;
    index index.html;

    # Serve static files (HTML, CSS, JS, images)
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Proxy API requests to backend
    location /api/ {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF
```

## 3. Enable Site

```bash
# Remove default site (optional)
sudo rm /etc/nginx/sites-enabled/default

# Enable HTA site
sudo ln -s /etc/nginx/sites-available/hta-site /etc/nginx/sites-enabled/hta-site

# Test config
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
sudo systemctl enable nginx
```

## 4. Update Backend CORS

Update `/home/bernardfatoye/HTAplus/hta-backend/.env`:

```
CORS_ORIGIN=http://YOUR_PI_IP
```

Or if accessing via domain:
```
CORS_ORIGIN=http://yourdomain.com
```

Then restart backend:
```bash
sudo systemctl restart hta-backend
```

## 5. Set Permissions

```bash
# Make sure Nginx can read the frontend files
sudo chmod -R 755 /home/bernardfatoye/HTAplus
```

## 6. Test

- Frontend: `http://YOUR_PI_IP`
- API: `http://YOUR_PI_IP/api/contact` (should return 404/405 for GET, which is expected)

## Troubleshooting

Check Nginx logs:
```bash
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

Check backend logs:
```bash
sudo journalctl -u hta-backend -f
```
