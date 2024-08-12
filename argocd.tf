locals {
  argocd_domain    = "argocd.${var.ingress_domain}"
  argocd_namespace = "argocd"
  argocd_manifests = [
    {
      apiVersion = "cert-manager.io/v1"
      kind       = "Certificate"
      metadata = {
        name      = "argocd-server"
        namespace = local.argocd_namespace
      }
      spec = {
        subject = {
          organizations = [
            var.ingress_domain,
          ]
          organizationalUnits = [
            "Kubernetes",
          ]
        }
        commonName = "Argo CD Server"
        dnsNames = [
          local.argocd_domain,
        ]
        privateKey = {
          algorithm = "ECDSA" # NB Ed25519 is not yet supported by chrome 93 or firefox 91.
          size      = 256
        }
        duration   = "4320h" # NB 4320h (180 days). default is 2160h (90 days).
        secretName = "argocd-server-tls"
        issuerRef = {
          kind = "ClusterIssuer"
          name = "ingress"
        }
      }
    },
  ]
  argocd_manifest = join("---\n", [for d in local.argocd_manifests : yamlencode(d)])
}

data "helm_template" "argocd" {
  namespace  = local.argocd_namespace
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  # see https://artifacthub.io/packages/helm/argo/argo-cd
  # renovate: datasource=helm depName=argo-cd registryUrl=https://argoproj.github.io/argo-helm
  version      = "7.3.11" # app version 2.11.7.
  kube_version = var.kubernetes_version
  api_versions = []
  values = [yamlencode({
    global = {
      domain = local.argocd_domain
    }
    configs = {
      params = {
        # disable tls between the argocd components.
        "server.insecure"                                = "true"
        "server.repo.server.plaintext"                   = "true"
        "server.dex.server.plaintext"                    = "true"
        "controller.repo.server.plaintext"               = "true"
        "applicationsetcontroller.repo.server.plaintext" = "true"
        "reposerver.disable.tls"                         = "true"
        "dexserver.disable.tls"                          = "true"
      }
    }
    server = {
      ingress = {
        enabled = true
        tls     = false
      }
    }
  })]
}
