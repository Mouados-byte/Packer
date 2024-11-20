packer {
  required_version = ">= 1.7.0"

  required_plugins {
    qemu = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/qemu"
    }
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
}

variable "iso_checksum" {
  type    = string
  default = "b8f31413336b9393ad5d8ef0282717b2ab19f007df2e9ed5196c13d8f9153c8b"
}

variable "http_port_min" {
  type    = number
  default = 8000
}

variable "http_port_max" {
  type    = number
  default = 9000
}

locals {
  vm_name = "ubuntu-dev"
}

source "qemu" "kvm" {
  iso_url            = var.iso_url
  iso_checksum       = var.iso_checksum
  output_directory   = "output/kvm/dev"
  vm_name            = local.vm_name
  disk_size          = "2000"
  format             = "qcow2"
  headless           = true
  accelerator        = "kvm"
  http_directory     = "http"
  http_port_min      = var.http_port_min
  http_port_max      = var.http_port_max
  shutdown_command   = "echo 'packer' | sudo -S shutdown -P now"
  ssh_username       = "packer"
  ssh_password       = "packer"
  ssh_timeout        = "30m"

  boot_command = [
    "<esc><wait>",
    "linux /casper/vmlinuz ",
    "initrd=/casper/initrd ",
    "autoinstall ",
    "ds=nocloud-net;s=http://10.0.2.2:{{ .HTTPPort }}/ ",
    "<enter>"
  ]
}

source "vmware-iso" "vmware" {
  iso_url            = var.iso_url
  iso_checksum       = var.iso_checksum
  output_directory   = "output/vmware/dev"
  vm_name            = local.vm_name
  guest_os_type      = "ubuntu-64"
  disk_size          = 20000
  memory             = 2048
  cpus               = 2
  headless           = true
  http_directory     = "http"
  http_port_min      = var.http_port_min
  http_port_max      = var.http_port_max
  shutdown_command   = "echo 'packer' | sudo -S shutdown -P now"
  ssh_username       = "packer"
  ssh_password       = "packer"
  ssh_wait_timeout   = "30m"

  boot_command = [
    "<esc><wait>",
    "linux /casper/vmlinuz ",
    "initrd=/casper/initrd ",
    "autoinstall ",
    "ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
    "<enter>"
  ]
}

build {
  name    = "myapp-dev-build"
  sources = [
    "source.qemu.kvm",
    "source.vmware-iso.vmware"
  ]

  provisioner "shell" {
    script = "scripts/dev.sh"
  }
}