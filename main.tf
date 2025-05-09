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
  version          = "1.80.3"
  create_namespace = false

  set {
    name  = "operatorConfig.hostname"
    value = "heero-yuy"
  }

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
    value = "true"
    type  = "string"
  }
}

resource "kubernetes_cluster_role_binding" "tailnet_readers_view" {
  depends_on = [ helm_release.tailscale_operator ]
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


