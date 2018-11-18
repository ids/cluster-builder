## Cluster Builder - VMware Local Deployment Guide

VMware local deployment is geared toward building small clusters on a laptop for demo purposes.  Deployments are made to local machines running:

* VMware Fusion Pro 10+ on macOS
* VMware Workstation Pro 12+ on Windows
* VMware Workstation Pro 12+ on Linux

> **Note:** DC/OS requires at least 16GB of ram on the target machine.

---
### Notes

* The VMware Fusion application should be running on macOS.

* The VMware tools need to be in the PATH

* The hostnames used in the cluster definition packages must resolve via DNS or be statically set in `/etc/hosts`

#### VMware Tools Path

Ensure the VMware CLI tools are setup in the BASH PATH:

Eg for macOS.

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

		192.168.100.90  demo-swarm-m1  drupal.idstudios.vmware
		192.168.100.91	demo-swarm-w1
		192.168.100.92	demo-swarm-w2
		192.168.100.93	demo-swarm-w3

> The preferred approach is to use a DNS server.

---

> The script requires an active local sudo session as the VMware network controls require sudo, but this is difficult to prompt for with ansible.  If you don't have one, the script will prompt you for your local SUDO machine password.

The ansible scripts will adjust your local VMware network dhcpd.conf file based on the MAC addresses assigned during creation of the VMs, and the static IPs will be assigned by VMware via MAC address.

Once the VMs have been created, assigned their correct addresses, and are running, cluster provisioning process will begin.

> __Note__ that all settings marked as __fusion__ apply to all of the VMware desktop platforms.

### Ansible Fusion Configuration

### Fusion Sample: demo-centos-swarm hosts file

    [all:vars]
    cluster_type=centos-swarm
    cluster_name=demo-centos-swarm

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


**cluster_type**: one of _centos-dcos_, _centos-swarm_, _rhel-swarm_.

**vmware_target**: _fusion_ (also applies for workstation)

**fusion_net**: The name of the VMware network, vmnet[1-n], default is **vmnet2** with a network of 192.168.100.0.

**fusion_net_type**: One of _nat_, _bridged_ or _custom_.

__network_dns__: DNS entry for the primary interface

__network_dns2__: 2nd DNS entry for the primary interface

__network_dns3__: 3rd DNS entry for the primary interface

__network_dn__: Domain name for the primary interface subnet

__docker_prometheus_server=<host>__: The specified server will have **prometheus** and **grafana** instances installed.

__docker_elk_target=<elk-server:port>__: Will configure global instances of **logstash**  on all nodes in the cluster, with the docker engine configured to use the **gelf** log driver for sending logs to logstash, which will be configured to ship the logs to the specified elk server.


__docker_swarm_mgmt_cn__: The fully qualified server name to use for the remote api manager certificates.  This is the address used for the load balancer that balances the remote api requests over the manager nodes.

__docker_swarm_mgmt_gw__: The fully qualified gateway name to use for all external cluster access.

__docker_daemon_dns_override__: (optional)  By default, cluster-builder will use the dns entries defined for the host interfaces (network_dns, network_dns2, etc).  If a different DNS configuration is desired for Docker, this value can be used to override the default behavior.  It must be supplied in the JSON string array form:

		docker_daemon_dns_override='"192.168.1.1", "8.8.8.8"'

> Note the single quotes wrapping the double quotes.