locals {
  project_id = var.project_id != "" ? var.project_id : data.external.gcp_project.result.project
  
  default_tags = {
    Environment   = var.environment
    ManagedBy     = "terraform"
    Project       = var.cluster_name
    CreatedBy     = "terraform-gke-module"
  }
}

# Get current GCP project from gcloud config
data "external" "gcp_project" {
  program = ["bash", "-c", "echo '{\"project\": \"'$(gcloud config get-value project 2>/dev/null)'\"}'"]
}

resource "google_container_cluster" "primary" {
  project  = local.project_id
  name     = var.cluster_name
  location = var.zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network
  subnetwork = var.subnetwork

  # Enable Workload Identity
  workload_identity_config {
    workload_pool = "${local.project_id}.svc.id.goog"
  }

  # Enable network policy
  network_policy {
    enabled = true
  }

  # Enable IP alias for better networking
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.cluster_ipv4_cidr_block
    services_ipv4_cidr_block = var.services_ipv4_cidr_block
  }

  # Enable binary authorization
  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }

  # Enable shielded nodes
  enable_shielded_nodes = true

  # Resource labels
  resource_labels = local.default_tags

  # Maintenance policy
  maintenance_policy {
    daily_maintenance_window {
      start_time = var.maintenance_start_time
    }
  }

  # Enable monitoring and logging
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # Private cluster configuration
  dynamic "private_cluster_config" {
    for_each = var.enable_private_cluster ? [1] : []
    content {
      enable_private_nodes    = true
      enable_private_endpoint = var.enable_private_endpoint
      master_ipv4_cidr_block  = var.master_ipv4_cidr_block
    }
  }
}

resource "google_container_node_pool" "preemptible_nodes" {
  project    = local.project_id
  name       = "${var.cluster_name}-preemptible-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    preemptible  = var.preemptible
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = var.disk_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Enable Workload Identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Shielded instance configuration
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    # Labels
    labels = local.default_tags

    # Taints for preemptible nodes
    dynamic "taint" {
      for_each = var.preemptible ? [1] : []
      content {
        key    = "preemptible"
        value  = "true"
        effect = "NO_SCHEDULE"
      }
    }
  }

  # Allow surge upgrades
  upgrade_settings {
    max_surge       = var.max_surge
    max_unavailable = var.max_unavailable
  }

  # Autoscaling configuration
  dynamic "autoscaling" {
    for_each = var.enable_autoscaling ? [1] : []
    content {
      min_node_count = var.min_node_count
      max_node_count = var.max_node_count
    }
  }

  # Node management
  management {
    auto_repair  = var.auto_repair
    auto_upgrade = var.auto_upgrade
  }
}