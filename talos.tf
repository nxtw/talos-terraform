locals {
  network_mask = tonumber(split("/", var.cluster_node_network)[1])
  controller_nodes = [
    for i in range(var.controller_count) : {
      name    = "controller-${i}"
      address = cidrhost(var.cluster_node_network, var.cluster_node_network_first_controller_hostnum + i)
    }
  ]
  worker_nodes = [
    for i in range(var.worker_count) : {
      name    = "worker-${i}"
      address = cidrhost(var.cluster_node_network, var.cluster_node_network_first_worker_hostnum + i)
    }
  ]
  common_machine_config = {
    machine = {
      features = {
        #https://www.talos.dev/v1.7/kubernetes-guides/configuration/kubeprism/
        kubePrism = {
          enabled = true
          port    = 7445
        }
      }
      kernel = {
        modules = []
      }
    }
    cluster = {
      #https://www.talos.dev/v1.7/talos-guides/discovery/
      #https://www.talos.dev/v1.7/reference/configuration/#clusterdiscoveryconfig
      discovery = {
        enabled = true
        registries = {
          kubernetes = {
            disabled = false
          }
          service = {
            disabled = true
          }
        }
      }
      network = {
        cni = {
          name = "none"
        }
      }
      proxy = {
        disabled = true
      }
    }
  }
}

// https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/resources/machine_secrets
resource "talos_machine_secrets" "talos" {
  talos_version = "v${var.talos_version}"
}

// https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/data-sources/machine_configuration
data "talos_machine_configuration" "controller" {
  count              = var.controller_count
  cluster_name       = var.cluster_name
  cluster_endpoint   = var.cluster_endpoint
  machine_secrets    = talos_machine_secrets.talos.machine_secrets
  machine_type       = "controlplane"
  talos_version      = "v${var.talos_version}"
  kubernetes_version = var.kubernetes_version
  examples           = false
  docs               = false
  config_patches = [
    yamlencode(local.common_machine_config),
    yamlencode({
      machine = {
        install = {
          disk = "/dev/sda"
        }
        network = {
          hostname = local.controller_nodes[count.index].name
          interfaces = [
            {
              interface = "eth0"
              dhcp      = false
              addresses = ["${local.controller_nodes[count.index].address}/${local.network_mask}"]
              routes = [
                {
                  network = "0.0.0.0/0"
                  gateway = var.cluster_node_network_gateway
                }
              ]
              # https://www.talos.dev/v1.7/talos-guides/network/vip/
              vip = {
                ip = var.cluster_vip
              }
            }
          ]
          nameservers = var.cluster_node_network_nameservers
        }
        time = {
          servers = var.cluster_node_network_timeservers
        }
      }
    }),
    yamlencode({
      cluster = {
        inlineManifests = [
          {
            name = "cilium"
            contents = join("---\n", [
              data.helm_template.cilium.manifest,
              "# Source cilium.tf\n${local.cilium_external_lb_manifest}",
            ])
          },
          {
            name = "argocd"
            contents = join("---\n", [
              yamlencode({
                apiVersion = "v1"
                kind       = "Namespace"
                metadata = {
                  name = local.argocd_namespace
                }
              }),
              data.helm_template.argocd.manifest,
              "# Source argocd.tf\n${local.argocd_manifest}",
            ])
          },
        ],
      },
    }),
  ]
}

// https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/data-sources/machine_configuration
data "talos_machine_configuration" "worker" {
  count              = var.worker_count
  cluster_name       = var.cluster_name
  cluster_endpoint   = var.cluster_endpoint
  machine_secrets    = talos_machine_secrets.talos.machine_secrets
  machine_type       = "worker"
  talos_version      = "v${var.talos_version}"
  kubernetes_version = var.kubernetes_version
  examples           = false
  docs               = false
  config_patches = [
    yamlencode(local.common_machine_config),
    yamlencode({
      machine = {
        install = {
          disk = "/dev/sda"
        }
        network = {
          hostname = local.worker_nodes[count.index].name
          interfaces = [
            {
              interface = "eth0"
              dhcp      = false
              addresses = ["${local.worker_nodes[count.index].address}/${local.network_mask}"]
              routes = [
                {
                  network = "0.0.0.0/0"
                  gateway = var.cluster_node_network_gateway
                }
              ]
            }
          ]
          nameservers = var.cluster_node_network_nameservers
        }
        time = {
          servers = var.cluster_node_network_timeservers
        }
      }
    }),
  ]
}

// https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/data-sources/client_configuration
data "talos_client_configuration" "talos" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.talos.client_configuration
  endpoints            = [for node in local.controller_nodes : node.address]
}

// https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/data-sources/cluster_kubeconfig
data "talos_cluster_kubeconfig" "talos" {
  client_configuration = talos_machine_secrets.talos.client_configuration
  endpoint             = local.controller_nodes[0].address
  node                 = local.controller_nodes[0].address
  depends_on = [
    talos_machine_bootstrap.talos,
  ]
}

// https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/resources/machine_bootstrap
resource "talos_machine_bootstrap" "talos" {
  client_configuration = talos_machine_secrets.talos.client_configuration
  endpoint             = local.controller_nodes[0].address
  node                 = local.controller_nodes[0].address
  depends_on = [
    vsphere_virtual_machine.controller,
  ]
}