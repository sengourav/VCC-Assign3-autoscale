
Autoscaling a web application from a local VM to GCP when resource usage reaches 75%, followed by live migration back to the local machine when load decreases.

## Repository Structure

```
VCC-Assign3-autoscale/
├── README.md                  # Project documentation
├── app/                       # Web application files
│   ├── app.py                 # Flask application with CPU loading endpoints
│   ├── requirements.txt       # Python dependencies
│   └── Dockerfile             # Docker configuration for the web app
├── scripts/                   # Automation scripts
│   ├── autoscale.sh           # Main autoscaling script
│   ├── setup_local_vm.sh      # Script to set up the local Lubuntu VM
│   └── install_docker.sh      # Script to install Docker on the VM
├── config/                    # Configuration files
│   ├── port_forwarding.txt    # VirtualBox port forwarding configuration
│   └── gcp_config.json        # GCP configuration (without sensitive data)
├── docs/                      # Documentation
│   ├── VCC_Assignment_3.pdf   # Full project report
│   └── images/                # Screenshots and diagrams
└── .gitignore                 # Git ignore file
```


# VCC Assignment 3: Web Application Autoscaling

**Author:** Gourav Sen (M24CSA011)

This repository contains the implementation for automatically scaling a web application from a local VM to Google Cloud Platform (GCP) based on resource utilization.

## Project Overview

This project demonstrates autoscaling and live migration of a containerized web application:
- When CPU usage exceeds 75% on the local VM, the application is automatically scaled to GCP
- When the load decreases below 40%, the application is migrated back to the local VM
- The entire process is automated using bash scripts and Docker

## Prerequisites

- VirtualBox
- Lubuntu ISO
- Google Cloud SDK
- Docker
- Python/Flask

## Setup Instructions

1. Set up the local Lubuntu VM in VirtualBox
   ```bash
   ./scripts/setup_local_vm.sh
   ```

2. Install Docker on the VM
   ```bash
   ./scripts/install_docker.sh
   ```

3. Configure GCP service account and authentication
   - Create a service account with appropriate permissions
   - Download the JSON key file
   - Authenticate using: `gcloud auth activate-service-account --key-file=KEY_FILE`

4. Build and run the Docker container
   ```bash
   cd app
   docker build -t webapp .
   docker run -d -p 80:80 --name container webapp
   ```

5. Run the autoscaling script
   ```bash
   ./scripts/autoscale.sh
   ```

## Application Testing

- Access the web application: http://127.0.0.1:8080
- Generate load: http://127.0.0.1:8080/load
- Stop the load: http://127.0.0.1:8080/stop

## Demo

For a video demonstration, visit [this link](https://drive.google.com/drive/folders/17_SxUF_noejwMWdBEZ0-EldxOiuTXHCn?usp=sharing)

## Repository Structure Explanation

- `app/`: Contains the web application code including Flask app and Dockerfile
- `scripts/`: Contains automation scripts for setup and monitoring
- `config/`: Configuration files for the project
- `docs/`: Project documentation and images

## License

MIT
