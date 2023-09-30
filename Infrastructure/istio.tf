resource "null_resource" "istio_addons" {
  provisioner "local-exec" {
    command = "sh addon.sh"
  }
  depends_on = [module.eks_blueprints_addons, helm_release.litmus_chaos]
}

resource "helm_release" "istio-base" {
  name             = "istio-base"
  repository       = var.istio_chart_url
  chart            = "base"
  version          = var.istio_chart_version
  namespace        = "istio-system"
  create_namespace = true
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = var.istio_chart_url
  chart      = "istiod"
  version    = var.istio_chart_version
  namespace  = "istio-system"

  set {
    name  = "meshConfig.accessLogFile"
    value = "/dev/stdout"
  }

  depends_on = [helm_release.istio-base]
}

resource "helm_release" "istio-ingress" {
  name       = "istio-ingress"
  repository = var.istio_chart_url
  chart      = "gateway"
  version    = var.istio_chart_version
  namespace  = "istio-system"

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