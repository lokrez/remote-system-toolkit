#!/usr/bin/env bash
# ==============================================================================
# lib/dependencies.sh
#
# This library contains functions to check for required dependencies and
# verify root privileges for the build script.
# ==============================================================================

# Use Bash strict mode
set -euo pipefail

# --- Function to display an error and exit ---
# This is a helper function to ensure a consistent error message format.
function die {
    echo -e "\n\033[0;31mERROR:\033[0m $1" >&2
    exit 1
}

# --- Function to check for required dependencies ---
function check_dependencies {
    echo "--- Verifying system dependencies ---"
    
    # List of required commands for the main build script.
    # `whiptail` for the wizard, `curl` for downloads, `rsync` for file syncing,
    # `xorriso` for ISO creation, and `git` for versioning.
    local dependencies=("whiptail" "curl" "rsync" "xorriso" "git" "python3")
    local missing_deps=()

    # Loop through the array and check for each command
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    # If any dependencies are missing, print a clear error and exit
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "\n\033[0;31mERROR:\033[0m The following required tools are not installed:" >&2
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep" >&2
        done
        die "Please install these packages and try again."
    fi

    echo -e "\033[0;32mAll dependencies are installed.\033[0m"
}

# --- Function to check for root privileges ---
function check_root_privileges {
    echo "--- Checking for root privileges ---"
    if [[ $EUID -ne 0 ]]; then
        die "This script must be run with root privileges (sudo). Please run: sudo ./build.sh"
    fi
    echo -e "\033[0;32mRoot privileges confirmed.\033[0m"
}

