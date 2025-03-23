#!/bin/bash

# Variables
THRESHOLD=75            # Upper threshold to start the VM
MIN_THRESHOLD=30         # Lower threshold to stop the VM
INSTANCE_NAME="web-app-instance"
ZONE="asia-south1-a"
MACHINE_TYPE="e2-medium"
IMAGE_FAMILY="ubuntu-2204-lts"
IMAGE_PROJECT="ubuntu-os-cloud"

# Docker configuration
CONTAINER_NAME="container"
LOCAL_PORT=8080
DOCKER_PORT=80
DOCKER_IMAGE="webapp"

# --- Function to check if GCP VM is reachable ---
check_vm_ready() {
    echo "Checking VM status..."
    local retries=15  # Number of retries (30 seconds total)
    local delay=2     # Delay between retries

    for ((i=1; i<=retries; i++)); do
        if gcloud compute ssh "$INSTANCE_NAME" --zone="$ZONE" --strict-host-key-checking=no --command "echo 'VM is ready'" &>/dev/null; then
            echo "✅ VM is reachable!"
            return 0
        else
            echo "Waiting for VM to be reachable... Attempt $i/$retries"
            sleep "$delay"
        fi
    done

    echo "❌ Failed to connect to VM after $((retries * delay)) seconds."
    exit 1
}

# --- Check if the GCP VM exists ---
echo "Checking if GCP VM exists..."
if ! gcloud compute instances describe "$INSTANCE_NAME" --zone="$ZONE" &> /dev/null; then
    echo "GCP VM does not exist. Creating it..."

    # Create the GCP VM
    gcloud compute instances create "$INSTANCE_NAME" \
        --zone="$ZONE" \
        --machine-type="$MACHINE_TYPE" \
        --image-family="$IMAGE_FAMILY" \
        --image-project="$IMAGE_PROJECT" \
        --tags=http-server

    echo "Waiting for VM to start..."
    sleep 30

    # Ensure the VM is reachable before proceeding
    check_vm_ready

    # SSH into the VM and install Docker, pull image, and run container
    echo "Installing Docker and deploying the web app on the new VM..."

    gcloud compute ssh "$INSTANCE_NAME" --zone="$ZONE" --strict-host-key-checking=no --command "
        sudo apt update -y &&
        sudo apt install -y docker.io &&
        sudo systemctl start docker &&
        sudo systemctl enable docker &&
        sudo docker run -d --name $CONTAINER_NAME -p $DOCKER_PORT:$DOCKER_PORT $DOCKER_IMAGE
    "

    echo "✅ Web app deployed successfully on the new GCP VM!"
else
    echo "GCP VM already exists."
fi

# --- CPU Monitoring Section ---

# Get Docker container CPU usage
CONTAINER_CPU=$(docker stats --no-stream --format "{{.CPUPerc}}" "$CONTAINER_NAME" | sed 's/%//')

# Get VM CPU usage
VM_CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')

# Combine CPU usage by adding container and VM CPU usage
TOTAL_CPU=$(echo "$CONTAINER_CPU + $VM_CPU" | bc -l)
echo "Container CPU: $CONTAINER_CPU%"
echo "VM CPU: $VM_CPU%"
echo "Total CPU Usage: $TOTAL_CPU%"

# --- Autoscaling Logic ---
if (( $(echo "$TOTAL_CPU > $THRESHOLD" | bc -l) )); then
    echo "⚠️ High CPU usage detected: $TOTAL_CPU%"

    if gcloud compute instances describe "$INSTANCE_NAME" --zone="$ZONE" &> /dev/null; then
        echo "Starting existing GCP VM: $INSTANCE_NAME"
        gcloud compute instances start "$INSTANCE_NAME" --zone="$ZONE"

        # Wait until the VM is ready
        check_vm_ready

    else
        echo "Creating and starting a new GCP VM: $INSTANCE_NAME"
        gcloud compute instances create "$INSTANCE_NAME" \
            --zone="$ZONE" \
            --machine-type="$MACHINE_TYPE" \
            --image-family="$IMAGE_FAMILY" \
            --image-project="$IMAGE_PROJECT" \
            --tags=http-server

        echo "Installing Docker and deploying web app..."

        gcloud compute ssh "$INSTANCE_NAME" --zone="$ZONE" --strict-host-key-checking=no --command "
            sudo apt update -y &&
            sudo apt install -y docker.io &&
            sudo systemctl start docker &&
            sudo systemctl enable docker &&
            sudo docker run -d --name $CONTAINER_NAME -p $DOCKER_PORT:$DOCKER_PORT $DOCKER_IMAGE
        "

        echo "✅ Web app deployed successfully!"
    fi

elif (( $(echo "$TOTAL_CPU < $MIN_THRESHOLD" | bc -l) )); then
    echo "✅ Low CPU usage detected: $TOTAL_CPU%"
    echo "Stopping GCP VM: $INSTANCE_NAME"
    gcloud compute instances stop "$INSTANCE_NAME" --zone="$ZONE"

else
    echo "✅ CPU usage is within normal range: $TOTAL_CPU%"
fi
