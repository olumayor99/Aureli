resource "helm_release" "litmus_chaos" {
  name             = "litmus-chaos"
  namespace        = "litmus"
  repository       = "https://litmuschaos.github.io/litmus-helm/"
  chart            = "litmus"
  version          = "2.15.10"
  create_namespace = true
  depends_on       = [module.eks_blueprints_addons]
}