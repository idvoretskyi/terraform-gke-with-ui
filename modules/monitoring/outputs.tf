output "namespace" {
  description = "Monitoring namespace name"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "prometheus_service_name" {
  description = "Prometheus service name"
  value       = "prometheus-server"
}

output "grafana_service_name" {
  description = "Grafana service name"
  value       = "grafana"
}

output "prometheus_port_forward_command" {
  description = "Command to access Prometheus server via port forwarding"
  value       = "kubectl port-forward -n ${kubernetes_namespace.monitoring.metadata[0].name} svc/prometheus-server 9090:80"
}

output "grafana_port_forward_command" {
  description = "Command to access Grafana server via port forwarding"
  value       = "kubectl port-forward -n ${kubernetes_namespace.monitoring.metadata[0].name} svc/grafana 3000:80"
}

output "prometheus_url" {
  description = "Prometheus service URL within the cluster"
  value       = "http://prometheus-server.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local"
}

output "grafana_url" {
  description = "Grafana service URL within the cluster"
  value       = "http://grafana.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local"
}