# Kutti VirtualBox Driver Interface

The kutti QEMU driver interacts with QEMU VMs created by this image via the following interface:

## SSH

The driver uses SSH to communicate with the VM and run the scripts defined below.

## User

Kutti uses a user called `kuttiadmin` with a hardcoded password to run commands inside VMs. This user has sudo privileges without the need of a password.

## Scripts

Kutti uses a number of scripts to perform common operations inside VMs. These are all installed in a directory called `/opt/kutti/scripts`. Symbolic links to these are added in the `/usr/local/bin` directory.

The scripts are listed below:

## set-hostname.sh

This changes the hostname of a VM, and also changes its unique machine id and SSH fingerprint. It is invoked when a new node is added to a kutti cluster.

## capture-ca-certificates.sh

This captures or removes CA certificates. To capture, it uses openssl to make a call to a known HTTPS server, and saves the certificates it receives in a file called `/etc/ssl/certs/captured-ca.crt`. To remove, it deletes that file.

## set-proxy.sh

This sets or removes node-wide proxy settings. To set, it adds two files containing proxy settings: `/etc/profile.d/kutti-proxy.sh` for interactive programs, and `/etc/systemd/system.conf.d/kutti-proxy.conf` for daemons. To remove, it deletes these files.

## add-ca-certificate.sh

This adds a certificate to the operating system's trusted store. The certificate file must be in PEM format, with the filename ending in .crt.
