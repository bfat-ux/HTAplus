#!/bin/bash

echo "=== GitHub SSH Setup ==="
echo ""

# Step 1: Generate key if it doesn't exist
if [ -f ~/.ssh/id_ed25519 ]; then
    echo "SSH key already exists, skipping generation."
else
    echo "Generating SSH key..."
    ssh-keygen -t ed25519 -C "pi5" -f ~/.ssh/id_ed25519 -N ""
fi

echo ""
echo "========================================"
echo "YOUR PUBLIC KEY (copy this entire line):"
echo "========================================"
echo ""
cat ~/.ssh/id_ed25519.pub
echo ""
echo "========================================"
echo ""
echo "NEXT STEPS:"
echo "1. Go to https://github.com/settings/keys"
echo "2. Click 'New SSH key'"
echo "3. Title: Pi 5"
echo "4. Paste the key above"
echo "5. Click 'Add SSH key'"
echo ""
read -p "Press Enter AFTER you've added the key to GitHub..."

# Step 2: Test connection
echo ""
echo "Testing GitHub connection..."
ssh -T git@github.com 2>&1

# Step 3: Update remote
echo ""
echo "Updating repo remote to SSH..."
cd ~/HTAplus
git remote set-url origin git@github.com:bfat-ux/HTAplus.git
echo "Remote updated."

# Step 4: Test pull
echo ""
echo "Testing git pull..."
git pull origin main

echo ""
echo "=== Done! ==="
