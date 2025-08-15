#!/usr/bin/env bash
# ==============================================================================
# build.sh
#
# This is the main orchestrator script for the Remote System Toolkit.
# It calls functions from various modules to perform the build process.
# ==============================================================================

# Use Bash strict mode
set -euo pipefail

# --- Sourcing Libraries ---
# All of our modular scripts will be sourced here.
source lib/dependencies.sh
source lib/prompts.sh
source lib/download.sh

# --- Global Variables ---
# This section defines global variables for the script's state.
MODE="interactive"  # Can be 'interactive' or 'cli'
DISTRO=""           # e.g., 'ubuntu'
FLAVOR=""           # e.g., 'server'
DEVICE=""           # e.g., '/dev/sdc'
ISO_PATH=""         # The path to the downloaded ISO file

# --- Main Functions ---

function show_usage {
    echo "Usage: $0 [options]"
    echo ""
    echo "This script builds a custom, bootable ISO for the Remote System Toolkit."
    echo ""
    echo "Options:"
    echo "  -h, --help           Display this help message and exit."
    echo "  -b, --basic          Run in basic mode with minimal prompts."
    echo "  --distro <name>      Specify the base OS (e.g., 'ubuntu')."
    echo "  --flavor <name>      Specify the OS flavor (e.g., 'server')."
    echo "  --device <path>      Specify the target device to write the ISO to."
    echo ""
    echo "Example: sudo ./build.sh --distro ubuntu --flavor server --device /dev/sdc"
    echo ""
}

# --- Function to parse command-line arguments ---
function parse_cli_args {
    # We will use this function to parse command-line arguments and set our global variables.
    # The whiptail wizard will only be launched if no arguments are provided.
    echo "--- Parsing command-line arguments ---"
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                exit 0
                ;;
            -b|--basic)
                MODE="basic"
                shift
                ;;
            --distro)
                DISTRO="$2"
                shift 2
                ;;
            --flavor)
                FLAVOR="$2"
                shift 2
                ;;
            --device)
                DEVICE="$2"
                shift 2
                ;;
            *)
                echo "Error: Invalid argument: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # If any arguments were provided, we switch to CLI mode.
    if [[ -n "$DISTRO" || -n "$FLAVOR" || -n "$DEVICE" ]]; then
        MODE="cli"
    fi
}

# --- Function to handle ISO download and verification ---
function handle_download_and_verify {
    echo "--- Downloading and verifying base ISO ---"
    local iso_name="ubuntu-server.iso"
    local checksum_file="ubuntu-server.sha256"

    # In a real app, this would be dynamic and use our 'intelligent parsing' logic.
    local url_list=("https://releases.ubuntu.com/jammy/ubuntu-22.04.5-live-server-amd64.iso" "https://mirrors.example.com/ubuntu-22.04.5.iso")

    # Download the ISO
    download_with_fallback "${url_list[@]}" "$iso_name"

    # Verify the checksum
    verify_checksum "$iso_name" "$checksum_file"

    ISO_PATH="$iso_name"
    echo "ISO is ready at: $ISO_PATH"
}

# --- Function to run the whiptail wizard ---
function run_whiptail_wizard {
    # This function will contain all the logic for our interactive wizard.
    # It will call functions from the prompts module to present menus to the user.
    echo "--- Running interactive whiptail wizard ---"
    local main_choice
    main_choice=$(show_main_menu)

    if [[ "$main_choice" == "1" ]]; then
        local distro_choice
        distro_choice=$(show_distro_menu)
        echo "User selected: $distro_choice"
        # We can add more prompts here in the future.
    fi
}

function main {
    # --- Step 1: Pre-flight Checks ---
    # We call our pre-flight check functions from the dependencies module here.
    # This ensures the build environment is ready before any work begins.
    check_root_privileges
    check_dependencies

    # --- Step 2: Main Logic ---
    # This is where the core logic of the script will live.
    parse_cli_args "$@"

    if [[ "$MODE" == "interactive" ]]; then
        run_whiptail_wizard
    else
        echo "--- Running in CLI mode ---"
        # In the future, this section will contain the logic for the
        # headless build process.
    fi

    echo "--- Build process finished successfully ---"
}

# --- Main Script Execution ---
# We will call the main function to start the script.
main "$@"

