terraform {
  #required_version = "1.9.3"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.8.2"
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

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

provider "talos" {
}