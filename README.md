# Terraform Talos Proxmox configuration

## Build the Talos qcow image 

Make sure following tools are installed on your system
- docker/podman
- qemu-img

### Create an env file with Proxmox secrets (eg **secrets-proxmox.sh**)

```
unset HTTPS_PROXY
#export HTTPS_PROXY='http://localhost:8080'
export TF_VAR_proxmox_pve_node_address='<proxmox server address>'
export PROXMOX_VE_INSECURE='1'
export PROXMOX_VE_ENDPOINT="https://<proxmox server name/address>:8006"
export PROXMOX_VE_USERNAME='<proxmox user>'
export PROXMOX_VE_PASSWORD='<proxmox password>'
```

### Source the file 
`source ./secrets-proxmox.sh`

### Edit the build script

Fill out the desired versions for your environment

### Run the build script

`sudo ./build-image.sh init`

Wait for the script to finish

### Run Terraform

Edit your input variables (**terraform.tfvars**)

```
proxmox_pve_node_name = "proxmox"
proxmox_pve_node_address = "proxmox.mydomain.com"
kubernetes_version = "1.30.3"
cluster_name = "testcluster-proxmox"
cluster_vip = "192.168.1.10"
cluster_endpoint = "https://192.168.1.10:6443"
cluster_node_network_gateway = "192.168.1.1"
cluster_node_network = "192.168.1.0/24"
cluster_node_network_first_controller_hostnum = 80
cluster_node_network_first_worker_hostnum = 90
cluster_node_network_load_balancer_first_hostnum = 130
cluster_node_network_load_balancer_last_hostnum = 230
ingress_domain = "mydomain.com"
controller_count = 1
worker_count = 1
prefix = "talos-kubernetes-example"

```



Run terraform


`terraform init`
`terraform apply`
