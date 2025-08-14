#!/bin/bash

# ==============================================================================
# SCRIPT: inject-version.sh
# AUTHOR: Gemini
# DESCRIPTION: This script gets the latest Git commit hash and creates a
#              temporary, version-stamped copy of index.html.
# USAGE: ./inject-version.sh <output_file_path>
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if an output file path was provided
if [ -z "$1" ]; then
    echo "Error: Output file path must be provided as an argument." >&2
    exit 1
fi
OUTPUT_FILE="$1"

# --- Get the latest Git commit hash ---
GIT_VERSION=$(git rev-parse --short HEAD)

# --- Check if Git is available and a version was retrieved ---
if [ -z "$GIT_VERSION" ]; then
    echo "Error: Could not get Git version. Is this a Git repository?" >&2
    exit 1
fi

# --- Check if the source index.html file exists ---
SOURCE_HTML="index.html"
if [ ! -f "$SOURCE_HTML" ]; then
    echo "Error: Source file 'index.html' not found." >&2
    exit 1
fi

echo "Creating a temporary, version-stamped HTML file at: $OUTPUT_FILE"

# Copy the original index.html to the temporary location
cp "$SOURCE_HTML" "$OUTPUT_FILE"

# Use sed to replace the version placeholder with the actual Git version
# This finds `const appVersion = "v0.0.1-alpha";` and replaces it
sed -i "s/const appVersion = \"v0.0.1-alpha\";/const appVersion = \"$GIT_VERSION\";/" "$OUTPUT_FILE"

echo "Version injection complete. Original file 'index.html' is unchanged."

