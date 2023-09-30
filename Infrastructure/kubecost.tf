resource "helm_release" "kubecost" {
  name             = "kubecost"
  repository       = "https://kubecost.github.io/cost-analyzer/"
  chart            = "cost-analyzer"
  version          = "1.106.2"
  namespace        = "kubecost"
  create_namespace = true
  depends_on       = [helm_release.istio-base]
}