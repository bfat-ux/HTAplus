# Dynamic DNS for api.htaplus.com (GoDaddy + Pi)

Your home internet's public IP rotates from time to time. When it does,
`api.htaplus.com` silently starts pointing at the wrong box, the contact
form on htaplus.com starts failing, and nobody notices until you do.

This script prevents that. A systemd timer runs it every 5 minutes; it
checks your current public IP against what GoDaddy has on record, and
if they differ, it updates GoDaddy via their API. Normal runs are a
no-op with zero log spam.

---

## 1. Get a GoDaddy Production API key

1. Sign in at https://developer.godaddy.com/keys
2. Click **Create New API Key**
3. Name it something like `hta-ddns-pi`
4. **Environment: Production** (NOT "OTE" — OTE is a test environment
   and won't touch your real records)
5. Copy the **Key** and **Secret** somewhere safe — the Secret is only
   shown once.

---

## 2. Copy the files onto the Pi

From your Mac, inside the repo:

```bash
scp hta-backend/ddns/hta-ddns-update.sh \
    bernardfatoye@<pi>:/tmp/
scp hta-backend/ddns/hta-ddns.service \
    hta-backend/ddns/hta-ddns.timer \
    bernardfatoye@<pi>:/tmp/
scp hta-backend/ddns/hta-ddns.env.example \
    bernardfatoye@<pi>:/tmp/
```

(Replace `<pi>` with the Pi's LAN IP or hostname.)

---

## 3. Install on the Pi

SSH into the Pi, then:

```bash
# Move script into place and make it executable
sudo install -m 0755 /tmp/hta-ddns-update.sh /usr/local/bin/hta-ddns-update.sh

# Install the systemd units
sudo install -m 0644 /tmp/hta-ddns.service /etc/systemd/system/hta-ddns.service
sudo install -m 0644 /tmp/hta-ddns.timer   /etc/systemd/system/hta-ddns.timer

# Create the env file (mode 600 — only root should read the API secret)
sudo install -m 0600 /tmp/hta-ddns.env.example /etc/hta-ddns.env
sudo nano /etc/hta-ddns.env     # fill in GODADDY_KEY + GODADDY_SECRET

# Create the state directory
sudo mkdir -p /var/lib/hta-ddns
sudo chmod 755 /var/lib/hta-ddns
```

---

## 4. First run (manually, to make sure it works)

```bash
sudo systemctl daemon-reload
sudo systemctl start hta-ddns.service
sudo journalctl -u hta-ddns.service -n 20 --no-pager
```

You should see something like:

```
[hta-ddns] 2026-04-14T... Public IP 97.178.110.128 already matches GoDaddy. Refreshing local cache.
```

Or — if your public IP has actually changed since the last manual
update — you'll see `Update successful. api.htaplus.com -> <newIP>`.

---

## 5. Enable the timer so it runs forever

```bash
sudo systemctl enable --now hta-ddns.timer
sudo systemctl list-timers hta-ddns.timer
```

That's it. Every 5 minutes the script checks; only noisy when there's
something to say.

---

## 6. How to verify it's actually working

```bash
# Watch the timer fire in real time
sudo journalctl -u hta-ddns.service -f

# Force a run
sudo systemctl start hta-ddns.service

# Simulate an IP change by invalidating the cache
sudo rm /var/lib/hta-ddns/last-ip
sudo systemctl start hta-ddns.service
# -> should hit GoDaddy API, confirm IP still matches, refresh cache
```

---

## 7. Security notes

- `/etc/hta-ddns.env` is mode `0600`, owned by root. The API key is
  only readable by root and processes that start as root. The systemd
  unit uses `ProtectSystem=strict`, `PrivateTmp=yes`, and
  `NoNewPrivileges=yes` so even a compromise in the script can't mess
  with much else.
- The GoDaddy key can be revoked at any time from
  https://developer.godaddy.com/keys without disrupting anything else
  you're running — it's scoped only to that key.
- If the key leaks: delete it in the GoDaddy developer portal, create
  a new one, update `/etc/hta-ddns.env`, `sudo systemctl restart
  hta-ddns.service`.

---

## 8. Troubleshooting

| Symptom | Likely cause |
|---|---|
| `ERROR: GODADDY_KEY and GODADDY_SECRET must be set` | `/etc/hta-ddns.env` missing or misnamed |
| `HTTP 401` or `HTTP 403` from GoDaddy | Using OTE keys instead of Production keys |
| `HTTP 404` from GoDaddy | `DOMAIN` or `RECORD_NAME` wrong in env file |
| `could not reach https://api.ipify.org` | Pi lost internet; will auto-recover next run |
| Timer not firing | `sudo systemctl status hta-ddns.timer` — is it enabled? |
