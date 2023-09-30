resource "helm_release" "kubeshark" {
  name             = "kubeshark"
  repository       = "https://helm.kubeshark.co"
  chart            = "kubeshark"
  version          = "50.4.0"
  namespace        = "kubeshark"
  create_namespace = true
  depends_on       = [helm_release.istio-base]
}