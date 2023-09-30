resource "null_resource" "istio_addons" {
  provisioner "local-exec" {
    command = "sh addon.sh"
  }
  depends_on = [module.eks_blueprints_addons]
}

resource "helm_release" "istio-base" {
  chart      = "base"
  version    = var.istio_chart_version
  repository = var.istio_chart_url
  name       = "istio-base"
  namespace  = kubernetes_namespace_v1.istio_ns.metadata[0].name
}

resource "helm_release" "istiod" {
  chart      = "istiod"
  version    = var.istio_chart_version
  repository = var.istio_chart_url
  name       = "istiod"
  namespace  = kubernetes_namespace_v1.istio_ns.metadata[0].name

  set {
    name  = "meshConfig.accessLogFile"
    value = "/dev/stdout"
    }

  depends_on       = [helm_release.istio-base]
}

resource "helm_release" "istio-ingress" {
  chart            = "gateway"
  version          = var.istio_chart_version
  repository       = var.istio_chart_url
  name             = "istio-ingress"
  namespace  = kubernetes_namespace_v1.istio_ns.metadata[0].name
  create_namespace = true

  values = [
    yamlencode(
      {
        labels = {
          istio = "ingressgateway"
        }
        service = {
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type"       = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-scheme"     = "internet-facing"
            "service.beta.kubernetes.io/aws-load-balancer-attributes" = "load_balancing.cross_zone.enabled=true"
          }
        }
      }
    )
  ]
  depends_on = [helm_release.istiod]
}