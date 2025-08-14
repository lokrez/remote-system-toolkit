#!/bin/bash

# ==============================================================================
# SCRIPT: inject-version.sh
# AUTHOR: Gemini
# DESCRIPTION: This script gets the latest Git commit hash and injects it
#              into the index.html file to be used as a version stamp.
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Get the latest Git commit hash ---
# The --short flag provides a short, 7-character hash, which is ideal for a version stamp.
GIT_VERSION=$(git rev-parse --short HEAD)

# --- Check if Git is available and a version was retrieved ---
if [ -z "$GIT_VERSION" ]; then
    echo "Error: Could not get Git version. Is this a Git repository?" >&2
    exit 1
fi

# --- Find the index.html file and inject the version ---
HTML_FILE="index.html"

if [ ! -f "$HTML_FILE" ]; then
    echo "Error: index.html not found. Cannot inject version." >&2
    exit 1
fi

echo "Injecting version: $GIT_VERSION into $HTML_FILE"

# The sed command finds the `const appVersion = "v0.0.1-alpha";` line
# and replaces "v0.0.1-alpha" with the actual Git version.
sed -i "s/const appVersion = \"v0.0.1-alpha\";/const appVersion = \"$GIT_VERSION\";/" "$HTML_FILE"

echo "Version injection complete."


