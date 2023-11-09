#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define a temporary directory for the download
TMP_DIR=$(mktemp -d)

# Ensure cleanup happens even if the script exits prematurely
trap "rm -rf $TMP_DIR" EXIT

# Get Ubuntu version
declare repo_version=$(if command -v lsb_release &> /dev/null; then lsb_release -r -s; else grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"'; fi)

# Download Microsoft signing key and repository
wget https://packages.microsoft.com/config/ubuntu/$repo_version/packages-microsoft-prod.deb -O $TMP_DIR/packages-microsoft-prod.deb

# Install Microsoft signing key and repository
sudo dpkg -i $TMP_DIR/packages-microsoft-prod.deb

# Update packages
sudo apt update

# Make sure the Microsoft feeds are used for .NET related downloads
sudo tee -a /etc/apt/preferences <<-EOL
Package: dotnet* aspnet* netstandard*
Pin: origin "security.ubuntu.com"
Pin-Priority: -10
Pin: origin "us.archive.ubuntu.com"
Pin-Priority: -10
EOL

sudo apt update && sudo apt install -y dotnet-sdk-6.0 dotnet-sdk-7.0

# Ensure the profile directory exists
source utils/create_profile.sh

# Write the desired content to dotnet.profile
cat << EOF > "$PROFILE_D_DIR/dotnet.profile"
# Set paths for .NET
export DOTNET_ROOT=/usr/share/dotnet
export PATH="\$PATH:/usr/share/dotnet"

# bash parameter completion for the dotnet CLI

function _dotnet_bash_complete()
{
  local cur="\${COMP_WORDS[COMP_CWORD]}" IFS=$'\n' # On Windows you may need to use use IFS=$'\r\n'
  local candidates

  read -d '' -ra candidates < <(dotnet complete --position "\${COMP_POINT}" "\${COMP_LINE}" 2>/dev/null)

  read -d '' -ra COMPREPLY < <(compgen -W "\${candidates[*]:-}" -- "\$cur")
}

complete -f -F _dotnet_bash_complete dotnet
EOF
