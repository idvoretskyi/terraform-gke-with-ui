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
  default     = "gke-cluster"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "node_count" {
  description = "Number of nodes in the GKE cluster"
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-medium"
}

variable "disk_size_gb" {
  description = "Boot disk size for the nodes in GB"
  type        = number
  default     = 20
}

variable "preemptible" {
  description = "Whether to use preemptible nodes"
  type        = bool
  default     = true
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

variable "enable_autoscaling" {
  description = "Enable cluster autoscaling"
  type        = bool
  default     = false
}

variable "min_node_count" {
  description = "Minimum number of nodes in the pool"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes in the pool"
  type        = number
  default     = 10
}

variable "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring tools"
  type        = string
  default     = "monitoring"
}

variable "prometheus_helm_version" {
  description = "Prometheus Helm chart version"
  type        = string
  default     = "25.8.0"
}

variable "grafana_helm_version" {
  description = "Grafana Helm chart version"
  type        = string
  default     = "7.0.19"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  default     = "change-me-please"
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type        = string
  default     = "7d"
}

variable "prometheus_storage_size" {
  description = "Prometheus persistent volume size"
  type        = string
  default     = "8Gi"
}

variable "grafana_storage_size" {
  description = "Grafana persistent volume size"
  type        = string
  default     = "2Gi"
}