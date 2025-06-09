# GKE Module

This module creates a Google Kubernetes Engine (GKE) cluster with security best practices and configurable node pools.

## Features

- **Security First**: Workload Identity, Shielded Nodes, Binary Authorization
- **Flexible Networking**: Support for private clusters and custom VPCs
- **Cost Optimization**: Preemptible nodes and autoscaling support
- **Production Ready**: Maintenance windows, upgrade policies, monitoring

## Usage

```hcl
module "gke" {
  source = "./modules/gke"
  
  project_id   = "my-project"
  cluster_name = "my-cluster"
  zone         = "us-central1-a"
  
  # Node configuration
  node_count   = 3
  machine_type = "e2-medium"
  preemptible  = true
  
  # Autoscaling
  enable_autoscaling = true
  min_node_count     = 1
  max_node_count     = 10
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| google | ~> 5.0 |
| external | ~> 2.3 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 5.0 |
| external | ~> 2.3 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | GCP Project ID | `string` | `""` | no |
| region | GCP region | `string` | `"us-central1"` | no |
| zone | GCP zone | `string` | `"us-central1-a"` | no |
| cluster_name | GKE cluster name | `string` | `"gke-cluster"` | no |
| environment | Environment name | `string` | `"dev"` | no |
| node_count | Number of nodes | `number` | `3` | no |
| machine_type | Machine type for nodes | `string` | `"e2-medium"` | no |
| disk_size_gb | Boot disk size in GB | `number` | `20` | no |
| preemptible | Use preemptible nodes | `bool` | `true` | no |
| enable_autoscaling | Enable autoscaling | `bool` | `false` | no |
| min_node_count | Minimum nodes when autoscaling | `number` | `1` | no |
| max_node_count | Maximum nodes when autoscaling | `number` | `10` | no |
| enable_private_cluster | Enable private cluster | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_name | GKE cluster name |
| cluster_endpoint | GKE cluster endpoint |
| cluster_ca_certificate | Cluster CA certificate (base64) |
| project_id | GCP Project ID |
| gcloud_connect_command | kubectl connection command |

## Security Features

### Workload Identity
Enables secure communication between pods and GCP services without storing service account keys.

### Shielded Nodes
Provides verifiable integrity and protects against rootkits and bootkits.

### Binary Authorization
Ensures only verified container images are deployed.

### Network Policies
Enables micro-segmentation within the cluster.

### Private Clusters
Isolates nodes from the public internet (optional).

## Examples

### Basic Development Cluster
```hcl
module "dev_cluster" {
  source = "./modules/gke"
  
  cluster_name = "dev-cluster"
  environment  = "dev"
  preemptible  = true
  node_count   = 2
}
```

### Production Cluster
```hcl
module "prod_cluster" {
  source = "./modules/gke"
  
  cluster_name = "prod-cluster"
  environment  = "prod"
  
  # Production settings
  preemptible = false
  machine_type = "e2-standard-4"
  
  # Autoscaling
  enable_autoscaling = true
  min_node_count     = 3
  max_node_count     = 20
  
  # Private cluster
  enable_private_cluster = true
}
```