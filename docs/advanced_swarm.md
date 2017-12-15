Cluster Builder - Advanced Swarm Deployment
===========================================

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

## Configure DNS

## Install pfSense Swarm Gateway VM

## Deploy Cluster Builder Control Station

## Setup Cluster Package Definition Repository

## Advanced Cluster Configuration Package

## Setup Remote API Load Balancer

## Setup HAProxy SSL Offloaded Services

## Setup Passthrough Traefik Load Balancer

## Setup NFS Server

## Deploy Cluster

## Troubleshooting