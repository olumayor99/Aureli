module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # This is required to expose Istio Ingress Gateway
  enable_aws_load_balancer_controller = true

  helm_releases = {
    istio-base = {
      chart      = "base"
      version    = var.istio_chart_version
      repository = var.istio_chart_url
      name       = "istio-base"
      namespace  = "istio-system"
    }

    istiod = {
      chart      = "istiod"
      version    = var.istio_chart_version
      repository = var.istio_chart_url
      name       = "istiod"
      namespace  = "istio-system"

      set = [
        {
          name  = "meshConfig.accessLogFile"
          value = "/dev/stdout"
        }
      ]
    }

    istio-ingress = {
      chart            = "gateway"
      version          = var.istio_chart_version
      repository       = var.istio_chart_url
      name             = "istio-ingress"
      namespace  = "istio-system"
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
    }
  }
  depends_on = [resource.null_resource.istio_ns]
}

resource "null_resource" "istio_addons" {
  provisioner "local-exec" {
    command = "sh addon.sh"
  }
  depends_on = [module.eks_blueprints_addons]
}