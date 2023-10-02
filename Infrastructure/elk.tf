resource "helm_release" "elk-stack" {
  name             = "elk-stack"
  repository       = "oci://registry-1.docker.io/bitnamicharts/"
  chart            = "elasticsearch"
  version          = "19.12.0"
  namespace        = "elastic"
  create_namespace = true
}