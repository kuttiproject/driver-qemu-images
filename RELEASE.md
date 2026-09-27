# Releases

Each release from this repository contains .qcow2 files for supported versions of Kubernetes, and a file called **driver-qemu-images.json** which describes these releases. The location on these files in the GitHub release is burned into the corresponding version of the QEMU driver.

## .qcow2 files

These files can be built by running the included HashiCorp Packer scripts as detailed in [PACKER.md](PACKER.md).

## driver-qemu-images.json

The schema for this file is as follows:

```json
{
    "KUBERNETES VERSION": {
        "ImageK8sVersion": "KUBERNETES VERSION (must match key above)",
        "ImageChecksum": "SHA256 CHECKSUM OF QCOW2 FILE",
        "ImageStatus": "NotDownloaded",
        "ImageSourceURL": "PATH TO QCOW2 FILE IN RELEASE",
        "ImageDeprecated": false
    },...
}
```

A sample is provided below:

```json
{
    "1.35": {
        "ImageK8sVersion": "1.35",
        "ImageChecksum": "1630fbfef783c490b83d17dd21f2e8243ea7120fa2917455b8d1c1294a565362",
        "ImageSourceURL": "https://github.com/kuttiproject/driver-qemu-images/releases/download/v0.1/kutti-1.35.qcow2",
        "ImageStatus": "Downloaded",
        "ImageDeprecated": false
    },
    "1.36": {
        "ImageK8sVersion": "1.36",
        "ImageChecksum": "3889fa564078c7fd5297535fbb1cf80856a5c630b73ddc0fc6132cae2e0a9ad8",
        "ImageSourceURL": "https://github.com/kuttiproject/driver-qemu-images/releases/download/v0.1/kutti-1.36.qcow2",
        "ImageStatus": "Downloaded",
        "ImageDeprecated": false
    },
    "1.37": {
        "ImageK8sVersion": "1.37",
        "ImageChecksum": "177f4fba665c19086437fde195cf67f0381a9fda616c5dc81e6ff6b0cffe2628",
        "ImageSourceURL": "https://github.com/kuttiproject/driver-qemu-images/releases/download/v0.1/kutti-1.37.qcow2",
        "ImageStatus": "Downloaded",
        "ImageDeprecated": false
    }
}
```
