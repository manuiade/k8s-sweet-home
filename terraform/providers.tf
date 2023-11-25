terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
  required_version = "~> 1.5.0"
}

# Same parameters as kubernetes provider
provider "kubectl" {
  config_path    = "../ansible/static/kubeconfig"
  config_context = "kubernetes-admin@kubernetes"
}

provider "helm" {
  kubernetes {
    config_path    = "../ansible/static/kubeconfig"
    config_context = "kubernetes-admin@kubernetes"
  }
}