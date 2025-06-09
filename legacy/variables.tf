variable "project_id" {
  description = "GCP Project ID (defaults to currently configured project if not specified)"
  type        = string
  default     = ""
}

variable "region" {
  description = "GCP region to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone for zonal resources"
  type        = string
  default     = "us-central1-a"
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "preemptible-gke-cluster"
}

variable "node_count" {
  description = "Number of nodes in the GKE cluster"
  type        = number
  default     = 3
}

// Make sure the node type is sufficient for monitoring workloads
variable "machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-medium" // Ensure this is at least e2-medium
}

variable "disk_size_gb" {
  description = "Boot disk size for the nodes in GB"
  type        = number
  default     = 20 // Increased from 10GB to accommodate monitoring
}

variable "network" {
  description = "VPC network to deploy the cluster"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "VPC subnetwork to deploy the cluster"
  type        = string
  default     = "default"
}

variable "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring tools"
  type        = string
  default     = "monitoring"
}

variable "prometheus_helm_version" {
  description = "Prometheus Helm chart version"
  type        = string
  default     = "15.10.0"
}

variable "grafana_helm_version" {
  description = "Grafana Helm chart version"
  type        = string
  default     = "6.29.0"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type        = string
  default     = "7d"
}
