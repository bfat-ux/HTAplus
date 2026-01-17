#!/bin/bash
# Transfer command for Mac Terminal
# Run this from your Mac, not from the Pi!

# Your Pi's IP address (from the image, it's 192.168.1.154)
PI_IP="192.168.1.154"
PI_USER="bernardfatoye"
PI_PATH="/home/bernardfatoye/HTAplus/"

# Transfer files
scp -r "/Users/berna/HTA Project"/* ${PI_USER}@${PI_IP}:${PI_PATH}

echo "Transfer complete! Now go to your Pi and run:"
echo "cd /home/bernardfatoye/HTAplus/hta-backend"
