// Description : Creating a virtual machine template under Rocky Linux 9 from ISO file with Packer using VMware Workstation
// Author : Yoann LAMY <https://github.com/ynlamy/packer-rockylinux9>
// Licence : GPLv3

// Packer : https://www.packer.io/

packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "iso" {
  type        = string
  description = "A URL to the ISO file"
  default     = "local:Rocky-9.4-x86_64-minimal.iso"
}

variable "checksum" {
  type        = string
  description = "The checksum for the ISO file"
  default     = "sha256:ee3ac97fdffab58652421941599902012179c37535aece76824673105169c4a2"
}

variable "cloudinit_storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "cores" {
  type    = string
  default = "2"
}

variable "disk_format" {
  type    = string
  default = "raw"
}

variable "disk_size" {
  type    = string
  default = "20G"
}

variable "disk_storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "cpu_type" {
  type    = string
  default = "kvm64"
}

variable "memory" {
  type    = string
  default = "2048"
}

variable "network_vlan" {
  type    = string
  default = ""
}

variable "machine_type" {
  type    = string
  default = ""
}

variable "proxmox_api_password" {
  type      = string
  sensitive = true
  default   = "Fender2000"
}

variable "proxmox_api_user" {
  type = string
  default   = "root@pam"
}

variable "proxmox_host" {
  type = string
  default   = "swalwell-cloud:8006"

}

variable "proxmox_node" {
  type = string
  default   = "swalwell-cloud"
}

variable "ssh_username" {
  type        = string
  description = "The username to connect to SSH"
  default     = "root"
}

variable "ssh_password" {
  type        = string
  description = "A plaintext password to authenticate with SSH"
  default     = "Fender2000"
}

source "proxmox-iso" "rocky9" {
  proxmox_url              = "https://${var.proxmox_host}/api2/json"
  insecure_skip_tls_verify = true
  username                 = var.proxmox_api_user
  password                 = var.proxmox_api_password

  template_description = "Rocky 9.4 built on ${formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())}"
  node                 = var.proxmox_node
  network_adapters {
    bridge   = "vmbr0"
    firewall = true
    model    = "virtio"
    vlan_tag = var.network_vlan
  }
  disks {
    disk_size    = var.disk_size
    format       = var.disk_format
    io_thread    = true
    storage_pool = var.disk_storage_pool
    type         = "virtio"
  }
  scsi_controller = "virtio-scsi-single"

  boot_iso {
      type = "scsi"
      iso_file = var.iso
      unmount = true
      iso_checksum = var.checksum
  }

  http_directory = "http"
  boot_wait      = "10s"
  boot_command   = ["<up><wait><tab> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter>"]
  unmount_iso    = true

#  cloud_init              = true
#  cloud_init_storage_pool = var.cloudinit_storage_pool

  vm_name  = "rocky9"
  cpu_type = var.cpu_type
  os       = "l26"
  memory   = var.memory
  cores    = var.cores
  sockets  = "1"
  machine  = var.machine_type

  # Note: this password is needed by packer to run the file provisioner, but
  # once that is done - the password will be set to random one by cloud init.
  ssh_password = "Fender2000"
  ssh_username = "root"
}

build {
  sources = ["source.proxmox-iso.rocky9"]

    provisioner "file" {
        source = "keys/authorized_keys"
        destination = "/tmp/authorized_keys"
    }

    provisioner "shell" {
        scripts = [
            "bin/rocky-bootstrap.sh"
        ]
    }
}

