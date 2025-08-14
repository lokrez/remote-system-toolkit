#!/usr/bin/env bash
# ==============================================================================
# lib/iso_management.sh
#
# This library contains functions for managing the ISO build process,
# including mounting, copying, and creating the final ISO image.
# ==============================================================================

# Use Bash strict mode
set -euo pipefail

# --- Function to mount the base ISO ---
function mount_iso {
    local iso_file="$1"
    local mount_dir="$2"
    echo "--- Mounting ISO: $iso_file ---"
    sudo mkdir -p "$mount_dir"
    sudo mount -o loop "$iso_file" "$mount_dir"
}

# --- Function to create the final ISO ---
function create_final_iso {
    local work_dir="$1"
    local output_iso="$2"
    echo "--- Creating final ISO: $output_iso ---"
    
    # In a real version, this command would be more complex and dynamic.
    sudo xorriso -as mkisofs \
        -r \
        -V "RSToolkit" \
        -o "$output_iso" \
        -J -l -b boot/grub/i386-pc/eltorito.img \
        -no-emul-boot -boot-load-size 4 -boot-info-table \
        --grub2-boot-info \
        -eltorito-alt-boot \
        -e '--boot/grub/efi.img' \
        -no-emul-boot \
        -isohybrid-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
        "$work_dir"
}

# --- Function to clean up temporary files ---
function cleanup_build_dirs {
    local mount_dir="$1"
    local work_dir="$2"
    echo "--- Cleaning up temporary build directories ---"
    if [ -d "$mount_dir" ]; then
        echo "Unmounting $mount_dir"
        sudo umount "$mount_dir" || true
        sudo rm -rf "$mount_dir"
    fi
    if [ -d "$work_dir" ]; then
        echo "Removing work directory: $work_dir"
        sudo rm -rf "$work_dir"
    fi
    echo "Cleanup complete."
}

