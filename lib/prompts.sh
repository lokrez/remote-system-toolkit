#!/usr/bin/env bash
# ==============================================================================
# lib/prompts.sh
#
# This library contains functions for the whiptail-based interactive prompts.
# It is used by the main build.sh script to guide the user through the
# build process.
# ==============================================================================

# Use Bash strict mode
set -euo pipefail

# --- Global Variables ---
# We will define a list of distributions that will be used by our menus.
# This list will be dynamically fetched in a future version.
declare -A DISTROS
DISTROS[ubuntu]="Ubuntu Server"
DISTROS[fedora]="Fedora Server"
DISTROS[arch]="Arch Linux"

# --- Function to show the main menu ---
function show_main_menu {
    local choice
    choice=$(whiptail --title "Remote System Toolkit" --menu "Choose an action:" 20 78 10 \
        "1" "Build a custom ISO (Interactive Wizard)" \
        "2" "Help" \
        3>&1 1>&2 2>&3)
    echo "$choice"
}

# --- Function to show the distro selection menu ---
function show_distro_menu {
    local choice
    local options=(
        "ubuntu" "${DISTROS[ubuntu]}"
        "fedora" "${DISTROS[fedora]}"
        "arch" "${DISTROS[arch]}"
    )
    choice=$(whiptail --title "Base OS Selection" --menu "Choose a base distribution:" 20 78 10 "${options[@]}" 3>&1 1>&2 2>&3)
    echo "$choice"
}

# --- Function to show a simple yes/no prompt ---
function show_yesno_prompt {
    local message="$1"
    whiptail --title "Confirmation" --yesno "$message" 10 60
}

# --- Function to get a string input ---
function get_string_input {
    local prompt="$1"
    local default_value="$2"
