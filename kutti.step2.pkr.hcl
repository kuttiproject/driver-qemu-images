packer {
    required_plugins {
      qemu = {
        version = "~> 1"
        source  = "github.com/hashicorp/qemu"
      }
    }
}

variable "kube-version" {
  type    = string
  default = env("KUBE_VERSION")
}

variable "vm-version" {
  type    = string
  default = "latest"
}

variable "vm-description" {
  type    = string
  default = "Kutti Qemu Image"
}

source "qemu" "kutti-qemu" {
  iso_url = "out/kutti-base/kutti-base.qcow2"
  disk_image = "true"
  iso_checksum = "none"

  cpus      = "2"
  memory    = "2048"
  disk_size = "102400"
  disk_compression = true

  ssh_username = "kuttiadmin"
  ssh_password = "Pass@word1"
  ssh_timeout  = "20m"

  shutdown_command = "sudo poweroff"

  format = "qcow2"

  # The output file should be called 
  # kutti-<k8s version>.qcow2
  vm_name = "kutti-${var.kube-version}.qcow2"
  output_directory = "out/kutti-qemu"

  headless = true
}

build {
  sources = [
    "sources.qemu.kutti-qemu"
  ]

  # Set up base operating system settings and packages
  # Set up containerd and install kubernetes tools
  provisioner "shell" {
    scripts = [
      "buildscripts/setup-base.sh",
      "buildscripts/setup-kubernetes.sh"
    ]
    # These scripts must be run with sudo access
    execute_command   = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    valid_exit_codes  = [0, 2, 2300218]
    expect_disconnect = true

    # Ensure the KUBE_VERSION variable.
    environment_vars = [
      "KUBE_VERSION=${var.kube-version}"
    ]
  }

  # Copy interface scripts
  provisioner "file" {
    # Files in the kutti-scripts folder define the
    # interface between the driver and the OS in
    # the VMs.
    sources = [
      "attachments/kutti-scripts/"
    ]

    destination = "/opt/kutti/scripts"
  }

  # Make the scripts executable and create links
  # Remove unneeded software
  # Add /etc/kutti-release with component versions
  # Create and delete large empty file
  provisioner "shell" {
    scripts = [
      "buildscripts/process-scripts.sh",
      "buildscripts/cleanup.sh",
      "buildscripts/stamp-kuttirelease.sh",
      "buildscripts/pre-compact.sh"
    ]
    # These scripts must be run with sudo access
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"

    # Ensure the VM_VERSION variable.
    environment_vars = [
      "VM_VERSION=${var.vm-version}"
    ]
  }
}