output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.gke.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for the GKE cluster"
  value       = module.gke.cluster_endpoint
  sensitive   = true
}

output "project_id" {
  description = "GCP Project ID used for this deployment"
  value       = module.gke.project_id
}

output "gcloud_connect_command" {
  description = "Command to configure kubectl to connect to the cluster"
  value       = module.gke.gcloud_connect_command
}

output "prometheus_port_forward_command" {
  description = "Command to access Prometheus server via port forwarding"
  value       = module.monitoring.prometheus_port_forward_command
}

output "grafana_port_forward_command" {
  description = "Command to access Grafana server via port forwarding"
  value       = module.monitoring.grafana_port_forward_command
}

output "monitoring_namespace" {
  description = "Monitoring namespace name"
  value       = module.monitoring.namespace
}