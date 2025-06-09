resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
    labels = {
      name        = var.namespace
      environment = var.environment
      managed-by  = "terraform"
    }
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = var.prometheus_helm_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  timeout    = var.helm_timeout
  wait       = var.helm_wait

  # Resource configuration suitable for small clusters
  values = [
    yamlencode({
      server = {
        resources = {
          requests = {
            cpu    = var.prometheus_cpu_request
            memory = var.prometheus_memory_request
          }
          limits = {
            cpu    = var.prometheus_cpu_limit
            memory = var.prometheus_memory_limit
          }
        }
        retention = var.prometheus_retention
        persistentVolume = {
          enabled = var.prometheus_persistence_enabled
          size    = var.prometheus_storage_size
        }
      }
      alertmanager = {
        enabled = var.alertmanager_enabled
      }
      pushgateway = {
        enabled = var.pushgateway_enabled
      }
      nodeExporter = {
        resources = {
          requests = {
            cpu    = var.node_exporter_cpu_request
            memory = var.node_exporter_memory_request
          }
          limits = {
            cpu    = var.node_exporter_cpu_limit
            memory = var.node_exporter_memory_limit
          }
        }
      }
      kubeStateMetrics = {
        enabled = var.kube_state_metrics_enabled
      }
    })
  ]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = var.grafana_helm_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  timeout    = var.helm_timeout
  wait       = var.helm_wait

  values = [
    yamlencode({
      resources = {
        requests = {
          cpu    = var.grafana_cpu_request
          memory = var.grafana_memory_request
        }
        limits = {
          cpu    = var.grafana_cpu_limit
          memory = var.grafana_memory_limit
        }
      }
      persistence = {
        enabled = var.grafana_persistence_enabled
        size    = var.grafana_storage_size
      }
      adminPassword = var.grafana_admin_password
      datasources = {
        "datasources.yaml" = {
          apiVersion = 1
          datasources = [
            {
              name      = "Prometheus"
              type      = "prometheus"
              url       = "http://prometheus-server.${var.namespace}.svc.cluster.local"
              access    = "proxy"
              isDefault = true
            }
          ]
        }
      }
      dashboardProviders = var.enable_default_dashboards ? {
        "dashboardproviders.yaml" = {
          apiVersion = 1
          providers = [
            {
              name            = "default"
              orgId           = 1
              folder          = ""
              type            = "file"
              disableDeletion = false
              editable        = true
              options = {
                path = "/var/lib/grafana/dashboards/default"
              }
            }
          ]
        }
      } : {}
      dashboards = var.enable_default_dashboards ? {
        default = var.grafana_dashboards
      } : {}
    })
  ]

  depends_on = [helm_release.prometheus]
}