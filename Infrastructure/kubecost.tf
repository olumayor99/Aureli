resource "helm_release" "kubecost" {
  name             = "kubecost"
  repository       = "https://kubecost.github.io/cost-analyzer/"
  chart            = "cost-analyzer"
  version          = var.istio_chart_version
  namespace        = "kubecost"
  create_namespace = true

  depends_on = [helm_release.istio-base]
}