// prod.pkr.hcl

// Similar structure to dev.pkr.hcl with adjustments for production

locals {
  vm_name = "ubuntu-prod"
}

source "qemu" "kvm" {
  // Adjusted settings for production
  disk_size = "8000"
  // Other settings remain the same
}

source "vmware-iso" "vmware" {
  // Adjusted settings for production
  disk_size = 80000
  memory    = 8192
  cpus      = 4
  // Other settings remain the same
}

build {
  name    = "myapp-prod-build"
  sources = [
    "source.qemu.kvm",
    "source.vmware-iso.vmware"
  ]

  provisioner "shell" {
    script = "scripts/prod.sh"
  }
}
