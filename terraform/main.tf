module "metallb" {
  count                = var.metallb.install == true ? 1 : 0
  source               = "./modules/metallb"
  calico_cni           = var.metallb.calico_cni
  metallb_manifest_url = var.metallb.manifest_url
  metallb_ip_range     = var.metallb.ip_range
}

module "traefik" {
  count            = var.traefik.install == true ? 1 : 0
  source           = "./modules/traefik"
  helm_chart       = var.traefik.helm_chart
  expose_dashboard = var.traefik.expose_dashboard

  depends_on = [module.metallb]
}

module "cert_manager" {
  count                         = var.cert_manager.install == true ? 1 : 0
  source                        = "./modules/cert-manager"
  helm_chart                    = var.cert_manager.helm_chart
  deploy_sample_self_signed_crt = var.cert_manager.deploy_sample_self_signed_crt

  depends_on = [module.traefik]
}

module "prometheus" {
  count                     = var.prometheus.install == true ? 1 : 0
  source                    = "./modules/prometheus"
  helm_chart                = var.prometheus.helm_chart
  expose_prometheus_traefik = var.prometheus.expose_prometheus_traefik
  expose_grafana_traefik    = var.prometheus.expose_grafana_traefik

  depends_on = [module.cert_manager]
}

module "tekton" {
  count = var.tekton.install == true ? 1 : 0
  source                     = "./modules/tekton"
  public_tasks = var.tekton.public_tasks
}

module "istio" {
  count                         = var.istio.install == true ? 1 : 0
  source                        = "./modules/istio"
  helm_chart                    = var.istio.helm_chart
  defaultRevision = var.istio.defaultRevision
  depends_on = [module.traefik]
}

module "hello_nginx" {
  source        = "./modules/hello-nginx"
  deployment    = var.hello_nginx.deployment
  service       = var.hello_nginx.service
  ingress_https = var.hello_nginx.ingress_https

  depends_on = [module.cert_manager]
}