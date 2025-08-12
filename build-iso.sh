#!/usr/bin/env bash

# ==============================================================================
# SCRIPT TO BUILD A CUSTOM BOOTABLE ISO IMAGE FOR THE REMOTE SYSTEM TOOLKIT
#
# This script automates the process of creating a custom bootable ISO by
# downloading a minimal base image, extracting its contents, injecting our
# custom scripts and UI, and then repackaging it into a new ISO.
#
# WARNING: This script requires root privileges to mount and create files.
# ==============================================================================

# --- Set Bash Strict Mode ---
set -euo pipefail

# --- Configuration Variables ---
# Use a minimal Ubuntu Server netboot ISO as a lightweight base.
BASE_ISO_URL="https://releases.ubuntu.com/jammy/ubuntu-22.04.4-live-server-amd64.iso"
BASE_ISO_NAME="ubuntu-22.04.4-live-server-amd64.iso"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
WORK_DIR="$PROJECT_DIR/build"
OUTPUT_ISO="remote-system-toolkit.iso"

# --- Toolkit Files ---
# These are the files from your project that we will inject into the ISO.
CUSTOM_FILES=(
    "$PROJECT_DIR/rstool.py"
    "$PROJECT_DIR/bootable-recovery-ui.html"
    "$PROJECT_DIR/bash-dd-script-v2.sh"
)

# --- Function to display an error message and exit ---
function die {
    echo -e "\n\033[0;31mERROR:\033[0m $1" >&2
    exit 1
}

# --- Function to check for required dependencies ---
function check_dependencies {
    local missing_deps=()
    local deps=("curl" "mount" "genisoimage" "xorriso")
    
    echo "--- Checking for required dependencies ---"
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "\n\033[0;31mERROR:\033[0m The following required utilities are not installed:" >&2
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep" >&2
        fi
        die "Please install these packages manually (e.g., 'sudo apt install genisoimage') and try again."
    fi
    echo -e "\033[0;32mAll dependencies are installed.\033[0m"
}

# --- Function to download the base ISO ---
function get_base_iso {
    if [ -f "$PROJECT_DIR/$BASE_ISO_NAME" ]; then
        echo "Base ISO already exists at '$PROJECT_DIR/$BASE_ISO_NAME'. Skipping download."
    else
        echo "--- Downloading base ISO from '$BASE_ISO_URL' ---"
        if ! curl -L -o "$PROJECT_DIR/$BASE_ISO_NAME" "$BASE_ISO_URL" --progress-bar; then
            die "Failed to download the base ISO. Please check your network connection."
        fi
        echo -e "\n\033[0;32mDownload successful!\033[0m"
    fi
}

# --- Function to create the custom ISO ---
function build_iso {
    echo "--- Building custom ISO image ---"
    
    # 1. Create a working directory
    echo "Creating working directory: '$WORK_DIR'..."
    mkdir -p "$WORK_DIR/iso_contents" "$WORK_DIR/mount_point"
    
    # 2. Mount the base ISO
    echo "Mounting base ISO..."
    if ! mount -o loop "$PROJECT_DIR/$BASE_ISO_NAME" "$WORK_DIR/mount_point"; then
        die "Failed to mount the base ISO. Check for existing mounts or file corruption."
    fi
    
    # 3. Copy contents to working directory
    echo "Copying base ISO contents..."
    if ! rsync -a --progress "$WORK_DIR/mount_point/" "$WORK_DIR/iso_contents/"; then
        die "Failed to copy ISO contents."
    fi
    
    # 4. Unmount the base ISO
    echo "Unmounting base ISO..."
    if ! umount "$WORK_DIR/mount_point"; then
        die "Failed to unmount. Please unmount manually: 'sudo umount $WORK_DIR/mount_point'"
    fi
    
    # 5. Inject custom files and scripts
    echo "Injecting custom toolkit files..."
    CUSTOM_DEST_DIR="$WORK_DIR/iso_contents/toolkit"
    mkdir -p "$CUSTOM_DEST_DIR"
    cp -v "${CUSTOM_FILES[@]}" "$CUSTOM_DEST_DIR/"
    
    # Also inject a simple startup script to launch the UI
    echo "Creating startup script for the UI..."
    echo '#!/bin/bash
    # Simple script to launch the HTML UI
    echo "Starting web server on port 8000..."
    # Python 3 web server is a simple way to serve the HTML file
    cd /toolkit
    python3 -m http.server 8000 &
    # This will prevent the terminal from closing
    echo "The toolkit is available at http://localhost:8000"
    echo "Press Ctrl+C to exit the server and the terminal."
    /bin/bash' > "$WORK_DIR/iso_contents/live/toolkit-start.sh"
    
    chmod +x "$WORK_DIR/iso_contents/live/toolkit-start.sh"
    
    # 6. Modify the bootloader configuration (isolinux)
    echo "Modifying bootloader configuration..."
    ISOLINUX_CFG="$WORK_DIR/iso_contents/isolinux/isolinux.cfg"
    if [ -f "$ISOLINUX_CFG" ]; then
        # Create a backup of the original config file.
        cp "$ISOLINUX_CFG" "$ISOLINUX_CFG.bak"
        # Append a new entry to the menu to launch our toolkit.
        sed -i '/^LABEL live/a\
        LABEL toolkit\n\
        MENU LABEL ^Launch Remote System Toolkit\n\
        LINUX /casper/vmlinuz\n\
        INITRD /casper/initrd\n\
        APPEND root=/dev/ram0 ramdisk_size=1048576 rw quiet splash ---\n\
        ' "$ISOLINUX_CFG"
    else
        die "isolinux.cfg not found. Cannot modify bootloader."
    fi
    
    # 7. Create the final ISO image
    echo "Creating final ISO with xorriso..."
    if ! xorriso -as mkisofs \
        -r -V "RSToolkit" \
        -o "$PROJECT_DIR/$OUTPUT_ISO" \
        -J -l -b isolinux/isolinux.bin \
        -c isolinux/boot.cat -no-emul-boot \
        -boot-load-size 4 -boot-info-table \
        -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
        "$WORK_DIR/iso_contents"; then
        die "Failed to create the ISO image with xorriso."
    fi

    # 8. Clean up the temporary files
    echo "Cleaning up temporary files..."
    rm -rf "$WORK_DIR"
    
    echo -e "\n\033[0;32mSuccessfully built '$PROJECT_DIR/$OUTPUT_ISO'!\033[0m"
}

# --- Main function to run the script ---
function main {
    # Check for root privileges
    if [[ $EUID -ne 0 ]]; then
        echo -e "\n\033[0;31m------------------------------------------------------------------\033[0m"
        echo -e "\033[0;31m  ERROR: This script must be run with root privileges (sudo).\033[0m"
        echo -e "\033[0;31m  Please run the following command instead:\033[0m"
        echo -e "\033[0;31m\n    sudo ./$(basename "$0")\n\033[0m"
        echo -e "\033[0;31m------------------------------------------------------------------\n\033[0m"
        exit 1
    fi
    
    check_dependencies
    get_base_iso
    build_iso
    
    echo "The build process is complete. Your bootable ISO is ready."
    echo "You can now use your `bash-dd-script-v2.sh` to write this ISO to a USB drive."
    echo "Example: sudo ./bash-dd-script-v2.sh --iso-file \"$PROJECT_DIR/$OUTPUT_ISO\" --device <your_usb_device>"
}

# --- Run the main function ---
main

