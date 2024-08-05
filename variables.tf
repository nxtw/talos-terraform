# https://github.com/siderolabs/talos/releases
# https://www.talos.dev/v1.7/introduction/support-matrix/
variable "talos_version" {
  type = string
  # renovate: datasource=github-releases depName=siderolabs/talos
  default = "1.7.5"
  validation {
    condition     = can(regex("^\\d+(\\.\\d+)+", var.talos_version))
    error_message = "Must be a version number."
  }
}

# https://github.com/siderolabs/kubelet/pkgs/container/kubelet
# https://www.talos.dev/v1.7/introduction/support-matrix/
variable "kubernetes_version" {
  type = string
  default = "1.30.3"
  validation {
    condition     = can(regex("^\\d+(\\.\\d+)+", var.kubernetes_version))
    error_message = "Must be a version number."
  }
}

variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
  default     = "example"
}

variable "cluster_vip" {
  description = "A name to provide for the Talos cluster"
  type        = string
  default     = "192.168.1.200"
}

variable "cluster_endpoint" {
  description = "The k8s api-server (VIP) endpoint"
  type        = string
  default     = "https://192.168.1.200:6443" # k8s api-server endpoint.
}

variable "cluster_node_network" {
  description = "The IP network of the cluster nodes"
  type        = string
  default     = "192.168.1.0/24"
}

variable "cluster_node_network_first_controller_hostnum" {
  description = "The hostnum of the first controller host"
  type        = number
  default     = 80
}

variable "cluster_node_network_first_worker_hostnum" {
  description = "The hostnum of the first worker host"
  type        = number
  default     = 90
}

variable "cluster_node_network_load_balancer_first_hostnum" {
  description = "The hostnum of the first load balancer host"
  type        = number
  default     = 100
}

variable "cluster_node_network_load_balancer_last_hostnum" {
  description = "The hostnum of the last load balancer host"
  type        = number
  default     = 210
}

variable "cluster_node_network_gateway" {
  description = "The gateway"
  type        = string
  default     = "192.168.1.1"
}

variable "cluster_node_network_nameservers" {
  description = "The nameservers"
  type        = list(string)
  default     = ["1.1.1.1", "1.0.0.1"]
}

variable "cluster_node_network_timeservers" {
  description = "The timeservers"
  type        = list(string)
  default     = ["pool.ntp.org"]
}

variable "ingress_domain" {
  description = "the DNS domain of the ingress resources"
  type        = string
  default     = "example.test"
}

variable "controller_count" {
  type    = number
  default = 1
  validation {
    condition     = var.controller_count >= 1
    error_message = "Must be 1 or more."
  }
}

variable "worker_count" {
  type    = number
  default = 3
  validation {
    condition     = var.worker_count >= 1
    error_message = "Must be 1 or more."
  }
}

variable "vsphere_user" {
  type    = string
  default = "administrator@vsphere.local"
}

variable "vsphere_password" {
  type      = string
  default   = "password"
  sensitive = true
}

variable "vsphere_server" {
  type    = string
  default = "vsphere.local"
}

variable "vsphere_datacenter" {
  type    = string
  default = "Datacenter"
}

variable "vsphere_compute_cluster" {
  type    = string
  default = "Cluster"
}

variable "vsphere_network" {
  type    = string
  default = "VM Network"
}

variable "vsphere_datastore" {
  type    = string
  default = "Datastore"
}

variable "vsphere_folder" {
  type    = string
  default = "example"
}

variable "vsphere_talos_template" {
  type    = string
  default = "Templates/talos-1.7.5-amd64"
}

variable "prefix" {
  type    = string
  default = "terraform-talos-example"
}
