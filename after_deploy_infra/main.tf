resource "kubernetes_manifest" "ts_proxies" {  
  manifest = {
    apiVersion = "tailscale.com/v1alpha1"
    kind       = "ProxyGroup"
    metadata = {
      name = "herro-yuy-ts-egress-proxies"
    }
    spec = {
      type     = "egress"
      replicas = 3
    }
  }
}