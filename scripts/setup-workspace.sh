#!/bin/bash

# Script to set up a new Terraform workspace with remote state
# Usage: ./scripts/setup-workspace.sh [ENVIRONMENT] [PROJECT_ID] [REGION]

set -e

# Default values
DEFAULT_PROJECT_ID=$(gcloud config get-value project 2>/dev/null || echo "")
DEFAULT_REGION="us-central1"
DEFAULT_ENVIRONMENT="dev"

# Parse arguments
ENVIRONMENT=${1:-$DEFAULT_ENVIRONMENT}
PROJECT_ID=${2:-$DEFAULT_PROJECT_ID}
REGION=${3:-$DEFAULT_REGION}

# Validate inputs
if [[ -z "$PROJECT_ID" ]]; then
    echo "Error: PROJECT_ID is required"
    echo "Usage: $0 [ENVIRONMENT] [PROJECT_ID] [REGION]"
    echo "Example: $0 dev my-project us-central1"
    exit 1
fi

BUCKET_NAME="${PROJECT_ID}-terraform-state"
WORKSPACE_DIR="workspaces/${ENVIRONMENT}"

echo "Setting up Terraform workspace..."
echo "Environment: $ENVIRONMENT"
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"
echo "Workspace Directory: $WORKSPACE_DIR"
echo ""

# Create workspace directory
mkdir -p "$WORKSPACE_DIR"

# Create the state bucket if it doesn't exist
echo "Setting up state bucket..."
./scripts/create-state-bucket.sh "$PROJECT_ID" "$BUCKET_NAME" "$REGION"

# Copy example files to workspace
echo "Setting up workspace files..."

# Copy terraform files
cp examples/simple/*.tf "$WORKSPACE_DIR/"
cp examples/simple/terraform.tfvars.example "$WORKSPACE_DIR/"

# Create environment-specific backend configuration
cat > "$WORKSPACE_DIR/backend.tf" << EOF
terraform {
  backend "gcs" {
    bucket = "$BUCKET_NAME"
    prefix = "terraform/$ENVIRONMENT/gke-cluster"
  }
}
EOF

# Create environment-specific tfvars
cat > "$WORKSPACE_DIR/terraform.tfvars" << EOF
# Environment: $ENVIRONMENT
# Project: $PROJECT_ID

# GCP Configuration
project_id = "$PROJECT_ID"
region     = "$REGION"
zone       = "${REGION}-a"

# Cluster Configuration
cluster_name = "$ENVIRONMENT-gke-cluster"
environment  = "$ENVIRONMENT"

# Node Configuration (adjust as needed)
node_count   = 3
machine_type = "e2-medium"
disk_size_gb = 20
preemptible  = true

# Monitoring Configuration
monitoring_namespace   = "monitoring"
grafana_admin_password = "CHANGE-ME-PLEASE"  # TODO: Change this!
prometheus_retention   = "7d"

# Storage Configuration
prometheus_storage_size = "8Gi"
grafana_storage_size    = "2Gi"
EOF

echo ""
echo "✅ Workspace setup complete!"
echo ""
echo "Workspace location: $WORKSPACE_DIR"
echo ""
echo "Next steps:"
echo "1. Navigate to the workspace:"
echo "   cd $WORKSPACE_DIR"
echo ""
echo "2. IMPORTANT: Update terraform.tfvars with secure passwords:"
echo "   # Change grafana_admin_password to a secure value"
echo ""
echo "3. Initialize Terraform:"
echo "   terraform init"
echo ""
echo "4. Plan and apply:"
echo "   terraform plan"
echo "   terraform apply"
echo ""
echo "Note: The state will be stored in gs://$BUCKET_NAME/terraform/$ENVIRONMENT/gke-cluster/"