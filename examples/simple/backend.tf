terraform {
  backend "gcs" {
    bucket = "your-terraform-state-bucket"
    prefix = "terraform/gke-cluster"
    
    # Optional: Enable state locking and consistency checking
    # This requires the bucket to have object versioning enabled
    # See: https://cloud.google.com/storage/docs/object-versioning
  }
}

# Note: Before using this backend configuration:
# 1. Create the GCS bucket: ./scripts/create-state-bucket.sh
# 2. Update the bucket name above to match your created bucket
# 3. Initialize with: terraform init -migrate-state (if migrating from local state)