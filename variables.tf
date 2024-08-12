variable "proxmox_pve_node_name" {
  type    = string
}

variable "proxmox_pve_node_address" {
  type = string
}

# https://github.com/siderolabs/talos/releases
variable "talos_version" {
  type = string
  default = "1.7.6"
  validation {
    condition     = can(regex("^\\d+(\\.\\d+)+", var.talos_version))
    error_message = "Must be a version number."
  }
}

# https://github.com/siderolabs/kubelet/pkgs/container/kubelet
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
  default     = "testcluster"
}

variable "cluster_vip" {
  description = "A name to provide for the Talos cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "The k8s api-server (VIP) endpoint"
  type        = string
}

variable "cluster_node_network_gateway" {
  description = "The IP network gateway of the cluster nodes"
  type        = string
}

variable "cluster_node_network" {
  description = "The IP network prefix of the cluster nodes"
  type        = string
}

variable "cluster_node_network_first_controller_hostnum" {
  description = "The hostnum of the first controller host"
  type        = number
}

variable "cluster_node_network_first_worker_hostnum" {
  description = "The hostnum of the first worker host"
  type        = number
}

variable "cluster_node_network_load_balancer_first_hostnum" {
  description = "The hostnum of the first load balancer host"
  type        = number
}

variable "cluster_node_network_load_balancer_last_hostnum" {
  description = "The hostnum of the last load balancer host"
  type        = number
}

variable "ingress_domain" {
  description = "the DNS domain of the ingress resources"
  type        = string
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
  default = 1
  validation {
    condition     = var.worker_count >= 1
    error_message = "Must be 1 or more."
  }
}

variable "prefix" {
  type    = string
  default = "talos-kubernetes-example"
}
