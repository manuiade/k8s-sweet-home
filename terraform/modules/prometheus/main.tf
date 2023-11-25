resource "helm_release" "prometheus" {
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

resource "kubectl_manifest" "ingress_prometheus" {
  count     = var.expose_prometheus_traefik == true ? 1 : 0
  yaml_body = file("${path.root}/k8s-manifest/prometheus/ingress-prometheus.yaml")
  depends_on = [ helm_release.prometheus ]
}

resource "kubectl_manifest" "ingress_grafana" {
  count     = var.expose_grafana_traefik == true ? 1 : 0
  yaml_body = file("${path.root}/k8s-manifest/prometheus/ingress-grafana.yaml")
  depends_on = [ helm_release.prometheus ]
}