locals {
  project_id = var.project_id != "" ? var.project_id : data.external.gcp_project.result.project
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
}

resource "google_container_node_pool" "preemptible_nodes" {
  project   = local.project_id
  name      = "preemptible-pool"
  location  = var.zone
  cluster   = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    preemptible  = true
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Enable Workload Identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  # Allow surge upgrades
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
}
