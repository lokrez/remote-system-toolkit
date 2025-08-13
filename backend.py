# backend.py - A minimal Flask web server for the Remote System Toolkit

import json
import os
from flask import Flask, jsonify, request
import time
import random

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

FALLBACK_DEVICES = [
    {"name": "/dev/sda", "description": "512 GB M.2 SSD (System)", "is_removable": False},
    {"name": "/dev/sdb", "description": "2 TB M.2 SSD (Data)", "is_removable": False},
    {"name": "/dev/sdc", "description": "8 GB USB Drive", "is_removable": True}
]

# --- Helper Functions ---
def fetch_distro_list():
    """Simulates fetching the latest distro list from a remote server."""
    return FALLBACK_DISTROS

def fetch_storage_devices():
    """
    Simulates scanning the system for all connected block devices.
    In a production version, this would call a system command like `lsblk`
    and parse the output into a structured format.
    """
    return FALLBACK_DEVICES

def run_install_script(distro_url, target_device):
    """
    Placeholder for the actual installation script logic.
    In a real application, this would call a secure shell script
    and handle the output.
    """
    print(f"Simulating installation of {distro_url} on {target_device}")
    return {"status": "started", "job_id": f"job-{random.randint(1000, 9999)}"}

# --- API Endpoints ---
@app.route('/api/v1/distros', methods=['GET'])
def get_distros():
    """
    GET /api/v1/distros
    Returns a list of available OS distributions in JSON format.
    """
    return jsonify(fetch_distro_list())

@app.route('/api/v1/storage', methods=['GET'])
def get_storage():
    """
    GET /api/v1/storage
    Returns a list of all connected storage devices.
    """
    return jsonify(fetch_storage_devices())

@app.route('/api/v1/install', methods=['POST'])
def install_os():
    """
    POST /api/v1/install
    Handles a request to install an OS.
    The request body is expected to be a JSON object with 'url' and 'device'.
    """
    data = request.get_json()
    if not data or 'url' not in data or 'device' not in data:
        return jsonify({"error": "Missing required parameters: 'url' and 'device'."}), 400

    distro_url = data['url']
    target_device = data['device']

    # In a real application, you would perform extensive input validation here
    # to prevent command injection before calling the shell script.
    
    # Run the installation script in a non-blocking way
    result = run_install_script(distro_url, target_device)

    return jsonify(result), 202 # Return 202 Accepted, as the job is now running in the background

@app.route('/')
def index():
    return "Remote System Toolkit Backend is running."

if __name__ == '__main__':
    # This will run the server on all network interfaces on port 5000.
    # The web UI can then connect to this address.
    app.run(host='0.0.0.0', port=5000)


