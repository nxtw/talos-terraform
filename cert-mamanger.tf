locals {
  cert_manager_ingress_ca_manifests = [
    # https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.ClusterIssuer
    {
      apiVersion = "cert-manager.io/v1"
      kind       = "ClusterIssuer"
      metadata = {
        name = "selfsigned"
      }
      spec = {
        selfSigned = {}
      }
    },
    # https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.Certificate
    {
      apiVersion = "cert-manager.io/v1"
      kind       = "Certificate"
      metadata = {
        name      = "ingress"
        namespace = "cert-manager"
      }
      spec = {
        isCA = true
        subject = {
          organizations = [
            var.ingress_domain,
          ]
          organizationalUnits = [
            "Kubernetes",
          ]
        }
        commonName = "Kubernetes Ingress"
        privateKey = {
          algorithm = "ECDSA" 
          size      = 256
        }
        duration   = "4320h" 
        secretName = "ingress-tls"
        issuerRef = {
          name  = "selfsigned"
          kind  = "ClusterIssuer"
          group = "cert-manager.io"
        }
      }
    },
    # https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.ClusterIssuer
    {
      apiVersion = "cert-manager.io/v1"
      kind       = "ClusterIssuer"
      metadata = {
        name = "ingress"
      }
      spec = {
        ca = {
          secretName = "ingress-tls"
        }
      }
    },
  ]
  cert_manager_ingress_ca_manifest = join("---\n", [for d in local.cert_manager_ingress_ca_manifests : yamlencode(d)])
}

data "helm_template" "cert_manager" {
  namespace  = "cert-manager"
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version      = "1.15.1"
  kube_version = var.kubernetes_version
  api_versions = []
  set {
    name  = "installCRDs"
    value = "true"
  }
}
