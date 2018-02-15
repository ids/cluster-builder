Tectonic CoreOS
===============

Bare Metal PXE/iPXE Install for VMware ESXi/vSphere (Beta)
-----------------------------------------------------------

There are two core aspects to deploying bare metal __CoreOS__ (no pun):

* __The CoreOS Provisioner__, deployed on CentOS7 as a Matchbox / PXE / DHCP / TFTP server that chains iPXE so that VMware VMs can be provisioned via Matchbox over iPXE.  This can be used to deploy multiple CoreOS clusters.  It is very fast as the provisioner is setup to cache CoreOS local to the ESXi network.

* __The CoreOS Tectonic Cluster__, deployed as VMs set for PXE booting, with their assigned MAC addressess extracted from ESXi and used to auto-generate a terraform configuration that can then be applied, via Matchbox and __The CoreOS Provisioner__, to deploy a Tectonic Kubernetes cluster.  The provisioner DHCP server is auto-updated with the static IP assignments via MAC association.  CoreOS cluster node boot up and configuration is automatically handled by Terraform and Matchbox.

In __cluster-builder__ the provisioner has been designed as an all in one appliance that implements most of the core requirements for the bare metal install (found [here](https://coreos.com/tectonic/docs/latest/install/bare-metal/index.html) and in more detail listed [here](https://coreos.com/tectonic/docs/latest/install/bare-metal/metal-terraform.html)).

The provisioner provides:

* A DHCP server with a configured __next-server__ for PXE booting.
* A TFTP service that hosts a pxelinux.0 netboot image that bootstraps iPXE on to PXE machines.
* An iPXE kernel that once loaded directs netboot clients to Matchbox.
* A configured Matchbox service that hosts the latest stable version of CoreOS for nodes and clusters configured by Terraform, which is the engine underlying the installer.

> The provisioner could theoretically be used, as a VMware Virtual Machine, to provision actual bare metal servers (not VMs).  Sadly, however, without VMs __cluster-builder__ would not be able to do the grunt work for compiling MAC addresses and provisioning resources.

After you deploy the provisioner, you can use it to deploy clusters.  The Tectonic Graphical Installer is basically a GUI wrapper around Terraform, which communicates to Matchbox over the secure gRPC channel and submits configurations for clusters to be delivered via HTTP to the nodes as ignition configurations, queried through iPXE by MAC address.

> It is conceptually simiar to how Kickstart files are self hosted in Packer and made available to the bootstrap process via HTTP.

The GUI Installer does a good job of illustrating the process, so using it at least once can help to understand the process and things will make more sense.

> The default is to use the unattended Terraform installation process, but you can choose to exit out before applying and run the Graphical Installer to finish the job.

Easy as 1-2-3:

1. Define the configuration and validate it.
2. __Apply__ it (via Terraform/Matchbox).
3. Boot up the nodes, which will then request their configurations using their MAC addresses as the key to their ID.

> Only after the application reaches the point where the configuration has been submitted to Matchbox are the VMs powered on.  It is an asynchronous provisioning in the spirit of a reconcilliation loop and once you grokked works very well. If the VMs try to contact Matchbox before their MAC addresses are registered in a cluster configuration, they will be rejected, and a message "Operating system not found" will appear.

Using __cluster-builder__ and the __coreos-pxe__ variant for the bootstrap phase of installing a cluster does the following:

* Deploys a thin, netboot VM ova with a 250GB thinly provisioned VMDK to the nodes as per cluster-builder configuration for vCPU, Memory and Network and ESXi location.
* Starts the VMs long enough to get their assigned MAC addresses, then stops them.
* Updates the Provisioner VM DHCP server with static entries for the MAC addresses to assign the permanent IPs.
* Builds a Terraform template file (work in progress)
* Creates two CSV bulk upload files for the GUI Installer for all master/controller and worker nodes and MAC address mappings.

After __cluster-builder__ completes, the resulting Terraform configuration is applied. When this is complete the Tectonic Cluster has been installed - but is not yet finished.

## General Setup

This implementation is designed to work with the free ESXi hypervisors and doesn't use any vSphere features.

> But if you have vSphere, [this](https://coreos.com/tectonic/docs/latest/install/vmware/vmware-terraform.html) may prove to be a cleaner path to Tectonic.  If you'd like to contribute to __cluster-builder__ by coming up with a vSphere variant of CoreOS we'd be much obliged.

That said, the PXE approach produces a pure, undoctored CoreOS that is quite nice... and seems the favored approach among many.

#### Licensing

Tectonic offers a free 10 node license. See [Getting Started](https://coreos.com/tectonic/docs/latest/account/).

You will need to procure a license and pull secret.

#### VMware Fusion Notes

* You might need to run `sudo touch "/Library/Preferences/VMware Fusion/promiscAuthorized"` to prevent interactive prompting during the PXE install process.  However, launching the VMs manually anyway is good way to monitor the install process.
* Vmware Fusion 8.x doesn't work well on High Sierra, but neither does version 10.x.  NAT is frequently broken for private networks (which is what we use in cluster-builder).  If CoreOS is not installing on the nodes in a timely manner, or they are stuck in a PXE install loop, it is likely that the nodes can't NAT out to the internet.  This can be diagnosed by logging into the provisioner and attmepting to ping and resolve a public domain name.  If it doesn't work in one VM, it is likely broken for the network... and you will have to stop all the VMs and restart Fusion.  This is a 100% a VMware Fusion issue.

The VMware install process is nearly identical to the ESXi documented below except for the following modifications:

* The DHCP server on the provisioner isn't assigned the static IPs for the nodes.  It works best to use the VMware built in DHCP, so we bundle the __tftpserver__ and __nextserver__ into the static reservations that are added to __vmnet2/dhcpd.conf__ file.  The DHCP server on the provisioner is still enabled to support the PXE booting.
* Resolvable DNS names are required.  For portability I use my AWS Route 53 domain to create the records for the Fusion cluster... that way no matter where my laptop is, the nodes will resolve.  Putting these names into the __/etc/hosts__ file on the host doesn't work.

> See the [demo-core-privisioner](../examples/demo-core-provisioner/hosts) and [demo-core](../examples/demo-core/hosts) examples for CoreOS VMware Fusion deployment.

### Download the Tectonic Installer

Follow [this](https://coreos.com/tectonic/docs/latest/install/bare-metal/metal-terraform.html) documentation to download the Tectonic Installer. 
 
Once the installer has been downloaded make sure it is in the PATH, and also make sure to set __TECTONIC_HOME__ to the location of the installer folder in your BASH profile.

> __TECTONIC_HOME__ must be set for the cluster deployment to complete.

### DNS 

You will need to create the following DNS entries:

* __provisioner__: Eg. core-provisioner.idstudios.local 

> This is the all-in-one PXE appliance that is also a matchbox server.  It is entered for the "matchbox urls" in the Graphical installer to enable http/gRPC communication with Matchbox .

And then per cluster:

* __ingress__: eg. core-ingress.idstudios.local
* __tectonic control__: eg. core-admin.idstudios.local

The __provisioner__ is the domain name assigned to the provisioner VM (as illustrated in the examples)

__ingress__ should point to one or more worker nodes in a cluster, ideally load balanced over all of them.

__tectonic control__ should point to the controller node(s).  Also load balanced in a HA setup.

> You will need to enter these URLs into the Graphical installer.

Also, make sure to create entries in the DNS for all of the CoreOS nodes listed in the hosts file.

> the __ingress__ DNS entry should be a round robin DNS entry to all of the worker nodes, while the __tectonic control__ DNS entry should be a round robin DNS entry to all of the controller/master nodes.

### Install the Provisioner

See the __core-provisioner__ in the __examples__ folder.

Only one provisioner is required, it can install many clusters.

The __matchbox-certs__ generated during the install will be used for API authentication during cluster provisioning.  Copy them into any __coreos-pxe__ cluster definition packages you create.

### Install the CoreOS Tectonic Cluster

#### Create the Cluster Package

See the __core-1__ in the __examples__ folder.

The folder will need to contain a __hosts__ file similar to the example, but will also require:

* tectonic-license.txt
* config.json

> Make sure to save your license into that file name: __tectonic-license.txt__.

Both can be obtained from Tectonic for their Free 10 node cluster. See [Getting Started](https://coreos.com/tectonic/docs/latest/account/).

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

* terraform.tfvars (this is the main configuration for the unattended installation)
* manual-masters.csv (in support of the Graphical installer)
* manual-workers.csv (in support of the Graphical installer)

#### Launch the Tectonic Installer

The Terraform __apply__ will happen automatically as part of the deployment if you don't continue with the default.

> __Note__: The iSCSI units required to support Kubernetes iSCSI persistant volume direct Pod access are only installed with the unattended Terraform installation.

If you cancel before the __apply__, you can proceed with the Graphical web based Tectonic Installer:

    $TECTONIC_HOME/tectonic-installer/linux/installer

This opens up a web browser... select __Graphical Install - Bare Metal__.

Use the CSV files to bulk upload the mac addresses for controllers and workers.

All other required information should be found in the __cluster-builder__ cluster package folder.

#### Power on the Nodes

When the Terraform __apply__ begins the "Refreshing state..." wait message described in the console output, or the GUI installer asks to __Power On the Nodes__, use the following in another terminal tab:

    bash cluster-control ids/core-1 start

This should allow Terraform to finish provisioning the nodes.  It can take awhile... but if you watch the Terraform "Apply" log, you will see the progress as the nodes have CoreOS installed and come online.

> You can start the VMs any way you like, and in any order.

> It can take 30 minutes or more for a 10 node cluster.

__Note__: When the unattended Terraform __apply__ completes successfully, the cluster is not yet fully installed.  In the background all of the __Tectonic__ specific services will install and this can take 10 or more minutes after the script completes.  

> I like to ssh into the controller/master node and run `top` to watch the installation process, and when things quiet down, hit the ingress url... and it brings up the Tectonic Console.

#### Access the Tectonic Cluster

After the Terraform __apply__, save the assets in the __generated__ folder to the __cluster package folder__ for safe keeping.

Or, after the GUI install finishes, Make sure to __Download the Assets__, extract them and place them in the __cluster package folder__ for safe keeping.

You can then access the Tectonic Control Station at the ingress url specified in the hosts file.

Eg.

    https://core-ingress.idstudios.local

Once logged into the __Tectonic Control__ you can download a __.kubeconfig__ file that will allow you to easily setup your __kubectl__ on your workstation.

Enjoy a nice polished Kubernetes!  With __CoreOS__, chances are good you won't have to redeploy it again for a very long time.

> Checkout the __xtras/coreos__ folder for an __open-vm-tools.yml__ daemonset that will provide VMware tools on all the nodes.


Appendix A: Graphical Installer Walkthrough
-------------------------------------------

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
