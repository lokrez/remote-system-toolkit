# Remote System Toolkit (RST)

The Remote System Toolkit (RST) is a project designed to provide a comprehensive, dual-interface environment for system recovery and management. It is intended to be used as a live bootable OS, offering a user-friendly web interface for common tasks and a powerful command-line tool (`rstool`) for power users.

This project is a **conceptual prototype** designed to showcase the user interface and functionality. It is not a secure, production-ready application.

This project is released as open source software under the **MIT License**.

## Features

* **Dual-Mode Interface:** A web UI for simple, guided operations and an identical CLI for advanced, scriptable tasks.

* **OS Installation:** A simple interface to download and install popular server operating systems.

* **System Recovery:** Utilities for disk partitioning, file system checks, and data rescue.

* **Data Backup & Restore:** Options to back up data to an external drive or to a dedicated partition on the same drive.

* **Rollback Functionality:** A conceptual feature to revert the system to a previous state after a major operation.

* **Live Bootable Environment:** Designed to run from a USB drive or other bootable media, independent of the target machine's operating system.

## Getting Started

To get started, clone this repository and build a bootable live OS.

1.  **Clone the repository:**
    ```
    git clone https://github.com/your-username/remote-system-toolkit.git
    ```

2.  **Navigate to the project directory:**
    ```
    cd remote-system-toolkit
    ```

3.  **Build a live bootable image:**
    *(This is a conceptual step. You would use a tool like `mkusb` or `live-build` to create a live OS that includes this code and a web server.)*

    The `index.html` file in this repository is the core of the web interface. You would run a lightweight web server on your live OS to serve this file, which would then communicate with the backend `rstool` service.

## Project Structure

* `index.html`: The main web interface for the toolkit.
* `backend_api.md`: A conceptual design document for a secure backend API.
* `rstool.sh`: A conceptual bash script to simulate the command-line tool.
* `README.md`: This file.
* `.gitignore`: Defines files and directories to be ignored by Git.
* `LICENSE`: The MIT License for this project.

## Contributing

We welcome contributions! Please feel free to open issues or submit pull requests.

## Author

* **Developer:** @zerkol
