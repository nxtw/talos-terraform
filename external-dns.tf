data "helm_template" "external-dns" {
  namespace  = "kube-system"
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  version      = "1.14.5"
  kube_version = var.kubernetes_version
  api_versions = []
  values = [yamlencode({
    "provider" = {
        "name" = "cloudflare"
    }
    "env" = [
    {
      "name" = "CF_API_KEY"
      "valueFrom" = {
        "secretKeyRef" = {
          "key" = "apiKey"
          "name" = "cloudflare-api-key"
        }
      }
    },
    {
      "name" = "CF_API_EMAIL"
      "valueFrom" = {
        "secretKeyRef" = {
          "key" = "email"
          "name" = "cloudflare-api-key"
        }
      }
    },
  ]
})]
}
 
