Tectonic CoreOS on VMware ESXi/vSphere via PXE/iPXE - Alpha
===========================================================

There are two core aspects to deploying CoreOS:

* __The CoreOS Provisioner__, deployed on CentOS7 as a Matchbox / PXE / DHCP / TFTP server that chains iPXE so that VMware VMs can be provisioned via Matchbox.  This can be used to deploy multiple CoreOS clusters.

* __The CoreOS Tectonic Cluster__, deployed as VMs set for PXE booting, with their assigned MAC addressess extracted from ESXi and used to auto-generate a terraform configuration that can then be applied, via Matchbox and __The CoreOS Provisioner__, to deploy a Tectonic Kubernetes cluster.

> More about all this later...

TODO:

Cluster Deployment Workflow:
- Push out the empty OVA templates to the configured ESXi hosts, as per the cluster-builder hosts file
- Boot up each VM long enough to get the MAC address, then shut down.
- Use the gathered MACs + the 3 DNS entries + the fetched matchbox certs to construct a terraform config file.
- Apply the configuration via Terraform and Matchbox through the provisioner
- Startup all of the VMs - they should form a cluster.
- Terraform should provision the controller, and then the cluster is ready.

(last two steps are still unknown from cli)