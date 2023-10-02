module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.9.1" #ensure to update this to the latest/desired version

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    coredns = {
      preserve    = true
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    vpc-cni = {
      most_recent = true
      #preserve = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  enable_aws_load_balancer_controller = true
  #enable_cluster_proportional_autoscaler = true
  #enable_karpenter                       = true
  enable_kube_prometheus_stack           = true
  enable_metrics_server                 = true
  enable_external_dns                   = true
  enable_cert_manager                   = true
  cert_manager_route53_hosted_zone_arns = [resource.aws_route53_zone.ingress.arn]
  depends_on                            = [null_resource.update_kubeconfig]

}