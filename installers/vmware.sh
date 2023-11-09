#!/bin/bash

set -e

# Variables
DOWNLOAD_URL="https://www.vmware.com/go/getworkstation-linux"
TEMP_DIR=$(mktemp -d)

# Ensure temp directory is cleaned up on exit, error, or signal
trap 'rm -rf "$TEMP_DIR"' EXIT

# Install prerequisites
sudo apt install -y gcc build-essential

# Download VMware
echo "Downloading VMware Workstation to $TEMP_DIR..."
curl -L -A "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:91.0) Gecko/20100101 Firefox/91.0" -o "$TEMP_DIR/vmware-installer.bundle" $DOWNLOAD_URL

# Make the bundle executable
chmod +x "$TEMP_DIR/vmware-installer.bundle"

# Install VMware using the command-line options
# Note: The following options assume that you agree with the EULA.
# You should review VMware's EULA before using this script.
echo "Installing VMware..."
sudo "$TEMP_DIR/vmware-installer.bundle" --eulas-agreed --required --console

echo "VMware Workstation installation completed successfully!"

exit 0
