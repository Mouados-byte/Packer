packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
    vmware = {
      source  = "github.com/hashicorp/vmware"
      version = "~> 1"
    }
  }
}

locals {
  vm_name = "ubuntu-staging"
}

source "qemu" "kvm" {
  iso_url           = "https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso"
  iso_checksum      = "sha256:a4acfda10b18da50e2ec50ccaf860d7f20b389df8765611142305c0e911d16fd"
  disk_size        = "4000M"
  memory           = 2048
  cpus             = 2
  headless         = true
  ssh_username     = "ubuntu"
  ssh_password     = "ubuntu"
  ssh_timeout      = "30m"
  shutdown_command = "echo 'ubuntu' | sudo -S shutdown -P now"
  vm_name          = local.vm_name
  accelerator      = "kvm"
  format           = "qcow2"
  output_directory = "output-staging"
  boot_wait        = "10s"
  boot_command     = [
    "<enter><enter><f6><esc><wait>",
    " autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<enter>"
  ]
  http_directory   = "http"
}

source "vmware-iso" "vmware" {
  iso_url           = "https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso"
  iso_checksum      = "sha256:a4acfda10b18da50e2ec50ccaf860d7f20b389df8765611142305c0e911d16fd"
  disk_size         = 40000
  memory            = 4096
  cpus              = 2
  ssh_username      = "ubuntu"
  ssh_password      = "ubuntu"
  ssh_timeout       = "30m"
  shutdown_command  = "echo 'ubuntu' | sudo -S shutdown -P now"
  vm_name           = local.vm_name
  guest_os_type     = "ubuntu-64"
  output_directory  = "output-staging-vmware"
  boot_wait         = "10s"
  headless          = true
  boot_command      = [
    "<enter><enter><f6><esc><wait>",
    " autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<enter>"
  ]
  http_directory    = "http"
}

build {
  name    = "myapp-staging-build"
  sources = [
    "source.qemu.kvm",
    "source.vmware-iso.vmware"
  ]

  provisioner "shell" {
    script = "scripts/staging.sh"
  }
}