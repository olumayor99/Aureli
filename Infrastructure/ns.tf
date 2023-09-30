resource "kubernetes_namespace_v1" "istio_ns" {
  metadata {
    name = "istio-system"
  }
  depends_on = [null_resource.update_kubeconfig]
}

resource "kubernetes_namespace_v1" "litmus" {
  metadata {
    labels = {
      istio-injection = "enabled"
    }
    name = "litmus"
  }
  depends_on = [null_resource.update_kubeconfig]
}