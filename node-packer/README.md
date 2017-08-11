# VMware Cluster Node Builder
Packer builds VMware cluster nodes in **CentOS 7** & **Photon OS 1.0 R2** for use in DC/OS & Swarm Clusters.

## Requirements
  - Packer 1.0.3+ (brew install/upgrade packer)
  - VMware (Fusion / Workstation)
  - VMware's [ovftool](https://my.vmware.com/web/vmware/details?downloadGroup=OVFTOOL420-OSS&productId=614)  in $PATH
  - Ansible 2.3+ (brew install/upgrade ansible)

## Usage
> Make sure to create **keys/authorized_keys** before you run build.  This is installed in the **root** account of the vm.  Provisioning scripts that use this image are based on passwordless ssh.

Run the `set-key` script in the **keys** folder to set authorized_keys to the rsa key found in **~/.ssh/id_rsa.pub**.

To build the vmx and ova node image use the wrapper script and specify the type:

    bash build [centos7]

or

    bash build photon1


## Output
The builder creates a VMX in the respective **output_**<centos7|photon1>**_vmx** folder.

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

### Photon OS 1.0 R2
The Photon VM is not suitable for DC/OS, but may be used for Docker Swarm.  It has a minimal footprint.

- open-vm-tools
- nfs-utils
- Docker 17.06.0-ce (manually upgraded on Photon OS minimal from 1.12)

## Networking
Default approach is to use DHCP to reserve addresses by MAC, and then statically assign IPs as needed. The OVA template has the primary NIC set for DHCP on boot.

When the OVA is imported and booted for the first time it will be assigned a mac address by VMware for the life of the VM instance - this is then manually registered in the DHCP server as a static assignment.  When rebooted, the server is assigned its **static (DHCP) address** and **hostname**.

For VMware Fusion, DHCP is the way to go. For ESXi, we use ansible to configure a static IP as part of the deployment process in **photon-swarm** and **centos-dcos**.

### Deployment Steps
These steps describe the manual workflow.  This is automated in the **photon-swarm** and **centos-dcos** deployment projects.

#### Using DHCP Static Reservations:
1. Register the OVA with VMware (import/deploy it as a new VM instance)
2. Capture the MAC Address generated and register with DHCP Server as static assignment
3. Reboot the VM
4. Configure VM with Ansible (setup the Docker swarm)

#### Using Manual Static IP Assignment:
For Step 2. Use ansible, or log into the VM and configure the static IP Address.

## Workflow
These OVA images are the first stage of a deployment workflow:

1] Generate OVA cluster templates with Packer (this stage)
2] Use **Ansible** to deploy your VM instances and configure your cluster

> See https://github.com/ids/photon-swarm.

3] Continue to use **Ansible** to manage and maintain your cluster.

> The combination of Git + Packer + Ansible should ensure that all configuration is documented and repeatable, with no manual or ad-hoc configuration.

#### With a VM template created you can move on to deploying a container orchestration cluster with [cluster-builder](https://github.com/ids/cluster-builder)
---
