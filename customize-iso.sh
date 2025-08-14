#!/bin/bash

# ==============================================================================
# Script to package the Remote System Toolkit (RST) project files into the
# ISO's working directory.
#
# This version assumes the ISO working directory is located at './iso_work'
# and does not require a command-line argument.
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration Variables ---
# Define the source files for the project.
PROJECT_FILES=(
    "rstool.sh"
    "backend_api.md"
    "build-iso.sh"
    "index.html"
)

# Define the destination directory inside the ISO's working directory.
ISO_PROJECT_DIR="opt/rstool"

# Assume the ISO's working directory is a fixed, relative path.
ISO_WORK_DIR="iso_work"

# --- Main Packaging Logic ---
echo "--- Packaging RST project files ---"

# Check if the assumed ISO working directory exists.
if [ ! -d "$ISO_WORK_DIR" ]; then
    echo "Error: The assumed ISO working directory '$ISO_WORK_DIR' does not exist."
    echo "Please run the main build script first to prepare the directory."
    exit 1
fi

# Create the destination directory inside the ISO's working directory.
DEST_DIR="$ISO_WORK_DIR/$ISO_PROJECT_DIR"
echo "Creating project directory: $DEST_DIR"
sudo mkdir -p "$DEST_DIR"

# --- NEW: Create a temporary, version-stamped copy of index.html ---
# The new script injects the version and saves the file to a temporary location.
TEMP_HTML="$ISO_WORK_DIR/index.html"
./inject-version.sh "$TEMP_HTML"

# Copy each project file into the destination directory.
for file in "${PROJECT_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "Copying $file to $DEST_DIR"
        sudo cp "$file" "$DEST_DIR/"
    else
        echo "Warning: File not found - $file. Skipping."
    fi
done

echo "RST project files successfully packaged into the ISO's work directory."

# Optional: Add a custom command to the live system's path.
# This section has been updated to handle the 'File exists' error.
echo "Creating symbolic link for rstool.sh in /usr/local/bin..."
SYMLINK_PATH="$ISO_WORK_DIR/usr/local/bin/rstool"
SYMLINK_TARGET="/$ISO_PROJECT_DIR/rstool.sh"

# Check if the symbolic link already exists and remove it if it does.
if [ -L "$SYMLINK_PATH" ]; then
    echo "Removing existing symbolic link: $SYMLINK_PATH"
    sudo rm "$SYMLINK_PATH"
fi

sudo mkdir -p "$ISO_WORK_DIR/usr/local/bin"
# Create the new symbolic link.
sudo ln -s "$SYMLINK_TARGET" "$SYMLINK_PATH"

echo "Packaging complete."

