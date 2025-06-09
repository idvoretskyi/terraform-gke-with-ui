resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.monitoring_namespace
  }

  depends_on = [google_container_node_pool.preemptible_nodes]
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = var.prometheus_helm_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  timeout    = 900 # Increase timeout to 15 minutes
  wait       = false # Don't wait for all resources to be ready

  # Resource configuration suitable for small clusters
  set {
    name  = "server.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "server.resources.limits.cpu"
    value = "200m"
  }

  set {
    name  = "server.resources.requests.memory"
    value = "256Mi"
  }

  set {
    name  = "server.resources.limits.memory"
    value = "512Mi"
  }

  # Configure smaller persistent volumes
  set {
    name  = "server.retention"
    value = var.prometheus_retention
  }

  set {
    name  = "server.persistentVolume.enabled"
    value = "true"
  }

  set {
    name  = "server.persistentVolume.size"
    value = "4Gi" # Reduced from 8Gi
  }

  # Disable components we don't need for a minimal setup
  set {
    name  = "alertmanager.enabled"
    value = "false"
  }

  set {
    name  = "pushgateway.enabled"
    value = "false"
  }

  # Reduce nodeExporter resources
  set {
    name  = "nodeExporter.resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "nodeExporter.resources.requests.memory"
    value = "64Mi"
  }
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = var.grafana_helm_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  timeout    = 600 # Increase timeout to 10 minutes
  wait       = false # Don't wait for all resources to be ready

  # Configure smaller resource requests
  set {
    name  = "resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "resources.requests.memory"
    value = "128Mi"
  }

  set {
    name  = "resources.limits.cpu" 
    value = "200m"
  }

  set {
    name  = "resources.limits.memory"
    value = "256Mi"
  }

  set {
    name  = "persistence.enabled"
    value = "true"
  }

  set {
    name  = "persistence.size"
    value = "1Gi" # Reduced from 2Gi
  }

  set {
    name  = "adminPassword"
    value = var.grafana_admin_password
  }

  # Datasource configuration
  set {
    name  = "datasources.datasources\\.yaml.apiVersion"
    value = "1"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[0].name"
    value = "Prometheus"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[0].type"
    value = "prometheus"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[0].url"
    value = "http://prometheus-server.${var.monitoring_namespace}.svc.cluster.local"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[0].access"
    value = "proxy"
  }

  set {
    name  = "datasources.datasources\\.yaml.datasources[0].isDefault"
    value = "true"
  }

  depends_on = [helm_release.prometheus]
}
