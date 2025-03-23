# Auto-Scaling Architecture

This document explains the architecture of the auto-scaling system that migrates a web application between a local VM and Google Cloud Platform (GCP) based on resource utilization.

## System Overview

The architecture enables automatic scaling of a containerized web application from a local VM to GCP when CPU usage exceeds 75%, and migration back to the local VM when usage drops below 40%. This approach optimizes resource utilization and demonstrates live migration capabilities.

## Architecture Diagram

![architecture](https://github.com/user-attachments/assets/58122407-4008-4433-9538-8020832ec876)


## Architecture Components

### Local Machine
- **Host OS**: Runs VirtualBox for VM creation and management
- **VirtualBox**: Provides virtualization for running the Lubuntu VM
- **Port Forwarding**: Routes traffic from host ports to guest VM ports
  - SSH: Host port 2222 → Guest port 22
  - Web App: Host port 8080 → Guest port 80

### Local VM (Lubuntu)
- **Guest OS**: Lubuntu - lightweight Linux distribution
- **Docker**: Containerization platform for the web application
- **Web Application**: Flask-based application with CPU load simulation capabilities
- **Monitoring Stack**: 
  - htop: Real-time CPU monitoring
  - Autoscaling script: Monitors CPU and triggers migration when thresholds are crossed

### Google Cloud Platform (GCP)
- **GCP VM**: Automatically created when local CPU exceeds 75%
- **Service Account**: Provides authentication for GCP API access
- **GCP Cloud Storage**: Stores application data and state for migration
- **GCP APIs**: Compute Engine API for VM creation/deletion

### Connectivity & Authentication
- **SSH Access**: User connects to local VM via SSH (port 2222)
- **Service Account Authentication**: JSON key file for secure GCP access
- **Docker Network**: Internal network for container communication

## Data Flow

1. **Monitoring Phase**:
   - Autoscaling script continuously monitors local VM CPU usage
   - Web application runs in Docker container on port 80
   - User accesses application via port forwarding (8080 → 80)

2. **Auto-Scaling Trigger** (CPU > 75%):
   - Script detects high CPU usage
   - Authenticates with GCP using service account
   - Creates new VM instance in GCP
   - Deploys application container on GCP VM
   - Redirects traffic to GCP instance

3. **Live Migration Back** (CPU < 40%):
   - Script detects reduced CPU usage
   - Migrates application state back to local VM
   - Terminates GCP VM instance
   - Redirects traffic back to local VM


The system demonstrates two key cloud computing concepts:
1. **Auto-scaling**: Dynamic resource allocation based on demand
2. **Live Migration**: Movement of running application with minimal downtime

The architecture is designed to be demonstrative of these concepts while maintaining simplicity.
