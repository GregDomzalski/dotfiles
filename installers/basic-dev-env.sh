#!/bin/bash

# Install Git, SSH, and GnuPG and their dependencies
sudo apt update && sudo apt install -y git ssh gnupg kgpg

# Configure SSH
mkdir -p ~/.ssh
cp ../public_keys/home_infra_auth_key.pub ~/.ssh/home_infra_auth_key.pub
cp ../public_keys/github_auth_key.pub ~/.ssh/github_auth_key.pub
cp ../configs/ssh_config ~/.ssh/config

# Configure Git
cp ../configs/git_config ~/.gitconfig
