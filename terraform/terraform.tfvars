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

hello_nginx = {
    deployment = true
    service = true
    ingress_https = true # requires traefik and cert_manager previously installed
}