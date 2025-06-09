# Monitoring Module

This module deploys Prometheus and Grafana for Kubernetes cluster monitoring using Helm charts.

## Features

- **Prometheus**: Metrics collection and storage with configurable retention
- **Grafana**: Visualization dashboards with pre-configured data sources
- **Resource Optimized**: Suitable for small to medium clusters
- **Persistent Storage**: Configurable persistent volumes for data retention
- **Default Dashboards**: Pre-configured Kubernetes monitoring dashboards

## Usage

```hcl
module "monitoring" {
  source = "./modules/monitoring"
  
  namespace              = "monitoring"
  grafana_admin_password = "secure-password"
  
  # Storage configuration
  prometheus_storage_size = "10Gi"
  grafana_storage_size    = "5Gi"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| kubernetes | ~> 2.24 |
| helm | ~> 2.12 |

## Providers

| Name | Version |
|------|---------|
| kubernetes | ~> 2.24 |
| helm | ~> 2.12 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | Kubernetes namespace | `string` | `"monitoring"` | no |
| environment | Environment name | `string` | `"dev"` | no |
| grafana_admin_password | Grafana admin password | `string` | n/a | yes |
| prometheus_helm_version | Prometheus chart version | `string` | `"25.8.0"` | no |
| grafana_helm_version | Grafana chart version | `string` | `"7.0.19"` | no |
| prometheus_retention | Data retention period | `string` | `"7d"` | no |
| prometheus_storage_size | Prometheus storage size | `string` | `"8Gi"` | no |
| grafana_storage_size | Grafana storage size | `string` | `"2Gi"` | no |
| prometheus_cpu_request | Prometheus CPU request | `string` | `"100m"` | no |
| prometheus_memory_request | Prometheus memory request | `string` | `"256Mi"` | no |
| grafana_cpu_request | Grafana CPU request | `string` | `"100m"` | no |
| grafana_memory_request | Grafana memory request | `string` | `"128Mi"` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace | Monitoring namespace |
| prometheus_port_forward_command | Prometheus access command |
| grafana_port_forward_command | Grafana access command |
| prometheus_url | Prometheus internal URL |
| grafana_url | Grafana internal URL |

## Access

### Prometheus
Access Prometheus using port forwarding:
```bash
kubectl port-forward -n monitoring svc/prometheus-server 9090:80
```
Then open http://localhost:9090

### Grafana
Access Grafana using port forwarding:
```bash
kubectl port-forward -n monitoring svc/grafana 3000:80
```
Then open http://localhost:3000

**Default credentials:**
- Username: `admin`
- Password: Value from `grafana_admin_password`

## Pre-configured Dashboards

The module includes default Kubernetes monitoring dashboards:
- Kubernetes Cluster Monitoring
- Kubernetes Pods Monitoring

## Resource Configuration

### Small Cluster (Default)
```hcl
module "monitoring" {
  source = "./modules/monitoring"
  
  grafana_admin_password = "password"
  
  # Minimal resources
  prometheus_cpu_request    = "100m"
  prometheus_memory_request = "256Mi"
  grafana_cpu_request      = "100m"
  grafana_memory_request   = "128Mi"
}
```

### Large Cluster
```hcl
module "monitoring" {
  source = "./modules/monitoring"
  
  grafana_admin_password = "password"
  
  # Increased resources
  prometheus_cpu_request    = "500m"
  prometheus_memory_request = "2Gi"
  prometheus_storage_size   = "50Gi"
  prometheus_retention      = "30d"
  
  grafana_cpu_request     = "200m"
  grafana_memory_request  = "512Mi"
  grafana_storage_size    = "10Gi"
}
```

## Dependencies

This module should be deployed after the GKE cluster is ready:

```hcl
module "gke" {
  source = "./modules/gke"
  # ... configuration
}

module "monitoring" {
  source = "./modules/monitoring"
  
  grafana_admin_password = "password"
  depends_on = [module.gke]
}
```