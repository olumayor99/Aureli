resource "helm_release" "kubecost" {
  name             = "kubecost"
  repository       = "https://kubecost.github.io/cost-analyzer/"
  chart            = "cost-analyzer"
  version          = "1.106.2"
  namespace        = "kubecost"
  create_namespace = true
  depends_on       = [helm_release.istio-base]

  set {
    name  = "global.prometheus.enabled"
    value = "false"
  }
  set {
    name  = "global.grafana.enabled"
    value = "false"
  }
}

resource "helm_release" "kubeshark" {
  name             = "kubeshark"
  repository       = "https://helm.kubeshark.co"
  chart            = "kubeshark"
  version          = "50.4.0"
  namespace = "kubeshark"
  create_namespace = true
  depends_on       = [helm_release.istio-base]
}

resource "helm_release" "elk-stack" {
  name             = "elk-stack"
  repository       = "oci://registry-1.docker.io/bitnamicharts/"
  chart            = "elasticsearch"
  version          = "19.12.0"
  namespace        = "elastic"
  create_namespace = true
}

resource "helm_release" "fluentd" {
  name             = "fluentd"
  repository       = "oci://registry-1.docker.io/bitnamicharts/"
  chart            = "fluentd"
  version          = "5.9.5"
  namespace        = "fluentd"
  create_namespace = true
}

resource "helm_release" "falco" {
  name             = "falco"
  repository       = "https://falcosecurity.github.io/charts"
  chart            = "falco"
  version          = "3.7.1"
  namespace        = "falco"
  create_namespace = true
}
