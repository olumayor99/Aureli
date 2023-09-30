resource "null_resource" "aureli_deployment" {
  provisioner "local-exec" {
    command = "sh deploy.sh"
  }
  depends_on = [null_resource.istio_addons]
}