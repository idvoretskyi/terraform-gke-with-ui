variable "namespace" {
  description = "Kubernetes namespace for monitoring tools"
  type        = string
  default     = "monitoring"
  
  validation {
    condition = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.namespace))
    error_message = "Namespace must be a valid Kubernetes namespace name."
  }
}

variable "environment" {
  description = "Environment name for labeling"
  type        = string
  default     = "dev"
}

# Prometheus Configuration
variable "prometheus_helm_version" {
  description = "Prometheus Helm chart version"
  type        = string
  default     = "25.8.0"
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type        = string
  default     = "7d"
  
  validation {
    condition = can(regex("^[0-9]+[dwmy]$", var.prometheus_retention))
    error_message = "Retention period must be in format like '7d', '2w', '1m', '1y'."
  }
}

variable "prometheus_cpu_request" {
  description = "Prometheus CPU request"
  type        = string
  default     = "100m"
}

variable "prometheus_cpu_limit" {
  description = "Prometheus CPU limit"
  type        = string
  default     = "500m"
}

variable "prometheus_memory_request" {
  description = "Prometheus memory request"
  type        = string
  default     = "256Mi"
}

variable "prometheus_memory_limit" {
  description = "Prometheus memory limit"
  type        = string
  default     = "1Gi"
}

variable "prometheus_persistence_enabled" {
  description = "Enable Prometheus persistent volume"
  type        = bool
  default     = true
}

variable "prometheus_storage_size" {
  description = "Prometheus persistent volume size"
  type        = string
  default     = "8Gi"
}

variable "alertmanager_enabled" {
  description = "Enable Alertmanager"
  type        = bool
  default     = false
}

variable "pushgateway_enabled" {
  description = "Enable Pushgateway"
  type        = bool
  default     = false
}

variable "kube_state_metrics_enabled" {
  description = "Enable kube-state-metrics"
  type        = bool
  default     = true
}

# Node Exporter Configuration
variable "node_exporter_cpu_request" {
  description = "Node Exporter CPU request"
  type        = string
  default     = "50m"
}

variable "node_exporter_cpu_limit" {
  description = "Node Exporter CPU limit"
  type        = string
  default     = "100m"
}

variable "node_exporter_memory_request" {
  description = "Node Exporter memory request"
  type        = string
  default     = "64Mi"
}

variable "node_exporter_memory_limit" {
  description = "Node Exporter memory limit"
  type        = string
  default     = "128Mi"
}

# Grafana Configuration
variable "grafana_helm_version" {
  description = "Grafana Helm chart version"
  type        = string
  default     = "7.0.19"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  
  validation {
    condition = length(var.grafana_admin_password) >= 8
    error_message = "Grafana admin password must be at least 8 characters long."
  }
}

variable "grafana_cpu_request" {
  description = "Grafana CPU request"
  type        = string
  default     = "100m"
}

variable "grafana_cpu_limit" {
  description = "Grafana CPU limit"
  type        = string
  default     = "200m"
}

variable "grafana_memory_request" {
  description = "Grafana memory request"
  type        = string
  default     = "128Mi"
}

variable "grafana_memory_limit" {
  description = "Grafana memory limit"
  type        = string
  default     = "256Mi"
}

variable "grafana_persistence_enabled" {
  description = "Enable Grafana persistent volume"
  type        = bool
  default     = true
}

variable "grafana_storage_size" {
  description = "Grafana persistent volume size"
  type        = string
  default     = "2Gi"
}

variable "enable_default_dashboards" {
  description = "Enable default Grafana dashboards"
  type        = bool
  default     = true
}

variable "grafana_dashboards" {
  description = "Map of Grafana dashboards to install"
  type        = map(string)
  default = {
    "kubernetes-cluster-monitoring" = "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-global.json"
    "kubernetes-pods-monitoring"    = "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-pods.json"
  }
}

# Helm Configuration
variable "helm_timeout" {
  description = "Helm operation timeout in seconds"
  type        = number
  default     = 900
}

variable "helm_wait" {
  description = "Wait for Helm releases to be ready"
  type        = bool
  default     = false
}