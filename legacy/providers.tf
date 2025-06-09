terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.2"
    }
  }
  required_version = ">= 0.14"
}

# Get current GCP project from gcloud config
data "external" "gcp_project" {
  program = ["bash", "-c", "echo '{\"project\": \"'$(gcloud config get-value project 2>/dev/null)'\"}'"]
}

# Initialize the Google provider
provider "google" {
  project = var.project_id != "" ? var.project_id : data.external.gcp_project.result.project
  region  = var.region
}

# Get the client configuration
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}
