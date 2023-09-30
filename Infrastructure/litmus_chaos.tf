resource "helm_release" "litmus_chaos" {
  name             = "litmus-chaos"
  namespace = kubernetes_namespace_v1.litmus.metadata[0].name
  repository       = "https://litmuschaos.github.io/litmus-helm/"
  chart            = "litmus"
  version          = "2.15.10"

  depends_on = [module.eks_blueprints_addons]
}