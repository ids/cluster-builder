Cluster Builder
===============

[Ansible](https://www.ansible.com/) and [Packer](https://www.packer.io) IaC() scripts to configure [DC/OS](https://dcos.io/) and [Docker Swarm](https://www.docker.com/) container orchestration clusters and deploy them into VMware environments using simple Ansible inventory host file declarations and a minimal toolset.

> Deploy a production ready container orchestration cluster to VMware in minutes while you read [hacker news](https://news.ycombinator.com/)... the IaC way.

![Cluster Builder Overview](docs/images/cluster-builder-overview.png)

1. [Supported Clusters](#supported-clusters)
2. [Deployment Options](#deployment-options)
3. [Required Software](#required-software)
4. [Preparation](#preparation)
5. [Cluster Definition Packages](#cluster-definition-packages)
6. [Cluster Builder Usage](#cluster-builder-usage)
7. [Deploying a Cluster](#deploying-a-cluster)
8. [Controlling Cluster VM Nodes](#controlling-cluster-vm-nodes)
9. [VMware ESX Volume Driver Plugin](#vmware-esx-volume-driver-plugin)
10. [Prometheus Monitoring](#prometheus-monitoring)
11. [Host Mounted NFS Storage](#host-mounted-nfs-storage)
12. [Change Cluster Password](#change-cluster-password)
13. [Separate Management and Data Interfaces](#separate-management-and-data-interfaces)
14. [Advanced Swarm Deployment](#advanced-swarm-deployment)
15. [Production Readiness](#production-readiness)

## Supported Clusters
The **cluster-builder** currently supports building __Swarm__ and __DC/OS__ clusters for several platforms:

* PhotonOS Docker CE
* CentOS 7 Atomic Docker CE (deprecated)
* CentOS 7 Docker CE
* CentOS 7 Docker EE 
* CentOS 7 DC/OS 
* RedHat Enterprise 7 Docker CE
* RedHat Enterprise 7 Docker EE

> [PhotonOS](https://vmware.github.io/photon/) is VMware's take on a minimal linux container OS.

> [Project Atomic](https://www.projectatomic.io/) variant is now deprecated.  The __rpm-ostree__ model is too restrictive.

## Deployment Options
There are currently two types of deployment:

* VMware Fusion 
* VMware ESXi (vSphere)

The VMware Fusion deployment is intended for local development.

VMware ESXi is for staging and production deployments.

There are at present 6 supported cluster types, or variants:

- photon-swarm
- centos-swarm
- rhel-swarm
- centos-ucp
- rhel-ucp
- centos-dcos

and 

- atomic-swarm (deprecated)

> Each variant starts in the **node-packer** and uses _packer_ to build a base VMX/OVA template image from distribution iso.

## Required Software

### macOS / Linux

- VMware Fusion Pro 8+ / Workstation Pro 12+
- VMware ESXi 6.5+ (optional)
- VMware's [ovftool](https://my.vmware.com/web/vmware/details?productId=614&downloadGroup=OVFTOOL420) in $PATH
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

__Note for Red Hat Deployments__
The cluster definition package (folder) you create in the __clusters__ folder will need to contain a valid __rhel7-setup.sh__ file and __rhel.lic__ file. Additionally, the ISO needs to be manually downloaded and place in **node-packer/iso**.

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

	docker_prometheus_server=demo-swarm-m1

	[docker_swarm_manager]
	demo-swarm-m1 ansible_host=192.168.100.90 

	[docker_swarm_worker]
	demo-swarm-w1 ansible_host=192.168.100.91 swarm_labels='["front-end", "db-galera-node-1"]'
	demo-swarm-w2 ansible_host=192.168.100.92 swarm_labels='["front-end", "db-galera-node-2"]'
	demo-swarm-w3 ansible_host=192.168.100.93 swarm_labels='["front-end", "db-galera-node-3"]'

	[vmware_vms]
	demo-swarm-m1 numvcpus=2 memsize=2048 
	demo-swarm-w1 numvcpus=2 memsize=3072 
	demo-swarm-w2 numvcpus=2 memsize=3072 
	demo-swarm-w3 numvcpus=2 memsize=3072 


**cluster_type**: _photon-swarm_, _centos-dcos_, _centos-swarm_, _centos-ucp_, _atomic-swarm_, _rhel-swarm_, or _rhel-ucp_.

**vmware_target**: _fusion_ or _esxi_.

**fusion_net**: The name of the VMware network, vmnet[1-n], default is **vmnet2** with a network of 192.168.100.0.

**fusion_net_type**: One of _nat_, _bridged_ or _custom_.

__network_dns__: DNS entry for the primary interface

__network_dns2__: 2nd DNS entry for the primary interface

__network_dns3__: 3rd DNS entry for the primary interface

__network_dn__: Domain name for the primary interface subnet

__docker_prometheus_server=<host>__: The specified server will have **prometheus** and **grafana** instances installed.

__docker_elk_target=<elk-server:port>__: Will configure global instances of **logstash**  on all nodes in the cluster, with the docker engine configured to use the **gelf** log driver for sending logs to logstash, which will be configured to ship the logs to the specified elk server.

For deploying Docker EE UCP, there are also additional fields required:

__ucp_download_url__: The Docker EE Engine Download Url

__ucp_admin_user__: The admin user for the UCP

__ucp_admin_password__: The admin password for the UCP

#### ESXI options:

__esxi_data_net__: The name of the dedicated VMware network for the Data plane (VLAN)

__esxi_data_net_prefix__: The network prefix of the dedicated VMware network for the Data plane (eg. 192.168.2)

__ovftool_parallel=true__: This setting will execute __ovftool__ deployments in parallel rather then one at a time.  This can increase ovftool deployment performance by as much as 150%.

#### Advanced options:

__ovftool_parallel=true__: When set on ESXI deployments it will cause the ovftool processes to run in parallel in the background, resulting in as much as 20% performance increase in some environments. 

> Note that at the present time running ovftool in parallel will scramble the output to the console - but this won't affect the outcome.

__docker_swarm_mgmt_cn__: The fully qualified server name to use for the remote api manager certificates.  This is the address used for the load balancer that balances the remote api requests over the manager nodes.

__docker_swarm_mgmt_gw__: The fully qualified gateway name to use for all external cluster access.

__data_network_mask__: The network mask for the data network

__data_network_gateway__: The gateway address for the data network

__docker_daemon_dns_override__: (optional)  By default, cluster-builder will use the dns entries defined for the host interfaces (network_dns, network_dns2, etc).  If a different DNS configuration is desired for Docker, this value can be used to override the default behavior.  It must be supplied in the JSON string array form:

		docker_daemon_dns_override='"192.168.1.1", "8.8.8.8"'

> Note the single quotes wrapping the double quotes.

> When deploying two interface nodes, the Data plane interface should be assigned the default gateway, and the Control/Mgmt plane interface should NOT be assigned a default gateway.

__data_network_dns__: DNS entry for the data plane interface

__data_network_dns2__: 2nd DNS entry for the data plane interface

__data_network_dns3__: 3rd DNS entry for the data plane interface

__data_network_dn__: Domain name for the data interface subnet


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

* The VMware tools need to be in the PATH

* The Swarm Node hostnames must be specified in the host machine /etc/hosts

#### VMware Tools Path

Ensure the VMware CLI tools are setup in the BASH PATH:

Eg.

		export VM_TOOLS="/Library/Application Support/VMware Fusion"
		export PATH=$PATH:/usr/local/bin:/usr/bin:~/bin:$VM_TOOLS

		if [ -d "/Applications/VMware Fusion.app/Contents/Library" ]; then
		export PATH=$PATH:"/Applications/VMware Fusion.app/Contents/Library"
		fi

		if [ -d "/Applications/VMware OVF Tool/" ]; then
		export PATH=$PATH:"/Applications/VMware OVF Tool/"
		fi

#### Host /etc/hosts

The hostnames of the target VM nodes used in the cluster definition package:

		192.168.100.90  demo-swarm-m1 atomic-swarm-m1 drupal.idstudios.vmware
		192.168.100.91	demo-swarm-w1 atomic-swarm-w1
		192.168.100.92	demo-swarm-w2 atomic-swarm-w2
		192.168.100.93	demo-swarm-w3 atomic-swarm-w3

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

## Cluster Builder Usage

The __cluster-builder__ project is designed as a generic toolset for deployment.  All user specific configuration information is stored in the cluster definition packages which are kept in the __clusters__ folder.

It is recommended that an organization establish a base folder git repository within the __clusters__ folder to store their cluster definition packages.  Anything kept in __clusters__ will be ignored by the parent cluster-builder git repository.

Eg.

	cluster-builder
		|_ clusters
			|_ ids (my organization - git repo - named anything - shorter is better)
				|_ swarm-dev (my cluster definition package)
					|_ hosts (the cluster inventory hosts file)

All resulting artifacts from __cluster-builder__ are then stored within the cluster definition package.

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

Download the [VIB](https://bintray.com/vmware/vDVS/download_file?file_path=VMWare_bootbank_esx-vmdkops-service_0.19.641f741-0.0.1.vib) for the vDVS.


It is easiest to download the VIB to a shared datastore accessible to all of the ESX servers, and then copy it locally to the /tmp folder during each install.

> Make sure to put the VIB in tmp on the ESX server and reference it absolutely:

Eg.

	esxcli software vib install --no-sig-check -v /tmp/VMWare_bootbank_esx-vmdkops-service_0.20.15f5e1d-0.0.1.vib

The plugin is automatically installed as part of the cluster-builder swarm provisioning process. However, this can also be manually done on cluster nodes with the following command:

	docker plugin install --grant-all-permissions --alias vsphere vmware/docker-volume-vsphere:latest

## Prometheus Monitoring

Currently, __cAdvisor__ and __node-exporter__ are installed on CentOS and PhotonOS Swarms, with metrics enabled by default.

When the following is added to a cluster package hosts file:

docker_prometheus_server=<ansible inventory hostname>

Eg.

	docker_prometheus_server=swarm-m1

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

## Change Cluster Password
Change password is now integrated into the cluster deployment process.

For __CentOS__ deployments, both the __root__ and __admin__ passwords are prompted for change at the end of the cluster deployment.

For __PhotonOS__ deployments, only the __root__ will prompt.

> A bit of an annoyance, but it is integrated to ensure that clusters are never deployed into production with default root passwords.  TODO: Enhance to support headless deployments.

This functionality is also available as as top level script:

	bash cluster-passwd <cluster package> [user to change]

Eg.

	bash cluster-passwd esxi-centos-swarm admin

It is intended to be run on a regular basis as per the standard operating procedures for password change management.

## Separate Management and Data Interfaces

As of Docker Engine 17.06 is now possible to specify separate interfaces for the Management and Control traffic and the Swarm/Container Data traffic.

> See https://docs.docker.com/engine/swarm/networking

__cluster-builder__ now supports this via some additional directives in the cluster package inventory hosts file.

> __Note__: Currently only supported on CentOS variants.

### Separate Interface Preparation

If you haven't already done so, you will need to rebuild the __CentOS OVA__ so it contains the required two interfaces.

> This has been recently added to the centos7 packer build and only needs to be done once.

__Note__ that this separation does require additional network configuration external to the clusters.  The data plane will need access to a default gateway within the designated data plane subnet.

#### ESXI

Ensure there are two networks on the ESX hosts that all hosts can access.  This will likely mean the creation of two dedicated VLANs (or port groups).

The inventory hosts file __esxi_data_net__ should match the name of the ESX VLAN port group.

Inventory hosts file additions:

Eg.

	esxi_data_net="Data Network" 
	esxi_data_net_prefix=192.168.2

#### Fusion

Ensure a __vmnet3__ private custom network has been created.

Eg.

Inventory hosts file additions:

	fusion_data_net="vmnet3"
	fusion_data_net_type="custom"

#### Both ESXI/Fusion

Specify the settings for the 2nd dedicated data network inferface, also in the hosts file:

	data_network_mask=255.255.255.0
	data_network_gateway=192.168.2.1
	data_network_dns=8.8.8.8
	data_network_dns2=8.4.4.4
	data_network_dn=idstudios.data.local

> Make sure the settings match your target network

__Note__ the prefix "data_" in front of the settings.  The original settings that do not contain the "data_" prefix are used as the __Control and Management Plane Interface__.

Also make sure to assign the data plane interface IP address as **data_ip** for each VM node in the swarm:

	[docker_swarm_manager]
	swarm-m1 ansible_host=192.168.1.221 data_ip=192.168.2.221 

	[docker_swarm_worker]
	swarm-w1 ansible_host=192.168.1.231 data_ip=192.168.2.231 swarm_labels='["front-end"]'
	swarm-w2 ansible_host=192.168.1.232 data_ip=192.168.2.232 swarm_labels='["front-end"]'
	swarm-w3 ansible_host=192.168.1.233 data_ip=192.168.2.233 swarm_labels='["front-end"]'
	swarm-w4 ansible_host=192.168.1.234 data_ip=192.168.2.234 swarm_labels='["db-galera-node-1"]'
	swarm-w5 ansible_host=192.168.1.235 data_ip=192.168.2.235 swarm_labels='["db-galera-node-2"]'
	swarm-w6 ansible_host=192.168.1.236 data_ip=192.168.2.236 swarm_labels='["db-galera-node-3"]'

__Note__ the **data_ip** variable containing the ip address assignment for the data plane network.

## Advanced Swarm Deployment

The advanced swarm deployment configuration represents the current candidate production deployment model.  It involves the following key aspects:

* Separate interfaces for Control and Data plane underlay networks (each VM node in the swarm has two nics on two different subnets)
* Cluster VM nodes are fully contained within a private VLAN
* All cluster access is controlled via a Firewall/gateway
* All management services are load balanced over 3 or more manager nodes
* All management services are secured by HTTPS

For detailed step-by-step configuration instructions see the [Advanced Swarm Deployment Guide](docs/advanced_swarm.md)

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

#### Docker Versions

__Docker CE:__ 17.09.1-ce (or later)
centos-swarm
photon-swarm
atomic-swarm
rhel-swarm

__Docker EE:__ 2.2.3 (ucp)
centos-ucp
rhel-ucp

#### CentOS Based Clusters

* CentOS base VM image OVA template is based on the CentOS 7 Minimal 1708 iso and is  __1.1GB__, and contains one thinly provisioned SCSI based VMDK disk using __overlay2__, which is now supported on 1708 (CentOS/RHEL 7.4+).
* CentOS base VM image is a fully functioning and ready worker node.
* Default linux kernel is 3.10.x

#### PhotonOS Based Clusters

* PhotonOS base VM image OVA template is based on the PhotonOS 2 Minimal iso and is  __862.4MB__, and contains one thinly provisioned SCSI based VMDK disk: 250GB dynamically sizing system block device.
* PhotonOS VMs are based on Photon OS 2.0 (current), and have a 4.9 (or better) linux kernel
* PhotonOS VMs are automatically configured with __overlay2__ driver as they have a 4.x kernel

#### All Clusters

* Use __packer centric__ approach for provisioning, VM OVA based nodes are ready to be added to swarms
* The __VMware Docker Volume Service__ Docker Volume Plugin has been pre-installed on all cluster-builder VMs.
* Time synchronization of all the cluster nodes is done as part of the deployment process, and __chronyd__ or __ntpd__ services are configured and verified.
* Deployments can include configurable options for log shipping to ELK, using logstash.  Docker EE/UCP can also be configured to ship to __syslogd__ server post-deployment.
* Metrics are enabled (a configurable option), and cAdvisor/node-exporter options are available for deployment in support of Prometheus/Grafana monitoring, although Docker EE comes with some built in visualizations for CPU and memory reducing the urgency of more advanced metrics analysis.
* Remote API and TLS certificates are installed and configured on Docker CE deployments, enabling a unified application stack deployment model for both Docker EE and CE clusters.

> Note that all details pertaining to the above exist within this codebase. The cluster-builder starts with the distribution iso file in the initial [node-packer](node-packer) phase, and everything from the initial __kickstart__ install through to the final __ansible playbook__ are documented here and available for review.
