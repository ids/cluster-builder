# Cluster Builder - Advanced Swarm Deployment

This a step-by-step guide to configuring a VMware ESX based Docker CE/EE Swarm infrastructure in support of the cluster-builder advanced deployment model.

1. [Overview](#overview)
2. [Configure VMware VLANs](#configure-vmware-vlans)
3. [Configure DNS](#configure-dns)
4. [Install pfSense Swarm Gateway VM](#install-pfsense-gateway-vm)
5. [Deploy Cluster Builder Control Station](#deploy-cluster-builder-control-station)
6. [Setup Cluster Package Definition Repository](#setup-cluster-package-definition-repository)
7. [Advanced Cluster Configuration Package](#advanced-cluster-configuration-package)
8. [Setup Remote API Load Balancer](#setup-remote-api-load-balancer)
9. [Setup HAProxy SSL Offloaded Services](#setup-haproxy-ssl-offloaded-services)
10. [Setup Passthrough Traefik Load Balancer](#setup-passthrough-traefik-load-balancer)
11. [Setup NFS Server](#setup-nfs-server)
12. [Deploy Cluster](#deploy-cluster)
13. [Troubleshooting](#troubleshooting)

## Overview

The following diagram illustrates the advanced swarm deployment configuration:

![Advanced Swarm Overview](images/advanced-overview.png)

With this configuration, the __cluster-control__ vm is connected to the private VLANs used by the swarm vm nodes.  Direct access to the underlying swarm virtual machine nodes is not permitted from the external physical network.  All management of the swarm nodes is done through the __cluster-control__ station.

The private VLANs are implemented in the VMware ESX environment.

Access to the management services is secured and load balanced by the dedciated __cluster-gateway__, which provides firewall and load balancing services.  In this example __pfSense CE__ is used as the __cluster-gateway__, and it is installed as a virtual machine.

Control and Data plane traffic in the Docker Swarm has been separated each assigned a dedicated interface (subnet), with all inbound traffic directed to the data plane interfaces.

## Configure VMware VLANs

The creation of the dedicated private VLANs for the Control and Data interfaces of the swarm is relatively straightforward on VMware ESX.  

> __Note__ that for VLANs to span multiple ESX hosts requires they be connected via a __managed switch__.  Standard unmanaged switches will not work.

For each ESX host, in __Networking > Port Groups__:

![VMware Port Groups](images/vmware-vlan-list.png)

Create two new port groups (VLANs) for the Control and Data plane interfaces of the swarm:

![VMware Add Port Group](images/vmware-vlan-add-portgroup.png)

If there are multiple ESX hosts, the __managed switch__ needs to be configured to tag the outgoing packets with the designated VLAN ID.  This passes encapsulated VLAN packets between the switch ports.

The following screenshot shows the VLAN port assignment (taken from a Netgear GS108T 8-port managed switch):

![Switch Port Tagging](images/vmware-vlan-switch-port-tagging.png)

> __Note__ that each port shows "T", indicating the VLAN traffic is passed between ports.

## Configure DNS

It is necessary that all of the required DNS entries be setup and configured before deployment.  This includes:

* All Swarm VM node hostnames
* External DNS names for management services
* External DNS names for deployed services

It is useful to configure your cluster __hosts__ file to establish the various DNS entries required.

Examples, based on the internal example domain of __idstudios.local__:

    cluster-gateway.idstudios.local -> physical gateway address
    remote-api.idstudios.local -> physical gateway address
    swarm-m[1-3] -> private VLAN data plane addresses
    swarm-w[1-6] -> private VLAN data plan addresses

## Install pfSense Swarm Gateway VM

__pfSense Community Edition__ is a free to use firewall appliance with numerous advanced capabilities, such as:

* Professional Grade Firewall
* Integrated General Purpose Load Balancer
* Integrated HAProxy
* Inegrated BIND

We use __pfSense__ as the __cluster-gateway__ which controls and manages access to the swarm residing in the private VLAN.

Download the __pfSense__ ISO, and upload it to a shared datastore available to the ESX servers.

Create a new VM with this ISO, and make sure of the following:

* VM has at least 2GB of RAM
* VM has two or three nics:
  * Nic on the physical bridged VM Network (accessible by the physical network) - this is for the WAN side of the firewall
  * Nic on the Data plane VLAN - this is for the LAN_DATA side
  * (optional) Nic on the Mgmt/Control plan VLAN - this is for the LAN_MGMT side

We will configure pfSense based on the network configuration of our deployed swarm.

## Deploy Cluster Builder Control Station

Follow the deployment guidelines for the __cluster-builder-control__ workstation VM (as per the project readmes).

It is important that the __cluster-builder-control__ vm have at least 3 nics (additional virtual nics can be added and configured post deployment).

As shown in the overview diagram, the __cluster-builder-control__ station must reside on all three subnets.

> It may only need to reside on the data plane network - this needs to be confirmed.

## Setup Cluster Package Definition Repository

Create the user/organization specific top level cluster repo folder under __clusters__.  This should be as short as possible as it will be referenced often as a CLI parameter.

Eg.

For my company __Intelligent Design Studios__ I created the __ids__ folder for all of our cluster deployment packages:

    clusters
      |_ids

This is initialized as a private git repository, which is stored in a secure on-prem gitlab instance.  Within the __ids__ folder, the cluster packages are kept (as per those in examples).

    clusters
      |_ids
        |_swarm-dev

After a deployment the resulting certificates for secured TLS remote api access are then stored within this managed, versioned private git repo.

After successful deployment:

    cd clusters/ids
    git push origin master

Which keeps the cluster definition packages and resulting certificates safe and secure.

At any point the entire structure of the toolset can be restored with two simple git clone commands:

    git clone git@github.com:ids/cluster-builder.git
    cd cluster-builder/clusters
    git clone git@myprivategitlab.com:ids/ops/ids-clusters.git ids

Updates and enhancements made to the __cluster-builder__ toolkit are abstracted from the user specific cluster package definition packages.

## Advanced Cluster Configuration Package

See the example package [esxi-centos-swarm-advanced](../examples/esxi-centos-swarm-advanced/hosts) __hosts__ file for the example configuration for the layout illustrated in the overview.

## Setup Remote API Load Balancer

With the __Advanced Swarm Deployment__ access to the Remote API is load balanced over the 3-manager-node HA configuration.

This requires __docker_swarm_mgmt_sn__ to be set in the __hosts__file.

Eg.

    docker_swarm_mgmt_sn=remote-api.idstudios.local

The server name specified should be the DNS entry that maps to the __cluster-gateway__ WAN interface address.

This value is then used when creating the self signed TLS certificates shared by all of the manager nodes.  It is used for the CN value, and must match the address used for client access.

### Docker CE
__pfSense__ is configured to allow traffic for __port 2376__ and load balance it over the manager nodes on the data plane

### Docker EE
__pfSense__ is configured to allow traffic for __port 443__ and load balance it over the manager nodes on the data plane

## Setup HAProxy SSL Offloaded Services

__pfSense__ can run __HAProxy__ as an integrated package.  

Install __HAProxy__ on your __cluster-gateway__ through __System > Package Manager__, and search for __haproxy__.

Once installed, it can be accessed through __Services > HAProxy__.

Prometheus, Grafana and Portainer are all secured and accessed through HAProxy.

> TODO: walkthrough of the setup of HAProxy front end, back end and use of the pfSense Certificate Manager for SSL offloading.

## Setup Passthrough Traefik Load Balancer

Production traffic is proxied by the swarm integrated Traefik proxy.  Traefik will also manage SSL termination for the various services, and will route traffic based on host-header, using only a single IP/port for ingress.

__pfSense__ is configured to allow traffic from port 80 and load balance it over the worker nodes, using SSL passthrough, letting Traefik handle the end service routing.

## Setup NFS Server

> TODO: basic NFS setup in support of shared volume usage (i.e. drupal) within the advanced configuration.

## Deploy Cluster

> TODO: deployment considerations from within the private VLAN control station.

## Troubleshooting

> TODO: common issues