terraform {
  required_version = "1.9.4"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.4"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.62.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.14.0"
    }
    
  }
}


provider "kubernetes" {
  config_path    = "~/.kube/config"
  #config_context = "my-context"
}

provider "proxmox" {
  tmp_dir = "tmp"
  insecure = true
  ssh {
    node {
      name    = var.proxmox_pve_node_name
      address = var.proxmox_pve_node_address
    }
  }
}

provider "talos" {
}
