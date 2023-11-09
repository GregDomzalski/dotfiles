#!/bin/bash

# Set the script to exit immediately on error
set -e
set -o pipefail

# Create a temporary directory
TMP_DIR=$(mktemp -d)

# Ensure the temporary directory is cleaned up on exit, error, or interruption
trap "rm -rf $TMP_DIR" EXIT

# Install required tools
sudo apt-get install -y wget gpg

# GPG key path
GPG_KEY_PATH="/etc/apt/keyrings/packages.microsoft.gpg"

# Only download and install the GPG key if it hasn't already been installed
if [ ! -f "$GPG_KEY_PATH" ]; then
    # Download Microsoft's GPG key
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > "$TMP_DIR/packages.microsoft.gpg"

    # Install the GPG key
    sudo install -D -o root -g root -m 644 "$TMP_DIR/packages.microsoft.gpg" "$GPG_KEY_PATH"
fi

# Repository configuration file path
REPO_FILE_PATH="/etc/apt/sources.list.d/vscode.list"

# Only add the VS Code repository if it doesn't already exist
if [ ! -f "$REPO_FILE_PATH" ]; then
    sudo sh -c "echo 'deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main' > '$REPO_FILE_PATH'"
fi

# Install transport HTTPS for APT if not installed
sudo apt install -y apt-transport-https

# Update APT's cache
sudo apt update

# Install VS Code
sudo apt install -y code
