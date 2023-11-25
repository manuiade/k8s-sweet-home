resource "null_resource" "metallb_ipvs" {
  count = var.calico_cni == true ? 1 : 0
  provisioner "local-exec" {
    when    = create
    command = <<-EOT
        ../../../local-requirements/kubectl get configmap kube-proxy -n kube-system -o yaml | \
        sed -e "s/strictARP: false/strictARP: true/" | \
        ../../../local-requirements/kubectl apply -f - -n kube-system
        ../../../local-requirements/kubectl get configmap kube-proxy -n kube-system -o yaml | \
        sed -e 's/mode: ""/mode: "ipvs"/' | \
        ../../../local-requirements/kubectl apply -f - -n kube-system

        KUBE_POXY_POD_NAME=$(../../../local-requirements/kubectl get pods -no-headers -n kube-system | awk '{ print $1}' | grep kube-proxy)
        echo $KUBE_POXY_POD_NAME
        ../../../local-requirements/kubectl delete pod $KUBE_POXY_POD_NAME -n kube-system
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
        ../../../local-requirements/kubectl delete ns metallb-system
    EOT
  }
}

data "http" "metallb_manifest" {
  url = var.metallb_manifest_url
}

data "kubectl_file_documents" "metallb_objects" {
  content = data.http.metallb_manifest.response_body
}

resource "kubectl_manifest" "metallb" {
  for_each  = data.kubectl_file_documents.metallb_objects.manifests
  yaml_body = each.value

  # lifecycle {
  #   ignore_changes = [ yaml_incluster ]
  # }
}

resource "time_sleep" "wait_for_metallb" {
  create_duration = "60s"
  depends_on      = [kubectl_manifest.metallb]
}

data "kubectl_path_documents" "ip_address_pool" {
  pattern = "${path.root}/k8s-manifest/metallb/ip-address-pool.yaml"
  vars = {
    LB_IP_RANGE = var.metallb_ip_range
  }
  depends_on = [time_sleep.wait_for_metallb]
}

resource "kubectl_manifest" "ip_address_pool" {
  yaml_body = data.kubectl_path_documents.ip_address_pool.documents[0]
}

resource "kubectl_manifest" "l2_advertisement" {
  yaml_body  = file("${path.root}/k8s-manifest/metallb/l2-advertisement.yaml")
  depends_on = [kubectl_manifest.ip_address_pool]
}