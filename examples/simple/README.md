# Simple GKE Cluster with Monitoring

This example creates a basic GKE cluster with Prometheus and Grafana monitoring.

## What This Example Creates

- GKE cluster with 3 preemptible nodes
- Prometheus for metrics collection
- Grafana for visualization
- Pre-configured dashboards

## Usage

1. **Setup state storage** (first time only):
   ```bash
   # From project root
   ./scripts/create-state-bucket.sh my-project my-project-terraform-state us-central1
   ```

2. **Copy the example configuration**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   cp backend.tf.example backend.tf
   ```

3. **Edit configuration files**:
   
   **terraform.tfvars**:
   ```hcl
   # Required
   grafana_admin_password = "your-secure-password"
   
   # Optional customizations
   cluster_name = "my-test-cluster"
   region       = "us-central1"
   zone         = "us-central1-a"
   node_count   = 3
   ```
   
   **backend.tf**:
   ```hcl
   terraform {
     backend "gcs" {
       bucket = "my-project-terraform-state"
       prefix = "terraform/dev/gke-cluster"
     }
   }
   ```

4. **Deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

5. **Connect to cluster**:
   ```bash
   # Use the command from terraform output
   gcloud container clusters get-credentials CLUSTER_NAME --zone ZONE --project PROJECT_ID
   ```

6. **Access monitoring**:
   ```bash
   # Prometheus
   kubectl port-forward -n monitoring svc/prometheus-server 9090:80
   
   # Grafana
   kubectl port-forward -n monitoring svc/grafana 3000:80
   ```

## Alternative: Automated Setup

Use the workspace setup script for faster deployment:

```bash
# From project root
./scripts/setup-workspace.sh dev my-project us-central1
cd workspaces/dev
# Edit terraform.tfvars to set secure passwords
terraform init
terraform plan
terraform apply
```

## Configuration Options

### Cost Optimization
```hcl
# Use smaller instances
machine_type = "e2-small"
disk_size_gb = 10

# Enable autoscaling to scale down when not needed
enable_autoscaling = true
min_node_count     = 1
max_node_count     = 5
```

### Production Settings
```hcl
# Use regular (non-preemptible) nodes
preemptible = false

# Larger instances
machine_type = "e2-standard-4"
disk_size_gb = 50

# More storage for monitoring
prometheus_storage_size = "20Gi"
grafana_storage_size    = "5Gi"
prometheus_retention    = "15d"
```

## Customization

You can customize the cluster by modifying variables in `terraform.tfvars`:

```hcl
# Cluster configuration
cluster_name = "my-cluster"
environment  = "dev"
node_count   = 3
machine_type = "e2-medium"

# Monitoring configuration  
monitoring_namespace    = "monitoring"
prometheus_retention    = "7d"
prometheus_storage_size = "8Gi"
grafana_storage_size    = "2Gi"

# Security
grafana_admin_password = "very-secure-password"
```

## Outputs

After deployment, terraform will output:
- Cluster connection command
- Prometheus access command
- Grafana access command
- Project ID used

## Clean Up

To destroy all resources:
```bash
terraform destroy
```

**Note**: This will permanently delete the cluster and all data. Make sure to backup any important data first.