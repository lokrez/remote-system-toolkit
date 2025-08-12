# Conceptual Backend API Design for RST

This document outlines the conceptual design for a secure, robust backend API to support the Remote System Toolkit (RST) web interface. The current `index.html` is a frontend prototype and does not have a functional, secure backend.

## 1. Core Principles

* **Security First:** All backend communication must be authenticated and all user-provided input must be rigorously validated. A generic command execution is a major security risk and will not be implemented.
* **Stateless Endpoints:** The API should be RESTful where possible, with stateless endpoints.
* **Real-time Communication:** For long-running tasks, a persistent connection (e.g., WebSockets) will be used to stream real-time output and status updates back to the frontend.

## 2. API Endpoints

Instead of a generic `runRemoteCommand`, the API will expose specific, vetted endpoints. Each endpoint will have its own authentication and validation logic.

| HTTP Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/v1/distros` | Fetches the list of available OS distributions from a trusted source. |
| `POST` | `/api/v1/install` | Installs a specified OS. The request body must contain a validated URL and target device. |
| `GET` | `/api/v1/storage` | Scans and returns a list of connected storage devices, partitions, and their properties. |
| `POST` | `/api/v1/backup/external` | Initiates a backup to a specified external device. |
| `POST` | `/api/v1/backup/self` | Initiates a backup to a new partition on the same device. |
| `POST` | `/api/v1/restore` | Restores data from a backup. |
| `POST` | `/api/v1/network` | Configures a network interface using validated parameters. |
| `POST` | `/api/v1/filesystem/check` | Runs a file system check on a specified partition. |
| `POST` | `/api/v1/rollback` | Reverts the last major change using a system snapshot. This requires a dedicated snapshotting system. |

## 3. Communication

* The frontend will make an initial `POST` request to an endpoint.
* The backend will perform validation, start the job, and return a unique job ID.
* The frontend will then open a WebSocket connection to `/ws/status/{jobId}` to receive real-time updates (e.g., "Downloading ISO...", "Verifying checksum...").
* Once the job is complete, the WebSocket connection will close, and the frontend will display the final status.

## 4. Input Validation

All data passed to the API must be sanitized and validated. For example:
* **URLs:** Must be checked against a whitelist of trusted mirrors.
* **Device Paths:** Must be validated as valid device files (e.g., `/dev/sdb`) and not arbitrary user input.
* **Network Configs:** Must be checked for valid IP addresses, netmasks, etc.
