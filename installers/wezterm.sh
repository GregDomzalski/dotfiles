#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e
set -o pipefail

# Use trap to ensure cleanup happens even if the script exits prematurely
trap "rm -rf $TMP_DIR" EXIT

# Create a temporary directory for downloads
TMP_DIR=$(mktemp -d)

# Fetch the download URLs for the latest AppImage and its sha256 checksum
echo "Fetching the download URLs for the latest AppImage and its sha256 checksum..."
APPIMAGE_URL=$(curl -s https://api.github.com/repos/wez/wezterm/releases/latest | grep -oP 'https://.*?Ubuntu20\.04\.AppImage(?=")')
CHECKSUM_URL=$(curl -s https://api.github.com/repos/wez/wezterm/releases/latest | grep -oP 'https://.*?Ubuntu20\.04\.AppImage\.sha256(?=")')
ICON_URL="https://github.com/wez/wezterm/blob/fec90ae04bf448d4b1475ba1d0ba1392846a70d6/assets/icon/wezterm-icon.svg"

# Download the AppImage and its checksum
echo "Downloading the AppImage..."
wget "$APPIMAGE_URL" -O "$TMP_DIR/WezTerm.AppImage"
wget "$CHECKSUM_URL" -O "$TMP_DIR/WezTerm.AppImage.sha256"
wget "$ICON_URL" -O "$TMP_DIR/WezTerm.svg"

# Verify the checksum
echo "Verifying checksum..."

EXPECTED_CHECKSUM=$(cat "$TMP_DIR/WezTerm.AppImage.sha256" | awk '{print $1}')
ACTUAL_CHECKSUM=$(sha256sum "$TMP_DIR/WezTerm.AppImage" | awk '{print $1}')

if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
  echo "Checksum verification failed!"
  echo "Expected: $EXPECTED_CHECKSUM"
  echo "Got: $ACTUAL_CHECKSUM"
  exit 1
fi

# Ensure the target directory exists
mkdir -p ~/.local/share/AppImages

# Move and chmod the AppImage
echo "Installing AppImage into ~/.local/share/AppImages"
mv "$TMP_DIR/WezTerm.AppImage" ~/.local/share/AppImages/WezTerm.AppImage
mv "$TMP_DIR/WezTerm.svg" ~/.local/share/AppImages/WezTerm.svg
chmod +x ~/.local/share/AppImages/WezTerm.AppImage

# Symlink the AppImage
echo "Adding symlink in ~/.local/bin"
mkdir -p ~/.local/bin
ln -sf ~/.local/share/AppImages/WezTerm.AppImage ~/.local/bin/wezterm

# Create .Desktop file
echo "Creating .Desktop file"
cat > ~/.local/share/applications/wezterm.desktop <<EOL
[Desktop Entry]
Version=1.0
Name=WezTerm
GenericName=Terminal Emulator
Comment=Wez's Terminal Emulator
Exec=$HOME/.local/bin/wezterm
Icon=$HOME/.local/share/AppImages/WezTerm.svg
Terminal=false
Type=Application
Categories=System;TerminalEmulator;
EOL

update-desktop-database ~/.local/share/applications/
