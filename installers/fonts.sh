#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e
set -o pipefail

# Use trap to ensure cleanup happens even if the script exits prematurely
trap "rm -rf $TEMP_DIR" EXIT

# Create temporary directory
TEMP_DIR=$(mktemp -d)
echo "Using temporary directory: ${TEMP_DIR}"

# Variables
REQUIREMENTS="curl fc-cache mkdir mktemp unzip"
LOCAL_FONTS_DIR="${HOME}/.local/share/fonts"
JETBRAINS_MONO="https://api.github.com/repos/JetBrains/JetBrainsMono/releases/latest"
JETBRAINS_NERDFONT="https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"

# Check requirements
echo "Checking requirements..."
for tool in ${REQUIREMENTS}; do
    echo -n "${tool}... "
    if command -v "${tool}" >/dev/null 2>&1; then
        echo "Found"
    else
        echo "Not found. Please install \"${tool}\" to fix it."
        exit 1
    fi
done


# Download the fonts
JETBRAINS_MONO_URL=$(curl -s "${JETBRAINS_MONO}" | grep -oP 'https://.+?JetBrainsMono.+\.zip(?=")')
echo "Downloading fonts archive: ${JETBRAINS_MONO_URL}"
wget "${JETBRAINS_MONO_URL}" -O "${TEMP_DIR}/jetbrainsmono.zip" || { echo "Unable to download: ${JETBRAINS_MONO_URL}"; exit 1; }

JETBRAINS_NERDFONT_URL=$(curl -s "${JETBRAINS_NERDFONT}" | grep -oP 'https://.+?JetBrainsMono.zip(?=")')
echo "Downloading fonts archive: ${JETBRAINS_NERDFONT_URL}"
wget "${JETBRAINS_NERDFONT_URL}" -O "${TEMP_DIR}/jetbrainsnerdfont.zip" || { echo "Unable to download: ${JETBRAINS_NERDFONT_URL}"; exit 1; }

# Creating fonts directory
if [ ! -d "${LOCAL_FONTS_DIR}" ]; then
    echo "Creating fonts directory: ${LOCAL_FONTS_DIR}"
    mkdir -p "${LOCAL_FONTS_DIR}" || { echo "Unable to create fonts directory: ${LOCAL_FONTS_DIR}"; exit 1; }
fi

# Extracting fonts
echo "Extracting fonts: ${LOCAL_FONTS_DIR}"
unzip -o "${TEMP_DIR}/jetbrainsmono.zip" -d "${LOCAL_FONTS_DIR}" > /dev/null 2>&1
unzip -o "${TEMP_DIR}/jetbrainsnerdfont.zip" -d "${LOCAL_FONTS_DIR}" > /dev/null 2>&1

# Building fonts cache
echo "Building fonts cache..."
fc-cache -f || { echo "Unable to build fonts cache"; exit 1; }

echo "Fonts have been installed"
