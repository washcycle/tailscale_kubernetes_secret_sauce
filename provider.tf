terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.3.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "docker-desktop"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "docker-desktop"
  }
}

resource "kubernetes_manifest" "ts_proxies" {
  manifest = {
    apiVersion = "tailscale.com/v1alpha1"
    kind       = "ProxyGroup"
    metadata = {
      name = "ts-proxies"
    }
    spec = {
      type     = "egress"
      replicas = 3
    }
  }
}
