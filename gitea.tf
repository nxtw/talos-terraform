locals {
  gitea_domain = "gitea.${var.ingress_domain}"
  gitea_namespace = "default"
  gitea_manifests = [
    {
      apiVersion = "cert-manager.io/v1"
      kind       = "Certificate"
      metadata = {
        name      = "gitea"
        namespace = local.gitea_namespace
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
        commonName = "gitea"
        dnsNames = [
          local.gitea_domain,
        ]
        privateKey = {
          algorithm = "ECDSA" 
          size      = 256
        }
        duration   = "4320h" 
        secretName = "gitea-tls"
        issuerRef = {
          kind = "ClusterIssuer"
          name = "ingress"
        }
      }
    },
  ]
  gitea_manifest = join("---\n", [for d in local.gitea_manifests : yamlencode(d)])
}


# https://gitea.com/gitea/helm-chart/src/tag/v10.4.0/values.yaml
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/data-sources/template
data "helm_template" "gitea" {
  namespace  = local.gitea_namespace
  name       = "gitea"
  repository = "https://dl.gitea.com/charts"
  chart      = "gitea"
  version      = "10.4.0"
  kube_version = var.kubernetes_version
  api_versions = [
    "networking.k8s.io/v1/Ingress",
  ]
  values = [yamlencode({
    redis-cluster = {
      enabled = false
    }
    redis = {
      enabled = false
    }
    postgresql = {
      enabled = false
    }
    postgresql-ha = {
      enabled = false
    }
    persistence = {
      enabled      = true
      storageClass = "linstor-lvm-r1"
      claimName    = "gitea"
    }
    gitea = {
      config = {
        database = {
          DB_TYPE = "sqlite3"
        }
        session = {
          PROVIDER = "memory"
        }
        cache = {
          ADAPTER = "memory"
        }
        queue = {
          TYPE = "level"
        }
      }
      admin = {
        username = "gitea"
        password = "gitea"
        email    = "gitea@${var.ingress_domain}"
      }
    }
    service = {
      http = {
        type      = "ClusterIP"
        port      = 3000
        clusterIP = null
      }
      ssh = {
        type      = "ClusterIP"
        port      = 22
        clusterIP = null
      }
    }
    ingress = {
      enabled = true
      hosts = [
        {
          host = local.gitea_domain
          paths = [
            {
              path     = "/"
              pathType = "Prefix"
            }
          ]
        }
      ]
      tls = [
        {
          secretName = "gitea-tls"
          hosts = [
            local.gitea_domain,
          ]
        }
      ]
    }
  })]
}
