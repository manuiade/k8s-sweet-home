terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
  required_version = "~> 1.4.0"
}

# Same parameters as kubernetes provider
provider "kubectl" {
  config_path    = "../ansible/static/kubeconfig"
  config_context = "kubernetes-admin@kubernetes"
}