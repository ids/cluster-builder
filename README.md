# Cluster Builder
Ansible scripts to configure a [DC/OS](https://dcos.io/), [Docker Swarm]() and [Kubernetes]() clusters.

## Cluster Types
The **cluster-builder** can currently deploy two types of clusters:

* PhotonOS Swarm
* CentOS 7 DC/OS Cluster

> **PhotonOS Kubernetes** is coming soon.

## Deployment Options
There are currently two types of deployment:

* VMware Fusion
* VMware ESXi (vSphere)

The VMware Fusion deployment is intended for local development.

VMware ESXi is for staging and production deployments.

## Requirements
	- Packer 1.03+
  - VMware Fusion 8+
  - VMware ESXi 6.5+ (optional)
  - VMware's [ovftool](https://my.vmware.com/web/vmware/details?downloadGroup=OVFTOOL420-OSS&productId=614) in $PATH
  - Ansible 2.3+ (brew install/upgrade ansible)

> Ensure that the host names specified in the inventory file also resolve (exist in /etc/hosts or DNS)

#### Pre-Requesites:
It is necessary that the **id_rsa.pub** value of the **cluster-builder** operator account be set in the **packer/cluster-node/keys/authorized_keys**. This is required as the scripts use passwordless SSH to access the 
VMs for provisioning.

The cluster provisioning scripts rely on a template ova that corresponds to the cluster type.  These are built by packer and located in **packer/cluster-node/output_ovas**.  See [packer/cluster-node/Readme.md].  The **cluster-deploy** script will attempt to build the ova if it is not found.

## Inventory File
Everything is based on the **Ansible inventory file**, which defines the cluster specifications.

> Sample inventory files are located in the **cluster** folder.

#### Fusion Sample: demo-swarm

		[all:vars]
		cluster_type=photon-swarm
		cluster_name=demo-swarm

		vmware_target=fusion
		fusion_net="vmnet2"
		fusion_net_type="custom"
		fusion_vm_folder="../virtuals"

		network_mask=255.255.255.0
		network_gateway=192.168.100.1
		network_dns=192.168.100.1
		network_dns2=8.8.8.8
		network_dns3=8.8.4.4
		network_dn=idstudios.vmware

		[docker_swarm_manager]
		demo-swarm-m1 ansible_host=192.168.100.90 

		[docker_swarm_worker]
		demo-swarm-w1 ansible_host=192.168.100.91 swarm_labels='["db-node-1"]'
		demo-swarm-w2 ansible_host=192.168.100.92 swarm_labels='["db-node-2"]'
		demo-swarm-w3 ansible_host=192.168.100.93 swarm_labels='["db-node-3"]'

		[vmware_vms]
		demo-swarm-m1 numvcpus=2 memsize=2048 
		demo-swarm-w1 numvcpus=2 memsize=3072 
		demo-swarm-w2 numvcpus=2 memsize=3072 
		demo-swarm-w3 numvcpus=2 memsize=3072 


**cluster_type**
Either **photon_-swarm** or **centos-dcos**.

**vmware_target**
Either **fusion** or **esxi**.

**fusion_net**
The name of the VMware network, vmnet[1-n], default is **vmnet2** with a network of 192.168.100.0.

**fusion_net_type**
One of **nat**, **bridged** or **custom**.


#### ESXi Sample: esxi-dcos

		[all:vars]
		cluster_type=centos-dcos
		cluster_name=dcos-c2

		dcos_boot_server=192.168.1.160
		dcos_boot_server_port=9580

		vmware_target=esxi
		esxi_net="VM Network" 
		esxi_net_prefix=192.168.1

		network_mask=255.255.255.0
		network_gateway=192.168.1.1
		network_dns=192.168.1.10
		network_dns2=192.168.1.1
		network_dns3=8.8.8.8
		network_dn=idstudios.local

		[dcos_boot]
		dcos-c2-boot ansible_host=192.168.1.160 

		[dcos_masters]
		dcos-c2-m1 ansible_host=192.168.1.171 
		dcos-c2-m2 ansible_host=192.168.1.172 
		dcos-c2-m3 ansible_host=192.168.1.173 

		[dcos_agents_private]
		dcos-c2-a1 ansible_host=192.168.1.181 
		dcos-c2-a2 ansible_host=192.168.1.182 
		dcos-c2-a3 ansible_host=192.168.1.183 

		[dcos_agents_public]
		dcos-c2-p1 ansible_host=192.168.1.191 

		[vmware_vms]
		dcos-c2-boot numvcpus=2 memsize=1024 esxi_host=esxi-3 esxi_user=root esxi_ds=datastore3 
		dcos-c2-m1 numvcpus=2 memsize=2048 esxi_host=esxi-2 esxi_user=root esxi_ds=datastore2
		dcos-c2-m2 numvcpus=2 memsize=1584 esxi_host=esxi-3 esxi_user=root esxi_ds=datastore3
		dcos-c2-m3 numvcpus=2 memsize=1584 esxi_host=esxi-4 esxi_user=root esxi_ds=datastore4
		dcos-c2-a1 numvcpus=2 memsize=4048 esxi_host=esxi-3 esxi_user=root esxi_ds=datastore3
		dcos-c2-a2 numvcpus=2 memsize=4048 esxi_host=esxi-4 esxi_user=root esxi_ds=datastore4
		dcos-c2-a3 numvcpus=2 memsize=4048 esxi_host=esxi-3 esxi_user=root esxi_ds=datastore3
		dcos-c2-p1 numvcpus=2 memsize=2048 esxi_host=esxi-4 esxi_user=root esxi_ds=datastore4


VMs are provisioned based on the **[vmware_vms]** group attributes.


### VMware Fusion Deployment
VMware Fusion deployment is geared toward building small clusters on a laptop for demo purposes.  

Example inventory file:

* demo-swarm
* demo-dcos

> **Note:** This requires at least 16GB of ram on the target machine.

---
**Fusion Pre-requisites:**
- The examples use a custom VMware Fusion host-only network that maps to **vmnet2** with the network **192.168.100.0**.  This should be created before attempting to deploy the fusion demos.
- The VMware Fusion application should be running.
---

> The script requires an active local sudo session as the VMware network controls require sudo, but this is difficult to prompt for with ansible.  If you don't have one, the script will prompt you for your local SUDO machine password.

The ansible scripts will adjust your local VMware network dhcpd.conf file based on the MAC addresses assigned during creation of the VMs, and the static IPs will be assigned by VMware via MAC address.

Once the VMs have been created, assigned their correct addresses, and are running, cluster provisioning process will begin.

### VMware ESXi Deployment
ESXi deployment assumes that you have SSH enabled, and that your operator **id_rsa.pub** has been registered in the ESXi server's authorized_keys.

> **Note**: ESXi deployment uses static IP addresses auto-assigned during the deployment process.

Once deployed to ESXI, the VMs are started to generate their MAC addresses and fetch temporary DHCP IP addresses.  These are then used to create some BASH scripts that will configure the CentOS VMs with static IPs, as per the inventory file.

At this stage all of the VMs have been deployed and **should be running**.  They should also have their correct static IPs.

---
**ESXi Pre-requisites:**
* All of the ESXi hosts must be setup for root access with passwordless SSH.  The **authorized_keys** for the root account on each ESXi host must contain the public key for the account executing the script.  This should be the same public key used in the creation of the ova template images.
* The example esxi cluster inventory files are based on a bridged network of 192.168.1.0.  If this doesn't match your ESXi environment, you will need to create your own inventory file based on the example.
---

> You will be prompted for the ESXi root password as it is required as the ovftool - which does not appear to work with passwordless SSH.

> TODO: Future enhancements would switch to using PowerCLI or the vSphere API for remote control.

## Deploying a Cluster
To deploy a cluster:

    $ bash cluster-deploy <inventory-file>

Eg.

    $ bash cluster-deploy cluster/demo-swarm

#### Controlling the VM Nodes
There are ansible tasks that use the inventory files to execute VM control commands.

Use the respective wrapper scripts:

    bash cluster-control <inventory-file> <action: one of stop|suspend|start|destroy>

Eg.

    $ bash cluster-control cluster/demo-swarm suspend

