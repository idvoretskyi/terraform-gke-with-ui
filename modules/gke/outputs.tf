output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "Endpoint for the GKE cluster"
  value       = google_container_cluster.primary.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64 encoded public certificate that is the root of trust for the cluster"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "Location of the GKE cluster"
  value       = google_container_cluster.primary.location
}

output "node_pool_name" {
  description = "Name of the node pool"
  value       = google_container_node_pool.preemptible_nodes.name
}

output "project_id" {
  description = "GCP Project ID used for this deployment"
  value       = local.project_id
}

output "gcloud_connect_command" {
  description = "Command to configure kubectl to connect to the cluster"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${var.zone} --project ${local.project_id}"
}