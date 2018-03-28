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