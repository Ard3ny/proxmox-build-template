variable "proxmox_host_node" {
  type    = string
  default = "pve"
}

variable "proxmox_source_template" {
  type    = string
  default = "debian-temp"
}

variable "proxmox_template_name" {
  type    = string
  default = "debian-template"
}

variable "proxmox_api_url" {
  type    = string
}

# token/secret auth method 
variable "proxmox_api_token_id" {
  type    = string
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

#If you want to use username/password instead of token
#variable "proxmox_api_username" {
#  type    = string
#  default = "root@pve"
#}

#variable "proxmox_api_password" {
#  type    = string
#  sensitive = true
#}

variable "proxmox_network_bridge" {
  type    = string
  default = "vmbr0"
}

packer {
  required_plugins {
    proxmox = {
      version = " >= 1.0.1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-clone" "ubuntu" {
  insecure_skip_tls_verify = true
  full_clone = false

  template_name = "${var.proxmox_template_name}"
  template_description = "Built at ${timestamp()} by Packer"
  clone_vm      = "${var.proxmox_source_template}"

  os              = "l26"
  cores           = "1"
  memory          = "1024"
  scsi_controller = "virtio-scsi-pci"
  vm_id           = "9000"

  ssh_username = "packer"
  ssh_timeout = "10m"

  qemu_agent = true

  network_adapters {
    bridge = "${var.proxmox_network_bridge}"
    model  = "virtio"
  }

  node          = "${var.proxmox_host_node}"

  #username/passwort auth method
  #username      = "${var.proxmox_api_username}"
  #password      = "${var.proxmox_api_password}"

  #token ID / secret auth method 
  username      = "${var.proxmox_api_token_id}"
  token         = "${var.proxmox_api_token_secret}"
  
  proxmox_url   = "${var.proxmox_api_url}"
}

build {
  sources = ["source.proxmox-clone.ubuntu"]

  provisioner "shell" {
    script = "bin/bootstrap_ubuntu.sh"
  }
}