# backend.py - A minimal Flask web server for the Remote System Toolkit

import json
import os
from flask import Flask, jsonify

app = Flask(__name__)

# --- Configuration Variables ---
# In a full project, this would be fetched from a remote source
# For this prototype, we'll serve the existing fallback data.
FALLBACK_DISTROS = [
    {
        "name": "Ubuntu Server",
        "versions": [
            {"version": "24.04 LTS", "flavors": [
                {"name": "Minimal", "url": "https://releases.ubuntu.com/24.04/ubuntu-24.04-live-server-amd64.iso"}
            ]},
            {"version": "22.04 LTS", "flavors": [
                {"name": "Minimal", "url": "https://releases.ubuntu.com/22.04/ubuntu-22.04-live-server-amd64.iso"}
            ]}
        ]
    },
    {
        "name": "Fedora Server",
        "versions": [
            {"version": "40", "flavors": [
                {"name": "Minimal", "url": "https://download.fedoraproject.org/pub/fedora/linux/releases/40/Server/x86_64/iso/Fedora-Server-dvd-x86_64-40-1.14.iso"}
            ]},
            {"version": "39", "flavors": [
                {"name": "Minimal", "url": "https://download.fedoraproject.org/pub/fedora/linux/releases/39/Server/x86_64/iso/Fedora-Server-dvd-x86_64-39-1.14.iso"}
            ]}
        ]
    },
    {
        "name": "Arch Linux",
        "versions": [
            {"version": "Latest", "flavors": [
                {"name": "Latest ISO", "url": "https://mirrors.kernel.org/archlinux/iso/latest/archlinux-x86_64.iso"}
            ]}
        ]
    }
]

# --- API Endpoints ---
@app.route('/api/v1/distros', methods=['GET'])
def get_distros():
    """
    GET /api/v1/distros
    Returns a list of available OS distributions in JSON format.
    """
    # This simulates fetching the list from a remote source or a local file.
    # For now, it simply returns the hardcoded list.
    return jsonify(FALLBACK_DISTROS)

if __name__ == '__main__':
    # This will run the server on all network interfaces on port 5000.
    # The web UI can then connect to this address.
    app.run(host='0.0.0.0', port=5000)

