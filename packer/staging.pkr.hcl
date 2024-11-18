// staging.pkr.hcl

// Similar structure to dev.pkr.hcl with adjustments for staging

locals {
  vm_name = "ubuntu-staging"
}

source "qemu" "kvm" {
  // Adjusted settings for staging
  disk_size = "4000"
  // Other settings remain the same
}

source "vmware-iso" "vmware" {
  // Adjusted settings for staging
  disk_size = 40000
  memory    = 4096
  cpus      = 2
  // Other settings remain the same
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
