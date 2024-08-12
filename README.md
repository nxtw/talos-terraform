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

`terraform init`
`terraform apply`
