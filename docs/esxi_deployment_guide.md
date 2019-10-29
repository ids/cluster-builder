## Cluster Builder - ESXi Deployment Guide

ESXi deployment assumes that you have SSH enabled, and that your operator **id_rsa.pub** has been registered in the ESXi server's authorized_keys.

> **NOTE**: ESXi deployment uses static IP addresses auto-assigned during the deployment process.

Once deployed to ESXI, the VMs are started to generate their MAC addresses and fetch temporary DHCP IP addresses.  These are then used to create some BASH scripts that will configure the VMs with static IPs, as per the inventory file.

At this stage all of the VMs have been deployed and **should be running**.  They should also have their correct static IPs.

#### Using a .passwords File

For ESXi deployment you can place a `.passwords` file in the cluster definition package folder to save having to type in the ESXi user (usually root) password for `ovftool` deployment, or the node passwords, during each run of the deployment script.

The `.passwords` file should can contain the following:

```
export CB_ESXI_USER_PASSWORD=<password for ovftool deployment to ESXi hypervisors or vSphere>
export CB_NODE_ROOT_PASSWORD=<strong plain text password>
export CB_NODE_ADMIN_PASSWORD=<strong plain text password>
```

If a `.passwords` file is not used the script will prompt for the values.

---
### ESXi Preparation

* All of the ESXi hosts must be setup for root access with passwordless SSH.  The **authorized_keys** for the root account on each ESXi host must contain the public key for the account executing the script.  This should be the same public key used in the creation of the ova template images.

* The example esxi cluster inventory files are based on a bridged network of 192.168.1.0.  If this doesn't match your ESXi environment, you will need to create your own inventory file based on the example.

---

> You will be prompted for the ESXi root password as it is required for the ovftool - which does not appear to work with passwordless SSH.

> TODO: Future enhancements would switch to using PowerCLI or the vSphere API for remote control.

### ESXi DC/OS Sample: esxi-centos-dcos hosts file

		[all:vars]
		cluster_type=centos-dcos
		cluster_name=esxi-centos-dcos

		dcos_boot_server=192.168.1.160
		dcos_boot_server_port=9580

		vmware_target=esxi
		esxi_net="VM Network" 
		esxi_net_prefix=192.168.1

		network_mask=255.255.255.0
		network_gateway=192.168.1.1
		network_dns=8.8.8.8
		network_dns2=8.8.4.4
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
		dcos-c2-boot  numvcpus=2 memsize=1024 esxi_host=esxi-1 esxi_user=root esxi_ds=datastore1 
		dcos-c2-m1    numvcpus=2 memsize=3072 esxi_host=esxi-5 esxi_user=root esxi_ds=datastore5
		dcos-c2-m2    numvcpus=2 memsize=3072 esxi_host=esxi-4 esxi_user=root esxi_ds=datastore4
		dcos-c2-m3    numvcpus=2 memsize=3072 esxi_host=esxi-3 esxi_user=root esxi_ds=datastore3
		dcos-c2-a1    numvcpus=2 memsize=4096 esxi_host=esxi-1 esxi_user=root esxi_ds=datastore1
		dcos-c2-a2    numvcpus=2 memsize=4096 esxi_host=esxi-3 esxi_user=root esxi_ds=datastore3
		dcos-c2-p1    numvcpus=2 memsize=2048 esxi_host=esxi-3 esxi_user=root esxi_ds=datastore3

		[vmware_db_vms]
		dcos-c2-a3    numvcpus=2 memsize=5120 esxi_host=esxi-5 esxi_user=root esxi_ds=datastore5

		[vmware_vms:children]
		vmware_db_vms

VMs are provisioned based on the **[vmware_vms]** group attributes.

**exsi_host** is the target host where the VM will be deployed. **esxi-user** and **esxi-ds** are fairly straightforward.

**cluster_type**: one of _centos-dcos_, _centos-k8s_ or _fedora-k8s_.

**vmware_target**: _esxi_

__ovftool_parallel=true__: When set on ESXI deployments it will cause the ovftool processes to run in parallel in the background, resulting in as much as 20% performance increase in some environments. 

> Note that at the present time running ovftool in parallel will scramble the output to the console - but this won't affect the outcome.

__overwrite_existing_vms=true__: When set to `true` the __ovftool__ will delete any existing VMs as part of the deployment.

__protected=true__: When set to `true` __cluster-builder__ will not allow destruction or re-deployment of the cluster.  This should be set for all deployed clusters where destruction would be disruptive, especially __production__ environments.

#### Networking Options

__network_dns__: DNS entry for the primary interface

__network_dns2__: 2nd DNS entry for the primary interface

__network_dns3__: 3rd DNS entry for the primary interface

__network_dn__: Domain name for the primary interface subnet

__network_mask__: The primary interface subnet network mask

__network_cidr__: The primary interface network mask in CIDR form for (required for Ubuntu nodes)
