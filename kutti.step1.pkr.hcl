packer {
    required_plugins {
      qemu = {
        version = "~> 1"
        source  = "github.com/hashicorp/qemu"
      }
    }
}

variable "iso-url" {
  # Location of a debian netinst iso
  type    = string
}

variable "iso-checksum" {
  # Checksum of the debian netinst iso
  type    = string
}

source "qemu" "kutti-base" {
  # Before using this script, you need to obtain a debian
  # netinst ISO, and put it in a folder called "iso".
  # The iso path and its checksum should be passed in via
  # the variables iso-url and iso-checksum.
  # E.g.:
  #   iso-url: ./iso/debian-12.10.0-amd64-netinst.iso
  #   iso-checksum: sha256:ee8d8579128977d7dc39d48f43aec5ab06b7f09e1f40a9d98f2a9d149221704a
  iso_url      = "${var.iso-url}"
  iso_checksum = "${var.iso-checksum}"

  # Create a VM with 
  #  - 2 cpu cores
  #  - 2 GiB RAM
  #  - 100 GiB hard disk
  cpus      = "2"
  memory    = "2048"
  disk_size = "102400"

  # Optimize for 64-bit Debian Linux
  # Option unavailable on qemu

  # HTTP serve the preseed file
  http_directory = "buildhttp"

  # Performance and Driver Optimizations
  disk_interface = "virtio"
  net_device     = "virtio-net"
  # Set accelerator depending on build host (kvm = Linux, hvf = macOS, hyperv = Windows)
  accelerator    = "kvm"

  format = "qcow2"

  boot_command = [
    "<esc><wait>",
    "install <wait>",
    "fb=false <wait>",
    "auto=true <wait>",
    "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed_bookworm_cloudkernel.cfg <wait>",
    "domain=kuttiproject.org <wait>",
    "hostname=kutti <wait>",
    "<enter><wait>"
  ]


  # Although this step needs no ssh, these settings must be
  # specified.
  ssh_username = "kuttiadmin"
  ssh_password = "Pass@word1"
  ssh_timeout  = "20m"

  shutdown_command = "sudo poweroff"

  # The output file should be called kutti-base.qcow2
  vm_name = "kutti-base.qcow2"
  output_directory = "out/kutti-base"
}

build {
  sources = [
    "sources.qemu.kutti-base"
  ]
}
