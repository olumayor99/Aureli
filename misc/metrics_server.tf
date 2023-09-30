resource "helm_release" "metrics_server" {
  name             = "metrics_server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server"
  chart            = "metrics-server"
  version          = "3.11.0"
}