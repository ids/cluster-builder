# VMware Cluster Node Packer
Packer builds VMware cluster nodes in **CentOS 7** & **Photon OS 2.0** for use in DC/OS & Swarm Clusters.

## Requirements
  - Packer 1.0.4+ (brew install/upgrade packer)
  - VMware (Fusion Pro 8+/ Workstation Pro 12+)
  - VMware's [ovftool](https://my.vmware.com/web/vmware/details?downloadGroup=OVFTOOL420-OSS&productId=614)  in $PATH
  - Ansible 2.3+ (brew install/upgrade ansible)

> Note: To save time you may want to seed the __iso__ folder with the respective iso files used in the creation of CentOS, Photon or RHEL based VMs.  Simply download them and place them in the __iso__ folder. Packer will download them on demand if they don't exist already in the folder.

[PhotonOS ISO Download](http://dl.bintray.com/vmware/photon/2.0/GA/iso/photon-2.0-304b817.iso)

[CentOS7 ISO Download](http://mirrors.sonic.net/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1804.iso)

## Usage
> Make sure to create **keys/authorized_keys** before you run build.  This is installed in the **root** account of the vm.  Provisioning scripts that use this image are based on passwordless ssh.

Run the `set-key` script in the **keys** folder to set authorized_keys to the rsa key found in **~/.ssh/id_rsa.pub**.

To build the vmx and ova node image use the wrapper script and specify the type:

    bash build [centos7]

or

    bash build photon


## Output
The builder creates a VMX in the respective **output_**<centos7|photon>**_vmx** folder.

This is post-processed using **ovftool** into a single file OVA template located in the **output_ova** folder.

## Provisioning Summary
### CentOS 7
The CentOS 7 VM is provisioned to be used as a DC/OS node but is also suitable for Docker Swarm.

- Open VM Tools
- Ansible (used for provisioning)
  - Python 2.7+
  - Pip 8.1+
  - Ansible 2.3+
- CentOS
  - Latest CentOS 7+ kernel & packages
  - Enable Overlay file system
  - Disable kdump
- DC/OS / Swarm Node Dependencies
  - Docker 17.05 w/ OverlayFS
  - curl, bash, ping, tar, xz, unzip, ipset
  - Disable firewalld
  - Disable IPv6
  - Cache docker images: nginx, zookeeper, registry
- Debug
  - jq
  - probe
  - net-utils
- Zero out free space to improve image compression

### Photon OS 2.0
The Photon VM is not suitable for DC/OS, but may be used for Docker Swarm.  It has a minimal footprint.

- open-vm-tools
- nfs-utils
- Docker 17.09.0-ce (manually upgraded on Photon OS minimal from 1.12)

## Networking
Default approach is to use DHCP to reserve addresses by MAC, and then statically assign IPs as needed. The OVA template has the primary NIC set for DHCP on boot.

When the OVA is imported and booted for the first time it will be assigned a mac address by VMware for the life of the VM instance - DHCP will assign a temporary address when the machine is first launched.  After the first phase of cluster-builder provisioning, the server is assigned its **static (DHCP) address** and **hostname**, and the temporary DHCP address is put back into the pool (only to be used during deployment activity).

For VMware Fusion, DHCP is the way to go and is how static IPs are assigned on local workstations. For ESXi, we use ansible to configure a static IP as part of the deployment process.

## Workflow
These OVA images are the first stage of a deployment workflow:

1] Generate OVA cluster templates with Packer (this stage)
2] Use **Ansible** to deploy your VM instances and configure your cluster

> See https://github.com/ids/cluster-builder.

3] Continue to use **Ansible** to manage and maintain your cluster.

> The combination of Git + Packer + Ansible should ensure that all configuration is documented and repeatable, with no manual or ad-hoc configuration.
