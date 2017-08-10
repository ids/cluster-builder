# VMware CentOS7 DC/OS Cluster
Ansible scripts to configure a [DC/OS](https://dcos.io/) cluster.

## Requirements
  - VMware Fusion 8+
  - VMware ESXi 6.5+ (optional)
  - VMware's [ovftool](https://my.vmware.com/web/vmware/details?downloadGroup=OVFTOOL420-OSS&productId=614)  in $PATH
  - **cluster-node-packer** CentOS7 VM template
  - Ansible 2.3+ (brew install/upgrade ansible)

> Ensure that the host names specified in the inventory file also resolve (exist in /etc/hosts or DNS)

## Inventory File
Everything is based on the **Ansible inventory file**, which defines the cluster specifications.

> Sample inventory files are located in the inventory folder.

	[all:vars]
	dcos_cluster_name=dcos-fusion
	dcos_boot_server=192.168.100.99
	dcos_boot_server_port=9580

	fusion_net="vmnet2"
	fusion_net_type="custom"

	network_mask=255.255.255.0
	network_gateway=192.168.100.1
	network_dns=192.168.100.1
	network_dns2=8.8.8.8
	network_dns3=8.8.4.4
	network_dn=idstudios.vmware

	[dcos_boot]
	demo-dcos-boot ansible_host=192.168.100.99

	[dcos_masters]
	demo-dcos-m1 ansible_host=192.168.100.100 

	[dcos_agents_private]
	demo-dcos-a1 ansible_host=192.168.100.101 
	demo-dcos-a2 ansible_host=192.168.100.102 
	demo-dcos-a3 ansible_host=192.168.100.103 

	[dcos_agents_public]
	demo-dcos-p1 ansible_host=192.168.100.106 

	[vmware_vms]
	demo-dcos-boot numvcpus=2 memsize=1024 
	demo-dcos-m1 numvcpus=2 memsize=1584
	demo-dcos-a1 numvcpus=2 memsize=2048
	demo-dcos-a2 numvcpus=2 memsize=2048
	demo-dcos-a3 numvcpus=2 memsize=2048
	demo-dcos-p1 numvcpus=2 memsize=1048


## Deployment
There are currently two types of deployment:

* VMware Fusion
* VMware ESXi (vSphere)

The VMware Fusion deployment is intended for local development.

VMware ESXi is for staging and production deployments.

#### Pre-Requesites: 
Run the cluster-node-packer to produce a **cluster-node-centos7-x86_64.ova** VM template.  This produces a minimal **CentOS .ova template VM** pre-configured with authorized_keys and an up-to-date docker engine.

> The scripts currently assume that the repo for cluster-node-packer is peer to this one and that the centos7 ova has been configured and built. See https://github.com/ids/cluster-node-packer.

### VMware Fusion Deployment
VMware Fusion deployment is geared toward building small clusters on a laptop for demo purposes.  The example inventory file is **demo-cluster**:

> **Note:** This requires at least 16GB of ram on the target machine.

---
**Fusion Pre-requisites:**
- The **demo-cluster** example uses a custom VMware Fusion host-only network that maps to **vmnet2** with the network **192.168.100.0**.  This should be in place before attempting to deploy _demo-cluster_.
- The VMware Fusion application should be running.
---

To deploy a Fusion DC/OS cluster run the bash wrapper script:

    $ bash fusion-deploy <inventory-file>

Eg.
    
	$ bash fusion-deploy inventory/demo-cluster

> Ensure you have an active local sudo session before running the script as the VMware network controls require sudo, but this is difficult to prompt for with ansible.  If you don't the script will prompt you for your local SUDO machine password.

The ansible scripts will adjust your local VMware network dhcpd.conf file based on the MAC addresses assigned during creation of the VMs, and the static IPs will be assigned by VMware via MAC address.

Once the VMs have been created, assigned their correct addresses, and are running, the DC/OS provisioning process will be executed.

> See the fusion-deploy script for the ansible playbooks involved in the stages of deployment.

When the script successfully completes you should be able to login to DC/OS at:

    http://<dcos master ip>


### VMware ESXi Deployment
The ESXi deployment is still very rough cut.  It assumes that you have SSH enabled, and that your current public key has been registered in the ESXi server's authorized_keys.

---
This builds a completely configured **DC/OS Cluster** with one command using the **Ansible inventory file** with some custom annotations.  The entire deployment process only takes about 40 minutes (depending on CPU and network speed):

1. Packer builds the DC/OS Cluster VM ova template configured with authorized_keys for passwordless access
2. Ansible then deploys the VMs to ESXi servers using ovftool and vim-cmd
3. Ansible configures them with static IP addresses once they are running
4. Ansible configures the DC/OS cluster as per the inventory file specifications
---

> **Note**: ESXi deployment uses static IP addresses auto-assigned during the deployment process.

---
**ESXi Pre-requisites:**
* All of the ESXi hosts must be setup for root access with passwordless SSH.  The **authorized_keys** for the root account on each ESXi host must contain the public key for the account executing the script.  This should be the same public key used in the creation of the ova template images.
* The example inventory file **esxi-cluster** is based on a bridged network of 192.168.1.0.  If this doesn't match your ESXi environment, you will need to create your own inventory file based on the example.
---

To deploy a DC/OS Cluster to your ESXi environment:

    $ bash esxi-deploy <inventory-file>

Eg.

    $ bash esxi-deploy inventory/esxi-cluster

> You will be prompted for the ESXi root password as it is required as the ovftool - which does not appear to work with passwordless SSH.

> TODO: Future enhancements would switch to using PowerCLI or the vSphere API for remote control.

Once deployed to ESXI, the VMs are started to generate their MAC addresses and fetch temporary DHCP IP addresses.  These are then used to create some BASH scripts that will configure the CentOS VMs with static IPs, as per the inventory file.

At this stage all of the VMs have been deployed and **should be running**.  They should also have their correct static IPs.

Now DC/OS provisioning begins.

> **Note:** that there are some lengthy pauses to allow the service to start up in the correct order.

> See the esxi-deploy script for the ansible playbooks involved in the stages of deployment.

When the script successfully completes you should be able to login to DC/OS at:

    http://<dcos master ip>

#### Controlling the VM Nodes
There are ansible tasks that use the inventory files to execute VM control commands.

Use the respective wrapper scripts:

    bash fusion-control <inventory-file> <action: one of stop|suspend|start|destroy>

or

    bash esxi-control <inventory-file> <action: one of stop|suspend|start>

#### TODOs:
- support multiple vnics and networks provisioned dynamically on the ESXi hosts