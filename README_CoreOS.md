Tectonic CoreOS on VMware ESXi/vSphere via PXE/iPXE - Alpha
===========================================================

There are two core aspects to deploying CoreOS:

* __The CoreOS Provisioner__, deployed on CentOS7 as a Matchbox / PXE / DHCP / TFTP server that chains iPXE so that VMware VMs can be provisioned via Matchbox over iPXE.  This can be used to deploy multiple CoreOS clusters.  It is very fast as the provisioner is setup to cache CoreOS local to the ESXi network.

* __The CoreOS Tectonic Cluster__, deployed as VMs set for PXE booting, with their assigned MAC addressess extracted from ESXi and used to auto-generate a terraform configuration that can then be applied, via Matchbox and __The CoreOS Provisioner__, to deploy a Tectonic Kubernetes cluster.  The provisioner DHCP server is auto-updated with the static IP assignments via MAC association.  CoreOS cluster node boot up and configuration is automatically handled by Terraform and Matchbox.

> More about all this later...

## General Setup

It isn't fully automated yet... only partially.

It is designed to work with the free ESXi hypervisors and doesn't use any vSphere features.

> But if you have vSphere, [this](https://coreos.com/tectonic/docs/latest/install/vmware/vmware-terraform.html) may prove to be a cleaner path to Tectonic.

### DNS 

You will need to create the following DNS entries:

* Provisioner: Eg. core-provisioner.idstudios.local

And per cluster:

* Ingress: eg. core-ingress.idstudios.local
* Control Plane: eg. core-admin.idstudios.local

Also, make sure to create entries in the DNS for all of the CoreOS nodes listed in the hosts file.

### Install the Provisioner

See the __core-provisioner__ in the __examples__ folder.

Only one provisioner is required, it can install many clusters.

The __matchbox-certs__ generated during the install will be used for API authentication during cluster provisioning.

### Install the CoreOS Tectonic Cluster

#### Create the Cluster Package

See the __core-1__ in the __examples__ folder.

The folder will need to contain a __hosts__ file similar to the example, but will also require:

* tectonic_license.txt
* config.json

Both can be obtained from Tectonic for their Free 10 node cluster.

Also make sure to copy the __matchbox-certs__ folder that was created during the deployment of the __core-provisioner__ into the cluster package folder.

#### Start SSH-AGENT

Terraform uses ssh-agent when attempting to establish passwordless connections with the node.

Before running __cluster-builder__:

    eval `ssh-agent` 
    ssh-add ~/.ssh/id_rsa

> Assuming this is also the key that is authorized on the nodes.

#### Do the Cluster Deployment

Run the usual cluster-deploy command:

    bash cluster-deploy ids/core-1

This will deploy the VMs as per the __hosts__ file and provision them, then create a few artifacts to assist with the Tectonic install.

In the __cluster package folder__:

* terraform.tfvars (for the manual install that does not yet work)
* manual-controllers.csv
* manual-works.csv

#### Launch the Tectonic Installer

Right now the best way to install is with the Web based Tectonic Installer:

    $TECTONIC_HOME/tectonic-installer/linux/installer

This opens up a web browser... select __Bare Metal - GUI__.

Use the CSV files to bulk upload the mac addresses for controllers and workers.

All other required information should be found in the __cluster package folder__.

#### Power on the Nodes

When the GUI installer asks to __Power On the Nodes__, use:

    bash cluster-control ids/core-1 start

This should allow Terraform to finish provisioning the nodes.

#### Access the Tectonic Cluster

After the GUI install finishes, Make sure to download the assets and place them in the __cluster package folder__.

You can then access the Tectonic Control Station at the ingress url specified in the hosts file.

Eg.

    https://core-ingress.idstudios.local




