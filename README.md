# Terraform GKE with Monitoring

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.0-blue)](https://www.terraform.io/)

This repository provides Terraform modules for creating a Google Kubernetes Engine (GKE) cluster with optional monitoring stack (Prometheus and Grafana). The modules are designed following Terraform best practices and are suitable for production use.

## Features

- **Modular Design**: Separate modules for GKE cluster and monitoring stack
- **Security Best Practices**: Workload Identity, Shielded Nodes, Binary Authorization
- **Cost Optimization**: Support for preemptible nodes and autoscaling
- **Monitoring Ready**: Optional Prometheus and Grafana deployment with pre-configured dashboards
- **Production Ready**: Proper resource management, maintenance windows, and upgrade policies

## Quick Start

1. **Prerequisites**:
   - [Terraform](https://www.terraform.io/downloads.html) >= 1.0
   - [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
   - GCP project with required APIs enabled:
     ```bash
     gcloud services enable compute.googleapis.com
     gcloud services enable container.googleapis.com
     ```

2. **Setup State Storage**:
   ```bash
   # Create GCS bucket for Terraform state
   ./scripts/create-state-bucket.sh [PROJECT_ID] [BUCKET_NAME] [REGION]
   ```

3. **Basic Usage**:
   ```bash
   cd examples/simple
   cp terraform.tfvars.example terraform.tfvars
   cp backend.tf.example backend.tf
   # Edit terraform.tfvars and backend.tf with your values
   terraform init
   terraform plan
   terraform apply
   ```

4. **Alternative: Automated Setup**:
   ```bash
   # Creates workspace with remote state configured
   ./scripts/setup-workspace.sh [ENVIRONMENT] [PROJECT_ID] [REGION]
   cd workspaces/[ENVIRONMENT]
   # Edit terraform.tfvars, then run terraform init/plan/apply
   ```

5. **Connect to your cluster**:
   ```bash
   # Command will be displayed in terraform output
   gcloud container clusters get-credentials CLUSTER_NAME --zone ZONE --project PROJECT_ID
   ```

## Modules

This repository contains the following modules:

### GKE Module (`modules/gke`)
Creates a GKE cluster with security best practices:
- Workload Identity enabled
- Shielded Nodes
- Binary Authorization
- Network policies
- Configurable node pools with autoscaling
- Private cluster support

### Monitoring Module (`modules/monitoring`)
Deploys Prometheus and Grafana for cluster monitoring:
- Prometheus with configurable retention and storage
- Grafana with pre-configured dashboards
- Resource-optimized for small clusters
- Configurable resource limits

## Usage Examples

### Basic Cluster
```hcl
module "gke" {
  source = "./modules/gke"
  
  project_id   = "my-project"
  cluster_name = "my-cluster"
  zone         = "us-central1-a"
  node_count   = 3
}
```

### Cluster with Monitoring
```hcl
module "gke" {
  source = "./modules/gke"
  # ... configuration
}

module "monitoring" {
  source = "./modules/monitoring"
  
  grafana_admin_password = "secure-password"
  depends_on = [module.gke]
}
```

### Production Cluster
```hcl
module "gke" {
  source = "./modules/gke"
  
  project_id   = "my-project"
  cluster_name = "prod-cluster"
  environment  = "prod"

  # Use regular nodes for production
  preemptible = false
  
  # Enable autoscaling
  enable_autoscaling = true
  min_node_count     = 3
  max_node_count     = 10
  
  # Enable private cluster
  enable_private_cluster = true
}
```

## Accessing Monitoring Tools

The monitoring module outputs commands to access the services:

```bash
# Access Prometheus (port-forward command in terraform output)
kubectl port-forward -n monitoring svc/prometheus-server 9090:80

# Access Grafana (port-forward command in terraform output)
kubectl port-forward -n monitoring svc/grafana 3000:80
```

Grafana credentials:
- Username: `admin`
- Password: Value from `grafana_admin_password` variable

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        GCP Project                          │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                   GKE Cluster                           ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    ││
│  │  │    Node     │  │    Node     │  │    Node     │    ││
│  │  │    Pool     │  │    Pool     │  │    Pool     │    ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘    ││
│  │                                                         ││
│  │  ┌─────────────────────────────────────────────────────┐││
│  │  │            Monitoring Namespace                     │││
│  │  │  ┌─────────────┐    ┌─────────────┐               │││
│  │  │  │ Prometheus  │    │   Grafana   │               │││
│  │  │  └─────────────┘    └─────────────┘               │││
│  │  └─────────────────────────────────────────────────────┘││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

## State Management

This project is configured to use Google Cloud Storage for Terraform state storage, which provides:

- **Team Collaboration**: Multiple team members can work with the same state
- **State Locking**: Prevents concurrent modifications
- **Versioning**: Automatic backup and recovery capabilities
- **Security**: State files are stored securely in GCS

### Setting Up Remote State

1. **Create State Bucket**:
   ```bash
   ./scripts/create-state-bucket.sh my-project my-project-terraform-state us-central1
   ```

2. **Configure Backend**:
   ```hcl
   terraform {
     backend "gcs" {
       bucket = "my-project-terraform-state"
       prefix = "terraform/dev/gke-cluster"
     }
   }
   ```

3. **Initialize with Remote State**:
   ```bash
   terraform init -migrate-state  # If migrating from local state
   terraform init                 # For new deployments
   ```

### Multi-Environment Setup

Use different prefixes for different environments:
- Development: `terraform/dev/gke-cluster`
- Staging: `terraform/staging/gke-cluster`
- Production: `terraform/prod/gke-cluster`

### Workspace Management

The `setup-workspace.sh` script automates workspace creation:
```bash
./scripts/setup-workspace.sh dev my-project us-central1
./scripts/setup-workspace.sh prod my-project us-central1
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Security

This module implements several security best practices:
- Workload Identity for secure pod-to-GCP-service communication
- Shielded GKE Nodes for enhanced security
- Binary Authorization for container image verification
- Network policies for micro-segmentation
- Private cluster support

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
