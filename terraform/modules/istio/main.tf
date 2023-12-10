resource "helm_release" "istio_base" {
  name             = "istio-base"
  repository       = var.helm_chart.repository
  chart            = "base"
  version          = var.helm_chart.version
  namespace        = var.helm_chart.namespace
  create_namespace = var.helm_chart.create_namespace
  force_update     = var.helm_chart.force_update
  values           = [for v in var.helm_chart.values : file(v)]

  set {
    name = "defaultRevision"
    value = var.defaultRevision 
  }

  dynamic "set" {
    for_each = var.helm_chart.set
    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "helm_release" "istio_system" {
  name             = "istiod"
  repository       = var.helm_chart.repository
  chart            = "istiod"
  version          = var.helm_chart.version
  namespace        = var.helm_chart.namespace
  create_namespace = false
  force_update     = var.helm_chart.force_update
  values           = [for v in var.helm_chart.values : file(v)]

  depends_on = [ helm_release.istio_base ]
}