#!/bin/bash

# Script to create a GCS bucket for Terraform state storage
# Usage: ./scripts/create-state-bucket.sh [PROJECT_ID] [BUCKET_NAME] [REGION]

set -e

# Default values
DEFAULT_PROJECT_ID=$(gcloud config get-value project 2>/dev/null || echo "")
DEFAULT_REGION="us-central1"

# Parse arguments
PROJECT_ID=${1:-$DEFAULT_PROJECT_ID}
BUCKET_NAME=${2:-"${PROJECT_ID}-terraform-state"}
REGION=${3:-$DEFAULT_REGION}

# Validate inputs
if [[ -z "$PROJECT_ID" ]]; then
    echo "Error: PROJECT_ID is required"
    echo "Usage: $0 [PROJECT_ID] [BUCKET_NAME] [REGION]"
    echo "Example: $0 my-project my-project-terraform-state us-central1"
    exit 1
fi

if [[ -z "$BUCKET_NAME" ]]; then
    echo "Error: BUCKET_NAME is required"
    exit 1
fi

echo "Creating Terraform state bucket..."
echo "Project ID: $PROJECT_ID"
echo "Bucket Name: $BUCKET_NAME"
echo "Region: $REGION"
echo ""

# Check if bucket already exists
if gsutil ls -b gs://"$BUCKET_NAME" &>/dev/null; then
    echo "Bucket gs://$BUCKET_NAME already exists"
else
    echo "Creating bucket gs://$BUCKET_NAME..."
    
    # Create the bucket
    gsutil mb -p "$PROJECT_ID" -l "$REGION" gs://"$BUCKET_NAME"
    
    echo "Bucket created successfully"
fi

# Enable versioning for state locking and recovery
echo "Enabling versioning on bucket..."
gsutil versioning set on gs://"$BUCKET_NAME"

# Set lifecycle policy to clean up old versions
echo "Setting lifecycle policy to clean up old state versions..."
cat > /tmp/lifecycle.json << EOF
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {
          "age": 30,
          "isLive": false
        }
      }
    ]
  }
}
EOF

gsutil lifecycle set /tmp/lifecycle.json gs://"$BUCKET_NAME"
rm /tmp/lifecycle.json

# Set bucket permissions (optional - adjust as needed)
echo "Setting bucket permissions..."

# Make bucket private (recommended for state files)
gsutil iam ch allUsers:objectViewer gs://"$BUCKET_NAME" 2>/dev/null || true
gsutil iam ch -d allUsers:objectViewer gs://"$BUCKET_NAME" 2>/dev/null || true

echo ""
echo "✅ Terraform state bucket setup complete!"
echo ""
echo "Bucket details:"
echo "  Name: gs://$BUCKET_NAME"
echo "  Project: $PROJECT_ID"
echo "  Region: $REGION"
echo "  Versioning: Enabled"
echo "  Lifecycle: Delete non-current versions after 30 days"
echo ""
echo "Next steps:"
echo "1. Update your backend.tf file:"
echo "   terraform {"
echo "     backend \"gcs\" {"
echo "       bucket = \"$BUCKET_NAME\""
echo "       prefix = \"terraform/your-environment\""
echo "     }"
echo "   }"
echo ""
echo "2. Initialize Terraform with the new backend:"
echo "   terraform init"
echo ""
echo "3. If migrating from local state:"
echo "   terraform init -migrate-state"