Cluster Builder
===============

Ansible and Packer Iac() scripts to configure [DC/OS](https://dcos.io/) and [Docker Swarm](https://www.docker.com/) container orchestration clusters and deploy them into VMware environments:

1. [Supported Clusters](#supported-clusters)
2. [Deployment Options](#deployment-options)
3. [Required Software](#required-software)
4. [Preparation](#preparation)
5. [Cluster Definition Packages](#cluster-definition-packages)
6. [Deploying a Cluster](#deploying-a-cluster)
7. [Controlling Cluster VM Nodes](#controlling-cluster-vm-nodes)
8. [VMware ESX Volume Driver Plugin](#vmware-esx-volume-driver-plugin)
9. [Production Readiness](#production-readiness)
10. [Prometheus Monitoring](#prometheus-monitoring)
11. [Host Mounted NFS Storage](#host-mounted-nfs-storage)


## Supported Clusters
The **cluster-builder** currently supports building __Swarm__ and __DC/OS__ clusters for several platforms:

* PhotonOS Docker CE
* CentOS 7 Atomic Docker CE
* CentOS 7 Docker CE
* CentOS 7 Docker EE 
* CentOS 7 DC/OS 

> [PhotonOS](https://vmware.github.io/photon/) is VMware's take on a minimal linux container OS, apparently tuned to the VMware hypervisor.  Initially I was skeptical, but after working with it in comparison to [CoreOS](https://coreos.com/) and [Project Atomic](https://www.projectatomic.io/), I have really grown to like it.  Very clean and well thought - what you need, no clutter.  Polished like CoreOS. Atomic seems more focused on their specific approach to Kubernetes then on being a general purpose container OS. 

## Deployment Options
There are currently two types of deployment:

* VMware Fusion 
* VMware ESXi (vSphere)

The VMware Fusion deployment is intended for local development.

VMware ESXi is for staging and production deployments.

There are at present 5 supported cluster types, or variants:

- photon-swarm
- centos-swarm
- atomic-swarm
- centos-ucp
- centos-dcos

> Each variant starts in the **node-packer** and uses _packer_ to build a base VMX/OVA template image from distribution iso.

## Required Software

### macOS / Linux

- VMware Fusion Pro 8+ / Workstation Pro 12+
- VMware ESXi 6.5+ (optional)
- VMware's [ovftool](https://my.vmware.com/web/vmware/details?downloadGroup=OVFTOOL420-OSS&productId=614) in $PATH
- Ansible 2.3+ `brew install/upgrade ansible`
- Hashicorp [Packer 1.04+](https://www.packer.io/downloads.html)

> Note: For Docker EE edition you will need to provide a valid Docker EE download URL and license file.

### Windows

There is now experimental Windows support for ESXi deployments. See the [Windows Readme](README_Windows.md).

The [Cluster Builder Control](https://github.com/ids/cluster-builder-control) is also an alternative.  It is a CentOS7 desktop with all the tools required for running **cluster-builder**.

It can be used:

* Running locally on a Windows or Linux VMware Workstation, or VMware Fusion for macOS
* Running remotely on an ESXi server

It can even be built remotely directly on an ESXi server, which is the intended purpose.  For production deployments it can form the foundation for a control station that operates within the ESX environment and is used to centralize management of the clusters.

For instructions see the [Cluster Builder Control](https://github.com/ids/cluster-builder-control) README.

## Preparation

* Ensure that the host names specified in the inventory file also resolve (exist in /etc/hosts or DNS)

* It is necessary that the **id_rsa.pub** value of the **cluster-builder** operator account be set in the **node-packer/keys/authorized_keys**. This is required as the scripts use passwordless SSH to access the 
VMs for provisioning.

* The cluster provisioning scripts rely on a **VM template OVA** that corresponds to the cluster type.  These are built by packer and located in **node-packer/output_ovas**.  See the cluster node packer [readme](https://github.com/ids/cluster-builder/blob/master/node-packer/README.md).  The **cluster-deploy** script will attempt to build the ova if it isn't found where expected.

__Note for Docker EE__
The cluster definition package (folder) you create in the __clusters__ folder will need to contain a valid __docker_subscription.lic__ file.

## Cluster Definition Packages

Everything is based on the **Ansible inventory file**, which defines the cluster specifications. These are defined in **hosts** files located in a folder given the cluster name:

Eg. In the **examples** folder there is:

		demo-atomic-swarm
			|_ hosts

Sample cluster packages are located in the **examples** folder and can be copied into the **clusters** folder.

### Fusion Sample: demo-photon-swarm hosts file

	[all:vars]
	cluster_type=photon-swarm
	cluster_name=demo-photon-swarm

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
	demo-swarm-w1 ansible_host=192.168.100.91 swarm_labels='["front-end", "db-galera-node-1"]'
	demo-swarm-w2 ansible_host=192.168.100.92 swarm_labels='["front-end", "db-galera-node-2"]'
	demo-swarm-w3 ansible_host=192.168.100.93 swarm_labels='["front-end", "db-galera-node-3"]'

	[docker_prometheus_server]
	demo-swarm-m1

	[docker_elk_server]
	demo-swarm-m1

	[vmware_vms]
	demo-swarm-m1 numvcpus=2 memsize=2048 
	demo-swarm-w1 numvcpus=2 memsize=3072 
	demo-swarm-w2 numvcpus=2 memsize=3072 
	demo-swarm-w3 numvcpus=2 memsize=3072 


**cluster_type**: _photon-swarm_, _centos-dcos_, _centos-swarm_ or _atomic-swarm_.

**vmware_target**: _fusion_ or _esxi_.

**fusion_net**: The name of the VMware network, vmnet[1-n], default is **vmnet2** with a network of 192.168.100.0.

**fusion_net_type**: One of _nat_, _bridged_ or _custom_.

__[docker_prometheus_server]__: When a server is placed in this group it will have **prometheus** and **grafana** instances installed.

__docker_enable_metrics=true__: When this is set global instances of **cAdvisor** and **node-exporter** on all nodes in the cluster.

__[docker_elk_server]__: When a server is placed in this group it will have **elasticsearch** and **kibana** instances installed. 

__docker_elk_target=<elk-server:port>__: Will configure global instances of **logstash**  on all nodes in the cluster, with the docker engine configured to use the **gelf** log driver for sending logs to logstash, which will be configured to ship the logs to the specified elk server.

For deploying Docker EE UCP, there are also additional fields required:

__ucp_download_url__: The Docker EE Engine Download Url

__ucp_admin_user__: The admin user for the UCP

__ucp_admin_password__: The admin password for the UCP


### ESXi Sample: esxi-centos-dcos hosts file

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

### VMware Fusion Deployment
VMware Fusion deployment is geared toward building small clusters on a laptop for demo purposes.

> **Note:** DC/OS requires at least 16GB of ram on the target machine.

---
### Fusion Preparation

* The examples use a custom VMware Fusion host-only network that maps to **vmnet2** with the network **192.168.100.0**.  This should be created before attempting to deploy the fusion demos.

* The VMware Fusion application should be running.
---

> The script requires an active local sudo session as the VMware network controls require sudo, but this is difficult to prompt for with ansible.  If you don't have one, the script will prompt you for your local SUDO machine password.

The ansible scripts will adjust your local VMware network dhcpd.conf file based on the MAC addresses assigned during creation of the VMs, and the static IPs will be assigned by VMware via MAC address.

Once the VMs have been created, assigned their correct addresses, and are running, cluster provisioning process will begin.

## VMware ESXi Deployment
ESXi deployment assumes that you have SSH enabled, and that your operator **id_rsa.pub** has been registered in the ESXi server's authorized_keys.

> **Note**: ESXi deployment uses static IP addresses auto-assigned during the deployment process.

Once deployed to ESXI, the VMs are started to generate their MAC addresses and fetch temporary DHCP IP addresses.  These are then used to create some BASH scripts that will configure the VMs with static IPs, as per the inventory file.

At this stage all of the VMs have been deployed and **should be running**.  They should also have their correct static IPs.

---
### ESXi Preparation

* All of the ESXi hosts must be setup for root access with passwordless SSH.  The **authorized_keys** for the root account on each ESXi host must contain the public key for the account executing the script.  This should be the same public key used in the creation of the ova template images.

* The example esxi cluster inventory files are based on a bridged network of 192.168.1.0.  If this doesn't match your ESXi environment, you will need to create your own inventory file based on the example.
---

> You will be prompted for the ESXi root password as it is required for the ovftool - which does not appear to work with passwordless SSH.

> TODO: Future enhancements would switch to using PowerCLI or the vSphere API for remote control.

## Deploying a Cluster
To deploy a cluster use **cluster-deploy**:

    $ bash cluster-deploy <inventory-package | cluster-name>

Eg.

    $ bash cluster-deploy demo-centos-swarm

## Controlling Cluster VM Nodes
There are ansible tasks that use the inventory files to execute VM control commands.

Use **cluster-control**:

    bash cluster-control <inventory-package | cluster-name> <action: one of stop|suspend|start|destroy>

Eg.

    $ bash cluster-control demo-atomic-swarm suspend


## VMware ESX Volume Driver Plugin

In order to make use of the VMware Volume Driver Plugin (vDVS) for persistent data volume management the VIB must be installed on all of the ESX servers used for the cluster.

Download the [VIB](https://bintray.com/vmware/vDVS/download_file?file_path=VMWare_bootbank_esx-vmdkops-service_0.17.c2aef31-0.0.1.vib) for the vDVS.

It is easiest to download the VIB to a shared datastore accessible to all of the ESX servers, and then copy it locally to the /tmp folder during each install.

> Make sure to put the VIB in tmp on the ESX server and reference it absolutely:

Eg.

	esxcli software vib install --no-sig-check -v /tmp/VMWare_bootbank_esx-vmdkops-service_0.17.c2aef31-0.0.1.vib

The plugin is automatically installed as part of the cluster-builder swarm provisioning process. However, this can also be manually done on cluster nodes with the following command:

	docker plugin install --grant-all-permissions --alias vsphere store/vmware/docker-volume-vsphere:latest


## Production Readiness

Currently in a pre-production state, but rapidly approaching production readiness with the CentOS variant of Docker CE and EE.

### Security

Currently two automated security audits of the  __cluster-builder CentOS Docker EE/CE__ clusters have been conducted:

> November 1st, 2017

#### Lynis

[Lynis](https://cisofy.com/lynis/) security scanning has been conducted on the current CentOS node.  Relevant suggestions were implemented as part of an [ansible hardening script](ansible/roles/centos-hardening/tasks/hardening.yml).

The report output is available [here](https://raw.githubusercontent.com/ids/cluster-builder/master/xtras/security-reports/centos-lynis.md).

#### CIS Docker Benchmark

The [CIS Docker Benchmark](https://docs.docker.com/compliance/cis/) has been applied to the curent CentOS node.  Warnings and subsequent mitigations were applied and/or documented at the top of the report, which is available [here](https://raw.githubusercontent.com/ids/cluster-builder/master/xtras/security-reports/centos-docker-cis.md).


### System Profile

A general overview of the highlights:

* Docker versions: __Docker CE:__ 17.0.9-ce (or later), __Docker EE:__ 2.2.3 (ucp)
* CentOS base VM image OVA template is based on the CentOS 7 Minimal 1708 iso and is  __894MB__, and contains two thinly provisioned SCSI based VMDK disks: 1) 250GB dynamically sizing system block device, and 2) 250GB dynamically sizing docker __device mapper direct-lvm__ dedicated block device.
* CentOS VMs have been configured with a production recommended __device mapper direct-lvm__ mode docker dedicated block device.
* The __VMware Docker Volume Service__ Docker Volume Plugin has been pre-installed on all cluster-builder VMs.
* Time synchronization of all the cluster nodes is done as part of the deployment process, and __chronyd__ services are configured and verified.
* Deployments can include configurable options for log shipping to ELK, using logstash.  Docker EE/UCP can also be configured to ship to __syslogd__ server post-deployment.
* Metrics are enabled (a configurable option), and cAdvisor/node-exporter options are available for deployment in support of Prometheus/Grafana monitoring, although Docker EE comes with some built in visualizations for CPU and memory reducing the urgency of more advanced metrics analysis.
* Remote API and TLS certificates are installed and configured on Docker CE deployments, enabling a unified application stack deployment model for both Docker EE and CE clusters.

> Note that all details pertaining to the above exist within this codebase. The cluster-builder starts with the distribution iso file in the initial [node-packer](node-packer) phase, and everything from the initial __kickstart__ install through to the final __ansible playbook__ are documented here and available for review.

## Prometheus Monitoring

Currently, __cAdvisor__ and __node-exporter__ are installed on CentOS and PhotonOS Swarms, with metrics enabled by default.

When the following is added to a cluster package hosts file:

	[docker_prometheus_server]
	<ansible inventory hostname>

Eg.

	[docker_prometheus_server]
	swarm-m1


Prometheus and Grafana containers will be installed on the specified node.

Promethus can then be reached at: http://<cluster node>:9090

Grafana at: http://<cluster node>:3000

> TODO: These need to be TLS secured and made production ready

## Host Mounted NFS Storage

Place the following file in the cluster definition package folder:

	nfs_shares.yml

In the format:

	nfs_shares:
		- folder: the name of the local mount folder
			fstab: the fstab entry
			group: an inventory group of hosts on which to setup this mount

Eg.

	nfs_shares:
		- folder: /mnt/nfs/shared
			fstab: "192.168.1.10:/Users/seanhig/NFS_SharedStorage  /mnt/nfs/shared   nfs      rw,sync,hard,intr  0     0"
			group: "docker_swarm_worker"
		- folder: /mnt/nfs/shared
			fstab: "192.168.1.10:/Users/seanhig/Google\\040Drive/Backups/NFS_Backups  /mnt/nfs/backups   nfs      rw,sync,hard,intr  0     0"   
			group: "docker_swarm_worker"
    
And then run the ansible playbook for the platform:

Eg.

	ansible-playbook -i clusters/esxi-photon-swarm/hosts ansible/photon-nfs-shares.yml

or

	ansible-playbook -i clusters/esxi-centos-swarm/hosts ansible/centos-nfs-shares.yml

And it will setup the mounts according to host group membership specified in the nfs_shares.yml configuration.