# Packer Build Instructions

The images for this repository can be built using HashiCorp [Packer](https://www.packer.io/).

The build is done in two steps. The first step builds a base operating system image. The
second step can be run multiple times to generate images for different versions of Kubernetes.

Preferably, use the Makefile or the Invoke-Build script (described below).

## Build Prerequisites

1. Qemu version 8.2 or above, with qemu-utils.
2. HashiCorp Packer, version 1.16.0 or above.
3. A Debian netinst ISO image. This has to be downloaded into a folder called ISO in this directory, and its name and checksum passed to the `kutti.step1.pkr.hcl` file.

## Build Instructions

1. Create a folder called "iso" in the current directory.
2. Download a Debian netinst ISO file into this directory.
3. Obtain the path and SHA256 checksum of this file.
4. Run `packer build -var iso-url=PATH -var iso-checksum=CHECKSUM kutti.step1.pkr.hcl` to generate a .qcow2 file of a bare OS image.
5. Run `packer build -var "kube-version=DESIREDVERSION" kutti.step2.pkr.hcl`. Here, DESIREDVERSION is the kubernetes version, as it is published in the google apt repository for Kubernetes.

## Details

### Step 1

The first step is the script `kutti.step1.pkr.hcl`, which builds a .qcow2 file from a Debian netinst CD ISO image. It uses a preseed file to configure the installation. Some important settings are as follows:

* US keyboard layout and language is US
* Locale and timezone are India
* The root password is "Pass@word1"
* A user called "kuttiadmin" is created with the password "Pass@word1"
* The entire hard disk is made into a single data partition, _no swap_.
* Only `sudo`, `openssh` and `dbus` are installed.
* The kuttiadmin user is given sudo rights without a password.
* The linux "cloud-amd64" kernel is installed.

### Step 2

The second step is the script `kutti.step2.pkr.hcl`. This starts from a VM created from the output of the previous step, and does the following:

* Removes the regular kernel, keeping the "cloud-amd64" kernel.
* Configures GRUB for:
  * zero wait at boot
  * use of fixed network interface names like eth0
* Adds a user called `user1` with sudo access.
* Adds driver interface scripts to the image
* Installs and configures `containerd` from the Docker debian repositories
* Installs kubernetes. The version is controlled by a variable called KUBE_VERSION
* Uninstalls unneeded software installed during the build process
* Writes a huge file filled with zeroes to fill the virtual HDD, and deletes it
* Compacts the virtual hard disk
* Exports to the final .qcow2.

## Makefile and Invoke-Build script

The steps described above can also be performed via a supplied makefile and GNU make.
`make step1` and `make step2` can be used.

If on PowerShell, the steps can be performed using the [Invoke-Build](https://github.com/nightroman/Invoke-Build) module and the supplied script.
`Invoke-Build step1` and `Invoke-Build step2` can be used.

## Publishing a release

Collect the .qcow2 files for the supported versions, and create a `driver-qemu-images.json` file describing them. Then publish a GitHub release, and upload the `driver-qemu-images.json` file and the .qcow2 files to it. Details can be found in [RELEASE.md](RELEASE.md).
