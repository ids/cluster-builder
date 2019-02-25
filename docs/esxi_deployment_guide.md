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

**cluster_type**: one of _centos-dcos_, _centos-swarm_, _rhel-swarm_.

**vmware_target**: _esxi_

#### Networking Options

__network_dns__: DNS entry for the primary interface

__network_dns2__: 2nd DNS entry for the primary interface

__network_dns3__: 3rd DNS entry for the primary interface

__network_dn__: Domain name for the primary interface subnet

__docker_swarm_mgmt_cn__: The fully qualified server name to use for the remote api manager certificates.  This is the address used for the load balancer that balances the remote api requests over the manager nodes.

__docker_swarm_mgmt_gw__: The fully qualified gateway name to use for all external cluster access.

__data_network_mask__: The network mask for the data network

__data_network_gateway__: The gateway address for the data network

> When deploying two interface nodes, the Data plane interface should be assigned the default gateway, and the Control/Mgmt plane interface should NOT be assigned a default gateway.

__data_network_dns__: DNS entry for the data plane interface

__data_network_dns2__: 2nd DNS entry for the data plane interface

__data_network_dns3__: 3rd DNS entry for the data plane interface

__data_network_dn__: Domain name for the data interface subnet

#### Docker Specific Options

__docker_prometheus_server=<host>__: The specified server will have **prometheus** and **grafana** instances installed.

__docker_elk_target=<elk-server:port>__: Will configure global instances of **logstash**  on all nodes in the cluster, with the docker engine configured to use the **gelf** log driver for sending logs to logstash, which will be configured to ship the logs to the specified elk server.

#### Advanced options:

__docker_daemon_dns_override__: (optional)  By default, cluster-builder will use the dns entries defined for the host interfaces (network_dns, network_dns2, etc).  If a different DNS configuration is desired for Docker, this value can be used to override the default behavior.  It must be supplied in the JSON string array form:

		docker_daemon_dns_override='"192.168.1.1", "8.8.8.8"'

> Note the single quotes wrapping the double quotes.

__ovftool_parallel=true__: When set on ESXI deployments it will cause the ovftool processes to run in parallel in the background, resulting in as much as 20% performance increase in some environments. 

> Note that at the present time running ovftool in parallel will scramble the output to the console - but this won't affect the outcome.
