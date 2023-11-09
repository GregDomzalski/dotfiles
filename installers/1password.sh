#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e
set -o pipefail

# Define a temporary directory for the download
TMP_DIR=$(mktemp -d)

# Use trap to ensure cleanup happens even if the script exits prematurely
trap "rm -rf $TMP_DIR" EXIT

# Download the 1Password .deb package to the temporary directory
wget -O $TMP_DIR/1password.deb https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb

# Install the downloaded .deb package using dpkg
# This only configures the new apt repository and adds the signing key
sudo dpkg -i $TMP_DIR/1password.deb || :

# Use apt to fix potential missing dependencies
# Shouldn't need this though...
sudo apt --fix-broken install -y

# Install 1Password
sudo apt update && sudo apt install -y 1password 1password-cli

# Ensure the profile directory exists
source utils/create_profile.sh

# Write the desired content to dotnet.profile
cat << EOF > "$PROFILE_D_DIR/1password.profile"
# Set up 1Password SSH agent
export SSH_AUTH_SOCK=~/.1password/agent.sock
EOF


# The temporary directory will be removed automatically upon script exit due to the trap command

echo ""
echo ""
echo "1Password Desktop and 1Password CLI have been installed"
echo "To configure the CLI:"
echo "1. Open and unlock the 1Password app."
echo "2. Click on your account or collection at the top of the sidebar."
echo "3. Turn on system authentication in the app."
echo "4. Navigate to Settings > Developer."
echo "5. Select 'Integrate with 1Password CLI."
echo ""