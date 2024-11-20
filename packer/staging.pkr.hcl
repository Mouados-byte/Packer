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
  iso_url           = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
  iso_checksum      = "9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"
  disk_size        = "4000M"
  memory           = 2048
  cpus             = 2
  headless         = true
  ssh_username     = "packer"
  ssh_password     = "packer"
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
  iso_checksum      = "9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"
  disk_size         = 40000
  memory            = 4096
  cpus              = 2
  ssh_username      = "packer"
  ssh_password      = "packer"
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