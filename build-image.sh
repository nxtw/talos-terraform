#!/bin/bash
set -euo pipefail
talos_version="1.7.6"
talos_qemu_guest_agent_extension_version="9.0.1"
talos_drbd_extension_version="9.2.8"
talos_spin_extension_version="0.15.0"
piraeus_operator_version="2.5.2"

export TALOSCONFIG=$PWD/talosconfig.yml
export KUBECONFIG=$PWD/kubeconfig.yml

function step {
  echo "### $* ###"
}

function build_talos_image {
  local talos_version_tag="v$talos_version"
  rm -rf tmp/talos
  mkdir -p tmp/talos
  cat >"tmp/talos/talos-$talos_version.yml" <<EOF
arch: amd64
platform: nocloud
secureboot: false
version: $talos_version_tag
customization:
  extraKernelArgs:
    - net.ifnames=0
input:
  kernel:
    path: /usr/install/amd64/vmlinuz
  initramfs:
    path: /usr/install/amd64/initramfs.xz
  baseInstaller:
    imageRef: ghcr.io/siderolabs/installer:$talos_version_tag
  systemExtensions:
    - imageRef: ghcr.io/siderolabs/qemu-guest-agent:$talos_qemu_guest_agent_extension_version
    - imageRef: ghcr.io/siderolabs/drbd:$talos_drbd_extension_version-v$talos_version
    - imageRef: ghcr.io/siderolabs/spin:v$talos_spin_extension_version
output:
  kind: image
  imageOptions:
    diskSize: $((2*1024*1024*1024))
    diskFormat: raw
  outFormat: raw
EOF
  docker run --rm -i \
    -v $PWD/tmp/talos:/secureboot:ro \
    -v $PWD/tmp/talos:/out \
    -v /dev:/dev \
    --privileged \
    "ghcr.io/siderolabs/imager:$talos_version_tag" \
    - < "tmp/talos/talos-$talos_version.yml"
  local img_path="tmp/talos/talos-$talos_version.qcow2"
  qemu-img convert -O qcow2 tmp/talos/nocloud-amd64.raw $img_path
  qemu-img info $img_path
  cat >terraform.tfvars <<EOF
talos_version = "$talos_version"
EOF
}

function init {
  step 'build talos image'
  build_talos_image
}

case $1 in
  init)
    init
    ;;
#   plan)
#     plan
#     ;;
#   apply)
#     apply
#     ;;
#   plan-apply)
#     plan
#     apply
#     ;;
#   health)
#     health
#     ;;
#   info)
#     info
#     ;;
#   destroy)
#     destroy
#     ;;
  *)
    echo $"Usage: $0 {init}"
    exit 1
    ;;
esac