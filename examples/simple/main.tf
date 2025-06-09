terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}

locals {
  project_id = var.project_id != "" ? var.project_id : data.external.gcp_project.result.project
}

# Get current GCP project from gcloud config
data "external" "gcp_project" {
  program = ["bash", "-c", "echo '{\"project\": \"'$(gcloud config get-value project 2>/dev/null)'\"}'"]
}

# Initialize the Google provider
provider "google" {
  project = local.project_id
  region  = var.region
}

# Get the client configuration
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke.cluster_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
  }
}

# Create GKE cluster
module "gke" {
  source = "../../modules/gke"

  project_id   = var.project_id
  region       = var.region
  zone         = var.zone
  cluster_name = var.cluster_name
  environment  = var.environment

  node_count   = var.node_count
  machine_type = var.machine_type
  disk_size_gb = var.disk_size_gb
  preemptible  = var.preemptible

  network    = var.network
  subnetwork = var.subnetwork

  enable_autoscaling = var.enable_autoscaling
  min_node_count     = var.min_node_count
  max_node_count     = var.max_node_count
}

# Deploy monitoring stack
module "monitoring" {
  source = "../../modules/monitoring"

  namespace   = var.monitoring_namespace
  environment = var.environment

  prometheus_helm_version = var.prometheus_helm_version
  grafana_helm_version    = var.grafana_helm_version
  grafana_admin_password  = var.grafana_admin_password
  prometheus_retention    = var.prometheus_retention

  # Resource configuration
  prometheus_storage_size = var.prometheus_storage_size
  grafana_storage_size    = var.grafana_storage_size

  depends_on = [module.gke]
}