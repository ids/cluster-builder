## VMware Fusion Deployment Guide

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

### Ansible Fusion Configuration

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


**cluster_type**: one of _photon-swarm_, _centos-dcos_, _centos-swarm_, _centos-ucp_, _atomic-swarm_, _rhel-swarm_, or _rhel-ucp_.

**vmware_target**: _fusion_ 

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