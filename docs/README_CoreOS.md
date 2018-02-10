Tectonic CoreOS
===============

Bare Metal PXE/iPXE Install for VMware ESXi/vSphere (Alpha)
-----------------------------------------------------------

There are two core aspects to deploying bare metal __CoreOS__ (no pun):

* __The CoreOS Provisioner__, deployed on CentOS7 as a Matchbox / PXE / DHCP / TFTP server that chains iPXE so that VMware VMs can be provisioned via Matchbox over iPXE.  This can be used to deploy multiple CoreOS clusters.  It is very fast as the provisioner is setup to cache CoreOS local to the ESXi network.

* __The CoreOS Tectonic Cluster__, deployed as VMs set for PXE booting, with their assigned MAC addressess extracted from ESXi and used to auto-generate a terraform configuration that can then be applied, via Matchbox and __The CoreOS Provisioner__, to deploy a Tectonic Kubernetes cluster.  The provisioner DHCP server is auto-updated with the static IP assignments via MAC association.  CoreOS cluster node boot up and configuration is automatically handled by Terraform and Matchbox.

In __cluster-builder__ the provisioner has been designed as an all in one appliance that implements most of the core requirements for the baremetal install (found [here](https://coreos.com/tectonic/docs/latest/install/bare-metal/index.html) and in more detail listed [here](https://coreos.com/tectonic/docs/latest/install/bare-metal/metal-terraform.html)).

The provisioner is a drop in appliance that provides:

* A DHCP server with a configured __next-server__ for PXE booting.
* A TFTP service that hosts a pxelinux.0 netboot image that bootstraps iPXE on to PXE machines.
* An iPXE kernel that loads on to PXE and directs netboot clients to Matchbox.
* A configured Matchbox service that hosts the latest stable version of CoreOS for nodes and clusters configured by Terraform.

> Any requests for a __matchbox__ url (such as in the graphical installer) should use the provisioner URL.

After you deploy the provisioner, you can use it to deploy clusters.  The Tectonic Installer is basically a GUI wrapper around Terraform.

The GUI Installer does a good job of illustrating the process, so once you use it the first time, things will make more sense.  First you define the configuration, then validate it.  Once validated, it is __Applied__.  Only after the application reaches the point that the configuration has been submitted to matchbox can you power on the VMs.  It is somewhat an asynchronous provisioning in the spirit of a reconcilliation loop.

> If they try to contact Matchbox before their MAC addresses are registered in a cluster configuration, they will be rejected, and a message "Operating system not found" will appear after they contact matchbox.

Once the cluster configuration has been submitted to matchbox the VMs can be powered on.

Using __cluster-builder__ and the __coreos-pxe__ variant for the bootstrap phase of installing a cluster does the following:

* Deploys a thin, netboot VM ova with a 250GB thinly provisioned VMDK to the nodes as per cluster-builder configuration for vCPU, Memory and Network and ESXi location.
* Starts the VMs long enough to get their assigned MAC addresses, then stops them.
* Updates the Provisioner VM DHCP server with static entries for the MAC addresses to assign the permanent IPs.
* Builds a Terraform template file (work in progress)
* Creates two CSV bulk upload files for the GUI Installer for all controller and worker nodes and MAC address mappings.

After __cluster-builder__ completes, the GUI installer is launched, and the configuration can be entered with minimal effort... when the GUI completes... the Tectonic Cluster has been installed.

> The provisioner could theoretically be used, as a VMware Virtual Machine, to provision actual bare metal servers (not VMs).  Sadly, however, without VMs __cluster-builder__ would not be able to do the grunt work for compiling MAC addresses and provisioning resources.  

## General Setup

It isn't fully automated yet... only partially.  But given that the entire stack is self updating and managed by the CoreOS team, soon to be RedHat, the need to re-deploy a cluster a significant number of times seems unlikely.  Once the layout is right, it will likely have a long shelf life (unlike some whale based distros).

It is designed to work with the free ESXi hypervisors and doesn't use any vSphere features.

> But if you have vSphere, [this](https://coreos.com/tectonic/docs/latest/install/vmware/vmware-terraform.html) may prove to be a cleaner path to Tectonic.  If you'd like to contribute to __cluster-builder__ by coming up with a vSphere variant of CoreOS we'd be much obliged.

### Download the Tectonic Installer

Follow [this](https://coreos.com/tectonic/docs/latest/install/bare-metal/metal-terraform.html) documentation to download the Tectonic Installer. 
 
> I've personally had better luck with the linux version thus far...  

Once the installer has been downloaded make sure it is in the PATH, and also make sure to set __TECTONIC_HOME__ to the location of the installer folder in your BASH profile.

> __TECTONIC_HOME__ must be set for the cluster deployment to complete.

### DNS 

You will need to create the following DNS entries:

* __provisioner__: Eg. core-provisioner.idstudios.local 

> This is the all-in-one PXE appliance that is also a matchbox server.  It is entered as the matchbox urls for http a gRPC in the Graphical installer.

And then per cluster:

* __ingress__: eg. core-ingress.idstudios.local
* __tectonic control__: eg. core-admin.idstudios.local

The __provisioner__ is the domain name assigned to the provisioner VM.

__ingress__ should point to one or more worker nodes in a cluster, ideally load balanced over all of them.

__tectonic control__ should point to the controller node(s).  Also load balanced in a HA setup.

> You will need to enter these URLs into the Graphical installer.

Also, make sure to create entries in the DNS for all of the CoreOS nodes listed in the hosts file.

### Install the Provisioner

See the __core-provisioner__ in the __examples__ folder.

Only one provisioner is required, it can install many clusters.

The __matchbox-certs__ generated during the install will be used for API authentication during cluster provisioning.  Copy them into any __coreos-pxe__ cluster definition packages you create.

### Install the CoreOS Tectonic Cluster

#### Create the Cluster Package

See the __core-1__ in the __examples__ folder.

The folder will need to contain a __hosts__ file similar to the example, but will also require:

* tectonic_license.txt
* config.json

> Make sure to save your license into that file name: __tectonic_license.txt__.

Both can be obtained from Tectonic for their Free 10 node cluster. See [here](https://coreos.com/tectonic/docs/latest/install/bare-metal/metal-terraform.html) in the __Getting Started__ section.

Also make sure to copy the __matchbox-certs__ folder that was created during the deployment of the __core-provisioner__ into the cluster package folder.  You will upload these files via the Graphical installer.

#### Start SSH-AGENT

Terraform uses ssh-agent when attempting to establish passwordless connections with the node.

Before running __cluster-builder__:

    eval `ssh-agent` 
    ssh-add ~/.ssh/id_rsa

_(Assuming this is also the key that is authorized on the nodes.)_

> Don't start a new ssh-agent if one is already running.

#### Deploy the Cluster

Run the familiar __cluster-deploy__ command:

    bash cluster-deploy ids/core-1

This will deploy the VMs as per the __hosts__ file and provision them, then create a few artifacts to assist with the Tectonic install.

In the __cluster package folder__:

* terraform.tfvars (for the manual install that does not yet work)
* manual-controllers.csv (controllers are also called masters)
* manual-works.csv

#### Launch the Tectonic Installer

Right now the best way to install is with the Graphical web based Tectonic Installer:

    $TECTONIC_HOME/tectonic-installer/linux/installer

This opens up a web browser... select __Graphical Install - Bare Metal__.

Use the CSV files to bulk upload the mac addresses for controllers and workers.

All other required information should be found in the __cluster-builder__ cluster package folder.

#### Power on the Nodes

When the GUI installer asks to __Power On the Nodes__, use:

    bash cluster-control ids/core-1 start

This should allow Terraform to finish provisioning the nodes.  It can take awhile... but if you watch the Terraform "Apply" log, you will see the progress as the nodes have CoreOS installed and come online.

> It can take 30 minutes or more for a 10 node cluster.

#### Access the Tectonic Cluster

After the GUI install finishes, Make sure to __Download the Assets__, extract them and place them in the __cluster package folder__ for safe keeping.

You can then access the Tectonic Control Station at the ingress url specified in the hosts file.

Eg.

    https://core-ingress.idstudios.local

Once logged into the __Tectonic Control__ you can download a __.kubeconfig__ file that will allow you to easily setup your __kubectl__ on your workstation.

Enjoy a nice polished Kubernetes!  With __CoreOS__, chances are good you won't have to redeploy it again for a very long time.

Graphical Installer Walkthrough
-------------------------------

### Pick the Install Option

![Installation Options](images/coreos/coreos-ginstaller-step1.png)

![Installation Options](images/coreos/coreos-ginstaller-step1a.png)

### Enter Cluster Name, Upload License & Pull Secret

![License](images/coreos/coreos-ginstaller-step2-license.png)

![Pull Secret](images/coreos/coreos-ginstaller-step2-pull.png)

### Enter DNS for Tectonic Control and Ingress

![DNS](images/coreos/coreos-ginstaller-step3-dns.png)

### Choose Cluster Certificates Option

![Cluster Certificates](images/coreos/coreos-ginstaller-step4-certs.png)

### Enter Matchbox Server URLS for HTTP and gRPC

> This is the provisioning server appliance

![Matchbox / Provisioning Server](images/coreos/coreos-ginstaller-step5-matchbox.png)

### Upload Matchbox Certificates

> These were created during the provisioning of the server appliance

![Matchbox Certificates](images/coreos/coreos-ginstaller-step6-matchbox-certs.png)

![Matchbox Certificate Location](images/coreos/coreos-ginstaller-step6-matchbox-folder.png)

![Matchbox CA Certificate](images/coreos/coreos-ginstaller-step6-ca-cert.png)

### Bulk Upload Masters (Controllers) Information

![Masters/Controllers](images/coreos/coreos-ginstaller-step7-masters.png)

![Masters/Controllers CSV](images/coreos/coreos-ginstaller-step7-masters-csv.png)

![Masters/Controllers CSV Definition](images/coreos/coreos-ginstaller-step7-masters-csv-def.png)

![Masters/Controllers Uploaded](images/coreos/coreos-ginstaller-step7-masters-complete.png)

### Bulk Upload Workers Information

Do the same thing for the workers.

![Workers](images/coreos/coreos-ginstaller-step8-workers-complete.png)

### Select the ETCD Option (default)

![etcd](images/coreos/coreos-ginstaller-step9-etcd.png)

### Enter SSH Public Key for Nodes

> No image for this step... simply copy and paste or upload your public key.

### Submit and Apply the Configuration to Matchbox.

![Submit](images/coreos/coreos-ginstaller-step10-submit.png)

![Checking](images/coreos/coreos-ginstaller-step10-checking.png)

![Apply](images/coreos/coreos-ginstaller-step10-apply.png)

> You can see here that Transform is waiting for the machines to be provisioned by Matchbox (and CoreOS), so it continue to configure them and the cluster.

![Apply and Waiting](images/coreos/coreos-ginstaller-step10-apply-wait.png)


### Power on the VMs

Eg.

    bash cluster-control ids/core-1 start


> During this phase the VMs will go through several cycles of at least 2 reboots, please be patient here.

![VM Boot Init](images/coreos/coreos-vm-pxe-boot-init.png)


![VM First Boot](images/coreos/coreos-vm-pxe-first-boot.png)

This stage is only midway through CoreOS provisioning...

![VM Mid Boot](images/coreos/coreos-vm-pxe-midboot.png)

> Note the full domain name is assigned.

### Terraform will Complete, Tectonic Starting

![Waiting](images/coreos/coreos-ginstaller-step10-waiting.png)

> Note above that Terraform is still waiting on nodes 1,5,7 & 9, but node #2 just completed, and the details show "ssh-agent" was the mode of authentication.

When all the VMs have been provisioned by Terraform, the Tectonic Startup will begin...

![Tectonic Starting](images/coreos/coreos-ginstaller-step11-starting.png)

![Tectonic Starting](images/coreos/coreos-ginstaller-step11-starting2.png)


### Cluster Deployment Complete

![Startup Complete](images/coreos/coreos-ginstaller-start-complete.png)

> Download your Assets!

![Complete](images/coreos/coreos-ginstaller-complete.png)
