# https://github.com/cert-manager/trust-manager/blob/v0.12.0/deploy/charts/trust-manager/values.yaml
data "helm_template" "trust_manager" {
  namespace  = "cert-manager"
  name       = "trust-manager"
  repository = "https://charts.jetstack.io"
  chart      = "trust-manager"
  version      = "0.12.0"
  kube_version = var.kubernetes_version
  api_versions = []
  set {
    name  = "secretTargets.enabled"
    value = "true"
  }
  set {
    name  = "secretTargets.authorizedSecretsAll"
    value = "true"
  }
}
