data "helm_template" "external-dns" {
  namespace  = "kube-system"
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  version      = "0.14.2"
  kube_version = var.kubernetes_version
  api_versions = []
  values = [yamlencode({
    provider = {
        name = "cloudflare"
    }
    env = {
        
    }

  })}
}
