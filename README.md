# driver-qemu-images

amd64 VM images for the kutti QEMU driver

![GitHub release (latest by date)](https://img.shields.io/github/v/release/kuttiproject/driver-qemu-images?include_prereleases)

This repository contains scripts for building images for the kutti QEMU driver running on amd64 Linux. Its releases are the download source of these images for the kutti system.

## Building Images

Images can be built by running the included HashiCorp Packer scripts as detailed in [PACKER.md](PACKER.md).

## Releases

Details of creating releases can be found in [RELEASE.md](RELEASE.md).

## Release Versioning

Releases will usually follow the major and minor version number of the [driver-qemu](https://github.com/kuttiproject/driver-qemu) project. Sometimes, this repository's releases may lag by a version.

### Image Kubernetes Versions and deprecation policy

The latest release in this repository contains images for the current version of Kubernetes, and up to five versions before that. The current version and two versions before that are supported, the three before that are deprecated (you can run existing clusters created using them, but not create new clusters). Images of versions before that are deleted.

Images in releases earlier than the latest are also deleted.

## Components

The images in this repository are built from open source components. Details can be found in [COMPONENTS.md](COMPONENTS.md).
