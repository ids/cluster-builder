// Description : Creating a virtual machine template under Rocky Linux 9 from ISO file with Packer using VMware Workstation
// Author : Yoann LAMY <https://github.com/ynlamy/packer-rockylinux9>
// Licence : GPLv3

// Packer : https://www.packer.io/

packer {
  required_version = ">= 1.7.0"
  required_plugins {
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

variable "iso" {
  type        = string
  description = "A URL to the ISO file"
  default     = "iso/Rocky-9.4-x86_64-minimal.iso"
}

variable "checksum" {
  type        = string
  description = "The checksum for the ISO file"
  default     = "sha256:ee3ac97fdffab58652421941599902012179c37535aece76824673105169c4a2"
}

variable "headless" {
  type        = bool
  description = "When this value is set to true, the machine will start without a console"
  default     = true
}

variable "name" {
  type        = string
  description = "This is the name of the new virtual machine"
  default     = "cluster-node-x86_64"
}

variable "username" {
  type        = string
  description = "The username to connect to SSH"
  default     = "admin"
}

variable "password" {
  type        = string
  description = "A plaintext password to authenticate with SSH"
  default     = "TempPass2024"
}

source "vmware-iso" "rockylinux9" {
  // Documentation : https://developer.hashicorp.com/packer/integrations/hashicorp/vmware/latest/components/builder/iso

  // ISO configuration
  iso_url      = var.iso
  iso_checksum = var.checksum

  // Driver configuration
  cleanup_remote_cache = false
  
  // Hardware configuration
  vm_name           = var.name
  vmdk_name         = var.name
  version           = "21"
  guest_os_type     = "rockylinux-64"
  cpus              = 2
  //vmx_data = {
  //  "numvcpus" = "2"
  //}
  memory            = 2048
  disk_size         = 256000
  network           = "nat"
  sound             = false
  usb               = false

  // Run configuration
  headless = var.headless

  // Shutdown configuration
  shutdown_command = "sudo systemctl poweroff"
  //shutdown_command = "sudo -S /sbin/halt -h -p"

  // Http directory configuration
  http_directory = "http"

  // Boot configuration
  boot_command = ["<up><wait><tab> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter>"]
  boot_wait    = "10s"

  // Communicator configuration
  communicator = "ssh"
  ssh_username = var.username
  ssh_password = var.password
  ssh_timeout  = "30m"

  // Output configuration
  output_directory = "cluster-node"

  // Export configuration
  format          = "ova"
  skip_compaction = false  
}

build {
    sources = ["source.vmware-iso.rockylinux9"]

    provisioner "file" {
        source = "keys/authorized_keys"
        destination = "/tmp/authorized_keys"
    }

    provisioner "shell" {
        scripts = [
            "bin/rocky-bootstrap.sh"
        ]
    }

/*     post-processor "shell-local" {
        inline = ["ovftool --overwrite node/cluster-node-centos8-x86_64.vmx output_ovas/cluster-node-centos8-x86_64.ova"]
    }
 */}