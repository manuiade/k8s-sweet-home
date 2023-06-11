module "metallb" {
  count                = var.install_metallb == true ? 1 : 0
  source               = "./modules/metallb"
  calico_cni           = var.calico_cni
  metallb_manifest_url = var.metallb_manifest_url
  metallb_ip_range     = var.metallb_ip_range
}

data "kubectl_file_documents" "nginx" {
  content = file("${path.root}/nginx.yaml")
}

resource "kubectl_manifest" "metallb" {
  for_each  = data.kubectl_file_documents.nginx.manifests
  yaml_body = each.value
}