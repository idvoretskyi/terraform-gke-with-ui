output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = "https://${google_container_cluster.primary.endpoint}"
  description = "GKE Cluster Host"
}

output "gcloud_connect_command" {
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${var.zone} --project ${local.project_id}"
  description = "Command to configure kubectl to connect to the cluster"
}

output "prometheus_server" {
  value       = "kubectl port-forward -n ${var.monitoring_namespace} svc/prometheus-server 9090:80"
  description = "Command to access Prometheus server"
}

output "grafana_server" {
  value       = "kubectl port-forward -n ${var.monitoring_namespace} svc/grafana 3000:80"
  description = "Command to access Grafana server"
}

output "project_id" {
  value       = local.project_id
  description = "GCP Project ID used for this deployment"
}
