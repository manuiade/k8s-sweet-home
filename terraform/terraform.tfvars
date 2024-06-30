# Metallb configuration
metallb = {
  install      = true
  manifest_url = "https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml"
  ip_range     = "192.168.178.8/30"
  calico_cni   = false
}

# Traefik configuration (required Metallb)
traefik = {
  install = true
  helm_chart = {
    name             = "traefik"
    chart            = "traefik"
    repository       = "https://helm.traefik.io/traefik"
    namespace        = "traefik"
    create_namespace = true
    force_update     = true
    values           = ["./k8s-manifest/traefik/helm-values.yaml"]
  }
  expose_dashboard = true
}

cert_manager = {
  install = true
  helm_chart = {
    name             = "cert-manager",
    chart            = "cert-manager",
    repository       = "https://charts.jetstack.io"
    namespace        = "cert-manager"
    create_namespace = true
    set = {
      "installCRDs" = true
    }
  }
  deploy_sample_self_signed_crt = true
}

prometheus = {
  install = true
  helm_chart = {
    name             = "prometheus"
    chart            = "kube-prometheus-stack"
    repository       = "https://prometheus-community.github.io/helm-charts"
    namespace        = "prometheus"
    create_namespace = true
  }
  expose_prometheus_traefik = true # need traefik and metallb to be installed
  expose_grafana_traefik    = true # need traefik and metallb to be installed
  # grafana dashboards = 12740, 3119, 6417
}

tekton = {
  install = false
  public_tasks = [
    "https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.9/git-clone.yaml",
    "https://raw.githubusercontent.com/tektoncd/catalog/main/task/kaniko/0.6/kaniko.yaml"
  ]
}

istio = {
  install = false
  helm_chart = {
    repository       = "https://istio-release.storage.googleapis.com/charts"
    namespace        = "istio-system"
    create_namespace = true
  }
  defaultRevision = "default"
}

# hello_nginx = {
#   deployment    = true
#   service       = true
#   ingress_https = true # requires traefik and cert_manager previously installed
# }