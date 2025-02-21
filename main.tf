resource "kubernetes_namespace" "tailscale" {
  metadata {
    name = "tailscale"
  }
}

variable "oauth_client_id" {
  type      = string
  sensitive = true
}

variable "oauth_client_secret" {
  type      = string
  sensitive = true
}

resource "helm_release" "tailscale_operator" {
  name             = "tailscale-operator"
  namespace        = kubernetes_namespace.tailscale.metadata[0].name
  repository       = "https://pkgs.tailscale.com/helmcharts"
  chart            = "tailscale-operator"
  version          = "1.80.0"
  create_namespace = false


  set {
    name  = "namespace"
    value = kubernetes_namespace.tailscale.metadata[0].name
  }

  set_sensitive {
    name  = "oauth.clientId"
    value = var.oauth_client_id
  }

  set_sensitive {
    name  = "oauth.clientSecret"
    value = var.oauth_client_secret
  }

  set {
    name  = "apiServerProxyConfig.mode"
    value = true
  }
}

resource "kubernetes_cluster_role_binding" "tailnet_readers_view" {
  metadata {
    name = "tailnet-readers-view"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }

  subject {
    kind      = "Group"
    name      = "tailnet-readers"
    api_group = "rbac.authorization.k8s.io"
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