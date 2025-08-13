#!/bin/bash

# --- Function to display script usage ---
function show_usage() {
    echo "Usage: $0 [-u <iso_url>] [-o <output_name>]"
    echo "  -u  URL of the base Ubuntu ISO to download (e.g., 'https://releases.ubuntu.com/jammy/ubuntu-22.04.5-live-server-amd64.iso')"
    echo "  -o  Name for the final custom ISO file (e.g., 'my-custom-ubuntu.iso')"
    echo "If no options are provided, the script will use default values."
}

# --- Define default variables ---
DEFAULT_ISO_URL="https://releases.ubuntu.com/jammy/ubuntu-22.04.5-live-server-amd64.iso"
DEFAULT_OUTPUT_ISO="ubuntu-custom-server-amd64.iso"
ISO_URL=""
OUTPUT_ISO=""
ISO_NAME=""
ISO_MOUNT=""
ISO_WORK=""

# --- Parse command-line arguments ---
while getopts "u:o:h" opt; do
    case ${opt} in
        u )
            ISO_URL="$OPTARG"
            ;;
        o )
            OUTPUT_ISO="$OPTARG"
            ;;
        h )
            show_usage
            exit 0
            ;;
        \? )
            show_usage
            exit 1
            ;;
    esac
done

# Set variables if not provided by arguments
if [ -z "$ISO_URL" ]; then
    ISO_URL="$DEFAULT_ISO_URL"
fi
if [ -z "$OUTPUT_ISO" ]; then
    OUTPUT_ISO="$DEFAULT_OUTPUT_ISO"
fi

# Define the working directory based on the ISO name
# This will be created in the current directory.
ISO_NAME=$(basename "$ISO_URL")
ISO_MOUNT="iso_mount"
ISO_WORK="iso_work"

# --- Main Script Execution ---

# --- Step 1: Clean up previous build directories ---
echo "--- Cleaning up previous build directories ---"
if [ -d "$ISO_MOUNT" ]; then
    echo "Removing previous mount directory: $ISO_MOUNT"
    sudo umount "$ISO_MOUNT" || true  # Use || true to prevent script from failing if not mounted
    sudo rm -rf "$ISO_MOUNT"
fi
if [ -d "$ISO_WORK" ]; then
    echo "Removing previous work directory: $ISO_WORK"
    sudo rm -rf "$ISO_WORK"
fi
echo "Cleanup complete."
echo ""

# --- Step 2: Download the base ISO if it doesn't exist ---
echo "--- Checking for base ISO file ---"
if [ ! -f "$ISO_NAME" ]; then
    echo "Downloading base ISO from: $ISO_URL"
    curl -o "$ISO_NAME" "$ISO_URL"
    echo "Download complete."
else
    echo "Base ISO already exists: $ISO_NAME"
fi
echo ""

# --- Step 3: Mount the ISO and copy its files ---
echo "--- Mounting ISO and copying files ---"
sudo mkdir -p "$ISO_MOUNT" "$ISO_WORK"
sudo mount -o loop "$ISO_NAME" "$ISO_MOUNT"

# Copy files using rsync
sudo rsync -a --progress "$ISO_MOUNT"/ "$ISO_WORK" --delete

echo "--- Unmounting ISO ---"
sudo umount "$ISO_MOUNT"
echo ""

# --- Step 4: Customization step (e.g., adding scripts or files) ---
echo "--- Customization step (e.g., adding scripts or files) ---"
# Call the customize script. We are removing the argument here.
# The customize-iso.sh script no longer takes an argument.
./customize-iso.sh

echo "Customization complete."
echo ""

# --- Step 5: Create the final custom ISO ---
echo "--- Creating the final custom ISO ---"

# The correct xorriso command for modern Ubuntu Live Server ISOs
# The boot paths are hardcoded to the standard locations for Ubuntu 22.04+
sudo xorriso \
    -as mkisofs \
    -r \
    -V "CUSTOM_UBUNTU" \
    -o "$OUTPUT_ISO" \
    -J -l -b boot/grub/i386-pc/eltorito.img \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    --grub2-boot-info \
    -eltorito-alt-boot \
    -e '--boot/grub/efi.img' \
    -no-emul-boot \
    -isohybrid-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
    "$ISO_WORK"

echo "ISO image created: $OUTPUT_ISO"
echo ""

# --- Step 6: Final cleanup ---
echo "--- Final cleanup ---"
# Keep the work directory so we can run the customize script multiple times
# without re-downloading the ISO. You can uncomment the line below to remove it.
# sudo rm -rf "$ISO_WORK"
sudo rm -rf "$ISO_MOUNT"
echo "Cleanup complete."

echo "Build process finished successfully."

