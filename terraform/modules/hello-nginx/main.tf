resource "kubectl_manifest" "deployment" {
  count     = var.deployment == true ? 1 : 0
  yaml_body = file("${path.root}/k8s-manifest/hello-nginx/deployment.yaml")
}

resource "kubectl_manifest" "service" {
  count      = var.service == true ? 1 : 0
  yaml_body  = file("${path.root}/k8s-manifest/hello-nginx/service.yaml")
  depends_on = [kubectl_manifest.deployment]
}

resource "kubectl_manifest" "ingress_https" {
  count      = var.ingress_https == true ? 1 : 0
  yaml_body  = file("${path.root}/k8s-manifest/hello-nginx/ingress-https.yaml")
  depends_on = [kubectl_manifest.service]
}