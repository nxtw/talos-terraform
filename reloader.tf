#  https://github.com/stakater/reloader/blob/v1.0.119/deployments/kubernetes/chart/reloader/values.yaml
data "helm_template" "reloader" {
  namespace  = "kube-system"
  name       = "reloader"
  repository = "https://stakater.github.io/stakater-charts"
  chart      = "reloader"
  version      = "1.0.119"
  kube_version = var.kubernetes_version
  api_versions = []
  set {
    name  = "reloader.autoReloadAll"
    value = "false"
  }
}
