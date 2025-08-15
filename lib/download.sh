#!/usr/bin/env bash
# ==============================================================================
# lib/download.sh
#
# This library contains functions for downloading ISO files and verifying their
# checksums. It is designed to be resilient and secure.
# ==============================================================================

# Use Bash strict mode
set -euo pipefail

# --- Function to download a file with multi-mirror fallback ---
function download_with_fallback {
    local url_list=("$@")
    local output_file=""
    local success=false

    # The last argument is the output file name
    output_file="${url_list[-1]}"
    unset 'url_list[${#url_list[@]}-1]'

    for url in "${url_list[@]}"; do
        echo "Attempting download from: $url"
        if curl -L --fail --progress-bar -o "$output_file" "$url"; then
            echo "Download successful."
            success=true
            break
        else
            echo "Download failed. Trying next mirror..."
        fi
    done

    if ! $success; then
        die "All download mirrors failed. Unable to get the file."
    fi
}

# --- Function to verify the checksum of a file ---
function verify_checksum {
    local file_path="$1"
    local checksum_file="$2"
    local checksum_algo=$(grep -oE '^(md5|sha256|sha512)' "$checksum_file" | head -n 1)

    if [[ -z "$checksum_algo" ]]; then
        echo "Warning: Could not determine checksum algorithm from file. Skipping verification."
        return 0
    fi

    echo "Verifying checksum for $file_path using $checksum_algo..."
    case "$checksum_algo" in
        "md5")
            if md5sum --status --check "$checksum_file" &> /dev/null; then
                echo "Checksum verified successfully."
                return 0
            fi
            ;;
        "sha256")
            if sha256sum --status --check "$checksum_file" &> /dev/null; then
                echo "Checksum verified successfully."
                return 0
            fi
            ;;
        "sha512")
            if sha512sum --status --check "$checksum_file" &> /dev/null; then
                echo "Checksum verified successfully."
                return 0
            fi
            ;;
    esac

    die "Checksum mismatch. The file may be corrupt or tampered with."
}

