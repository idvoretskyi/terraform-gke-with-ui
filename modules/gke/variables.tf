variable "project_id" {
  description = "GCP Project ID (defaults to currently configured project if not specified)"
  type        = string
  default     = ""
}

variable "region" {
  description = "GCP region to deploy resources"
  type        = string
  default     = "us-central1"
  
  validation {
    condition = can(regex("^[a-z]+-[a-z]+[0-9]$", var.region))
    error_message = "Region must be a valid GCP region format (e.g., us-central1)."
  }
}

variable "zone" {
  description = "GCP zone for zonal resources"
  type        = string
  default     = "us-central1-a"
  
  validation {
    condition = can(regex("^[a-z]+-[a-z]+[0-9]-[a-z]$", var.zone))
    error_message = "Zone must be a valid GCP zone format (e.g., us-central1-a)."
  }
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "gke-cluster"
  
  validation {
    condition = can(regex("^[a-z]([a-z0-9-]*[a-z0-9])?$", var.cluster_name))
    error_message = "Cluster name must start with a lowercase letter, followed by lowercase letters, numbers, or hyphens, and cannot end with a hyphen."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "node_count" {
  description = "Number of nodes in the GKE cluster"
  type        = number
  default     = 1
  
  validation {
    condition = var.node_count >= 1 && var.node_count <= 100
    error_message = "Node count must be between 1 and 100."
  }
}

variable "machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-small"
  
  validation {
    condition = can(regex("^(e2|n1|n2|c2|m1|m2|t2d|c3|g2)-(micro|small|medium|standard|highmem|highcpu)-[0-9]+$", var.machine_type)) || contains(["e2-micro", "e2-small", "e2-medium", "f1-micro", "g1-small"], var.machine_type)
    error_message = "Machine type must be a valid GCP machine type."
  }
}

variable "disk_size_gb" {
  description = "Boot disk size for the nodes in GB"
  type        = number
  default     = 20
  
  validation {
    condition = var.disk_size_gb >= 10 && var.disk_size_gb <= 10000
    error_message = "Disk size must be between 10 and 10000 GB."
  }
}

variable "disk_type" {
  description = "Boot disk type for the nodes"
  type        = string
  default     = "pd-standard"
  
  validation {
    condition = contains(["pd-standard", "pd-ssd", "pd-balanced"], var.disk_type)
    error_message = "Disk type must be one of: pd-standard, pd-ssd, pd-balanced."
  }
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

variable "preemptible" {
  description = "Whether to use preemptible nodes"
  type        = bool
  default     = true
}

variable "enable_autoscaling" {
  description = "Enable cluster autoscaling"
  type        = bool
  default     = true
}

variable "min_node_count" {
  description = "Minimum number of nodes in the pool"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes in the pool"
  type        = number
  default     = 5
}

variable "max_surge" {
  description = "Maximum number of nodes that can be created during an upgrade"
  type        = number
  default     = 1
}

variable "max_unavailable" {
  description = "Maximum number of nodes that can be unavailable during an upgrade"
  type        = number
  default     = 0
}

variable "auto_repair" {
  description = "Enable auto repair for nodes"
  type        = bool
  default     = true
}

variable "auto_upgrade" {
  description = "Enable auto upgrade for nodes"
  type        = bool
  default     = true
}

variable "maintenance_start_time" {
  description = "Start time for daily maintenance window (HH:MM format)"
  type        = string
  default     = "02:00"
  
  validation {
    condition = can(regex("^[0-2][0-9]:[0-5][0-9]$", var.maintenance_start_time))
    error_message = "Maintenance start time must be in HH:MM format (24-hour)."
  }
}

variable "enable_private_cluster" {
  description = "Enable private cluster configuration"
  type        = bool
  default     = false
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint for the cluster master"
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  description = "IPv4 CIDR block for the master network"
  type        = string
  default     = "172.16.0.0/28"
}

variable "cluster_ipv4_cidr_block" {
  description = "IPv4 CIDR block for the cluster pods"
  type        = string
  default     = "10.0.0.0/14"
}

variable "services_ipv4_cidr_block" {
  description = "IPv4 CIDR block for the cluster services"
  type        = string
  default     = "10.4.0.0/19"
}