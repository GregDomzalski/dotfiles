#!/bin/bash

set -e
set -o pipefail

# URLs
FILE_URL=$(curl -s 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' | grep -Po '"linux":.*?[^\\]",' | awk -F ':' '{print $3,":"$4}'| sed 's/[", ]//g')
FILE_NAME=$(basename "$FILE_URL")
CHECKSUM_URL="$FILE_URL.sha256"
CHECKSUM_NAME=$(basename "$CHECKSUM_URL")

# Destination directory
DEST_DIR="$HOME/.local/share/JetBrains/Toolbox/bin"
SYMLINK_DIR="$HOME/.local/bin"

# Temporary directory
TMP_DIR=$(mktemp -d)

# Download the files with full path
wget "$FILE_URL" -O "$TMP_DIR/$FILE_NAME"
wget "$CHECKSUM_URL" -O "$TMP_DIR/$CHECKSUM_NAME"

# Verify checksum
echo "Verifying checksum..."
EXPECTED_CHECKSUM=$(cat "$TMP_DIR/$CHECKSUM_NAME" | awk '{print $1}')
ACTUAL_CHECKSUM=$(sha256sum "$TMP_DIR/$FILE_NAME" | awk '{print $1}')

if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
  echo "Checksum verification failed!"
  echo "Expected: $EXPECTED_CHECKSUM"
  echo "Got: $ACTUAL_CHECKSUM"
  exit 1
fi

# Extract the archive
echo "Extracting the archive..."
mkdir -p "$DEST_DIR"
tar -xzf "$TMP_DIR/$FILE_NAME" -C "$DEST_DIR" --strip-components=1
chmod +x "$DEST_DIR/jetbrains-toolbox"

# Add symlink
mkdir -p $SYMLINK_DIR
rm "$SYMLINK_DIR/jetbrains-toolbox" 2>/dev/null || true
ln -s "$DEST_DIR/jetbrains-toolbox" "$SYMLINK_DIR/jetbrains-toolbox"

# Delete the downloaded files
echo "Cleaning up..."
rm "$TMP_DIR/$FILE_NAME" "$TMP_DIR/$CHECKSUM_NAME"

# Remove temp directory
rmdir "$TMP_DIR"

echo "Done!"

