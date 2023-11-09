#!/bin/bash

TMP_DIR=$(mktemp -d)

wget -O "$TMP_DIR/discord.deb" "https://discord.com/api/download?platform=linux&format=deb"

sudo apt install -y "$TMP_DIR/discord.deb"

rm "$TMP_DIR/discord.deb"
rmdir "$TMP_DIR"

echo "Done!"