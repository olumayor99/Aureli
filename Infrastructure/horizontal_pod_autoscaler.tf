resource "kubernetes_horizontal_pod_autoscaler_v2" "frontend" {
  metadata {
    name      = "frontend"
    namespace = "default"
  }

  spec {
    min_replicas                      = 2
    max_replicas                      = 5
    target_cpu_utilization_percentage = 50

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "frontend"
    }
  }

  depends_on = [null_resource.aureli_deployment]
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "backend" {
  metadata {
    name      = "backend"
    namespace = "default"
  }

  spec {
    min_replicas                      = 2
    max_replicas                      = 5
    target_cpu_utilization_percentage = 50

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "backend"
    }
  }

  depends_on = [null_resource.aureli_deployment]
}