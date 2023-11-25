resource "helm_release" "cert_manager" {
  name             = var.helm_chart.name
  repository       = var.helm_chart.repository
  chart            = var.helm_chart.chart
  version          = var.helm_chart.version
  namespace        = var.helm_chart.namespace
  create_namespace = var.helm_chart.create_namespace
  force_update     = var.helm_chart.force_update
  values           = [for v in var.helm_chart.values : file(v)]

  dynamic "set" {
    for_each = var.helm_chart.set
    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "kubectl_manifest" "sample_self_signed_issuer" {
  count     = var.deploy_sample_self_signed_crt == true ? 1 : 0
  yaml_body = file("${path.root}/k8s-manifest/cert-manager/issuer-self-signed.yaml")
  depends_on = [ helm_release.cert_manager ]
}

resource "kubectl_manifest" "sample_self_signed_certificate" {
  count     = var.deploy_sample_self_signed_crt == true ? 1 : 0
  yaml_body = file("${path.root}/k8s-manifest/cert-manager/certificate-self-signed.yaml")
  depends_on = [ kubectl_manifest.sample_self_signed_issuer ]
}