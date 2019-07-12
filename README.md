Cluster Builder
===============

[Ansible](https://www.ansible.com/) and [Packer](https://www.packer.io) IaC() scripts to configure [DC/OS](https://dcos.io/), [Docker Swarm](https://www.docker.com/) and [KubeAdm Stock Kubernetes](https://kubernetes.io/docs/setup/independent/) container orchestration clusters and deploy them into VMware environments using simple Ansible inventory host file declarations and a minimal toolset.

> Deploy a production ready container orchestration cluster to VMware in minutes while you read [hacker news](https://news.ycombinator.com/)...

## Usage Scenarios

__Cluster Builder__ is designed to work with the freely available VMware _ESXI Hypervisor_ and the free use license, as well as the professional desktop versions of VMware Worksation for Windows and Linux, and VMware Fusion for Mac.  It has been developed and tested on all platforms.

> It will also work with VMware's commercially supported _vSphere_ suite, making it great for both production and non-production environments.  There is no cost barrier to using cluster-builder.

### Desktop Micro-Service and Orchestration Development

__Cluster Builder__ enables both local and remote deployment, leveraging the same toolset to deploy identical cluster images to all environments.

![cluster-builder Desktop Usage](docs/images/cluster-builder-desktop-usage.png)

### Enterprise Hybrid-Cloud On-Premise Deployment

__Cluster Builder__ provides a production grade on-premise deployment and operating model for __Kubernetes__, __DC/OS__ and __Docker Swarm__ clusters.

![cluster-builder Enterprise Usage](docs/images/cluster-builder-enterprise-usage.png)

> Emphasis is on __Kubernetes__ now that __Kubernetes__ has won the container orchestration wars.

> See [here](docs/images/cluster-builder-overview.png) for a diagramtic depiction of the __Cluster Builder__ components.


## Usage Guide

__Cluster Builder__ is designed to handle ~all~ most of the complexity associated with on-premise deployments of [DC/OS](https://dcos.io/), [Docker Swarm](https://www.docker.com/) and [Kubernetes](https://kubernetes.io/) container orchestration clusters.

1. [Supported Clusters](#supported-clusters)
2. [Deployment Options](#deployment-options)
3. [Setup and Environment Preparation](#setup-and-environment-preparation)
4. [Cluster Definition Packages](#cluster-definition-packages)
5. [General Cluster Configuration](#general-cluster-configuration)
6. [Kubernetes KubeAdm Configuration](#kubernetes-kubeadm-configuration)
7. [Cluster Builder Usage](#cluster-builder-usage)
8. [Deploying a Cluster](#deploying-a-cluster)
9. [Connecting to a Cluster](#connecting-to-a-cluster)
10. [Kubernetes Dashboard](#kubernetes-dashboard)
11. [Change Cluster Password](#change-cluster-password)
12. [Controlling Cluster VM Nodes](#controlling-cluster-vm-nodes)
13. [Kubernetes iSCSI Provisioner and Targetd Storage Appliance](kubernetes-iscsi-provisioner-and-targetd-storage-appliance)
14. [Kubernetes ElasticSearch Logging](#kubernetes-elasticsearch-logging)
15. [Kubernetes CI Job Service Accounts](#kubernetes-ci-job-service-accounts)
16. [Kubernetes Load Testing Sample Stack](#kubernetes-load-testing-sample-stack)
17. [Helm Setup and KEDA](#helm-setup-and-keda)
18. [Host Mounted NFS Storage](#host-mounted-nfs-storage)
19. [Knative and Istio](#knative-and-istio)
20. [System Profile](#system-profile)

### Supported Clusters

* CentOS 7 Docker CE
* CentOS 7 DC/OS
* RedHat Enterprise 7 Docker CE
* CentOS 7.6 Kubernetes (Stock `kubeadm`)
* Fedora 29 Kubernetes (Stock `kubeadm`)

> The last two `kubeadm` based Kubernetes clusters are likely to be the focus going forward.  Stock `kubeadm` clusters are quite stable and reliable when properly configured.

### Deployment Options

There are two types of deployment: __local machine__ and remote __ESXI__ hypervisor (or vSphere).

Local deployments are supported for:

* VMware Fusion Pro 10+ for macOS
* VMware Workstation Pro 12+ for Windows
* Vmware Workstation Pro 12+ for Linux

Production usage targets:

* VMware ESXi (direct)
* VMware vSphere

> __Note__ that __DRS__ must be turned __off__ when deploying with __Cluster Builder__ to a vSphere/ESXi environment as the toolset currently expects VMs to be on the ESXi hosts specified in the deployment configuration file.  A future version will support a vSphere API based deployment option that will leverage and enable functionality such as DRS.  While DRS must be turned _off_ during current deployments, it can be turned back on when cluster deployment is complete (which usually only takes a few minutes).  This may result in the loss of post-deployment _cluster-control_ capabilities after VMs have been relocated, but should not affect cluster operations or management that relies on SSH.  On the up side, you don't need vCenter to perform __Cluster Builder__ deployments.  Free ESXi will do nicely.

> Each variant starts in the **node-packer** and uses _packer_ to build a base VMX/OVA template image from distribution iso.

#### Docker Swarm Cluster Types

* centos-swarm
* rhel-swarm

#### DC/OS Cluster Types

* centos-dcos

#### Kubernetes Cluster Types

There are two maintained `kubeadm` built Kubernetes variants:

* centos-k8s
* fedora-k8s

These `kubeadm` __Kubernetes__ cluster builds come pre-configured with a core toolset rivaling the latest cloud provider offerings:

* [Canal/Flannel](https://docs.projectcalico.org/v3.4/getting-started/kubernetes/installation/flannel) CNI network plugin with _Network Policy_ support
* [MetalLB](https://metallb.universe.tf/) the on-premise load balancer
* NGINX or Traefik for ingress and inbound traffic routing
* [Knative](https://cloud.google.com/knative/) serverless platform integration
* The Kubernetes Dashboard w/ Heapster integration and dashboard graphics (soon to support Metrics Server)
* iSCSI Provisioner integration and with an external Targetd Storage Appliance VM for PVC storage

> The __CentOS7 K8s__ cluster has been load tested to perform near the performance of Tectonic CoreOS w/ Canal CNI and with similar stability.  Recent builds out perform past CoreOS benchmarks.

The __Fedora K8s__ cluster is the bleeding edge and targetted for experimentation and/or those who want a current 4.x kernel.

#### Extras

__Cluster Builder__ can also deploy a special __Targetd Storage Appliance__ to supply persistent volume storage to Kubernetes clusters.

* targetd-server

For more information on Targetd [see the Kubernetes Storage Readme](docs/kubernetes-iscsi-storage.md)

> __Note__ it is best to deploy the __Targetd Storage Appliance__ prior to installing the Kubernetes cluster as the cluster deployment process will deploy and configure an __iscsi-provisioner__ deployment configured for the Targetd server when it already exists - and when the cluster _hosts_ file contains the necessary configuration information for the Targetd.

### Setup and Environment Preparation

#### macOS / Linux

* VMware Fusion Pro 10+ / Workstation Pro 12+
* VMware ESXi 6.5+ (optional)
* VMware's [ovftool](https://my.vmware.com/web/vmware/details?productId=614&downloadGroup=OVFTOOL420) in $PATH
* Ansible 2.3+ `brew install/upgrade ansible`
* Hashicorp [Packer 1.04+](https://www.packer.io/downloads.html)
* __kubectl__ 1.13+ (Kubernetes - `brew install/upgrade kubernetes-cli`)
* Docker for Mac or __docker-ce__ (Swarm only)
* Python `pip`

__Linux Setup Notes__

* For local machine deployments, configure _VMnet8_ (the NAT interface) with correct subnet and DHCP settings for the host file configuration and DNS names you plan to use.  The examples are given using either a __192.168.100.0__ or __192.168.101.0__ subnets (which map to the demo.idstudios.io and vm.idstudios.io example DNS names in the example cluster definition packages), but these can be adjusted as needed.  They simply need to align with the deployed __fusion_net__ and __fusion_net_type__ specified in the configuration, which in the case of Windows should be __vmnet8__.
* Ensure all VMware tools and Packer are in __PATH__:
  * vmrun
  * ovftool
* Ensure __kubectl__ is in the PATH (for K8s deployments).
* Ensure __docker__ is in the PATH (for swarm deployments).
* Ensure __host__ is in the PATH.
* For local deployments ensure that the cluster definition package configuration uses __vmnet8__ and __nat__ for the __fusion_net__ and __fusion_net_type__ settings respectively.  As mentioned above, the host machine will need to be configured with the correct __subnet__ for __vmnet8__, and this has to match the networking settings defined for the target cluster configuration.

> __Note__ Make sure and use _VMware's Virtual Network Editor_ that comes with the Pro version of Fusion/Workstation.  Trying to adjust the interface subnets by hand can be problematic.

__macOS Setup Notes__

* The locally deployed examples use a custom VMware Fusion host-only network that maps to **vmnet2** with the network **192.168.100.0**.  This should be created in Fusion Pro before attempting to deploy the fusion demos.

#### Windows

* VMware Workstation Pro 12+
* VMware ESXi 6.5+ (optional)
* Windows Subsystem for Linux by Ubuntu (WSL)
* __Ansible__ installed in the WSL via apt-get
* __kubectl__ installed via the [xtras/wsl/install-kubectl](xtras/wsl/install-kubectl) script
* __docker-ce__ installed via the [xtras/wsl/install-kubectl](xtras/wsl/install-kubectl) script
* Hashicorp [Packer 1.04+](https://www.packer.io/downloads.html)
* Python `pip` installed in the WSL

__Windows Setup Notes__

* When starting the WSL Bash shell make sure to start it with __Run as Administrator__.
* For local machine deployments, configure VMnet8 (the NAT interface) with correct subnet and DHCP settings for the host file configuration and DNS names you plan to use.  The examples are given using either a __192.168.100.0__ or __192.168.101.0__ subnet, but these can be adjusted as needed.  They simply need to align with the deployed __fusion_net__ and __fusion_net_type__ specified, which in the case of Windows should be __vmnet8__.
* Ensure all VMware tools and Packer are in PATH for __bash__ and __cmd__.  This can be done by adding them to the Windows system path:
  * vmrun.exe
  * ovftool.exe
* Ensure __kubectl__ is in the PATH (for K8s deployments).
* Ensure __docker__ is in the PATH (for swarm deployments).
* Ensure __host__ is in the PATH.
* For local deployments ensure that the cluster definition package configuration uses __vmnet8__ and __nat__ for the __fusion_net__ and __fusion_net_type__ settings respectively.  As mentioned above, the host machine will need to be configured with the correct __subnet__ for __vmnet8__, and this has to match the networking settings defined for the target cluster configuration.

Unlike Fusion where the host-only network is NAT'd by default, host-only on VMware Workstation for Windows does not have internet access.  Through experimentation it has been found that for local machine deployments cluster builder works best on the NAT'd interface, which is __VMnet8__ by default.

#### Cluster Builder Control Box (Jump Box & Management Station)

The [Cluster Builder Control Box](https://github.com/ids/cluster-builder-control) is also an alternative.  It is a CentOS7 desktop with all the tools required for running **cluster-builder**.

It can be used:

* Running locally on a Windows or Linux VMware Workstation, or VMware Fusion for macOS
* Running remotely on an ESXi server

It can even be built remotely directly on an ESXi server, which is the intended purpose.  For production deployments it can form the foundation for a control station that operates within the ESX environment and is used to centralize management of the clusters.

For instructions see the [Cluster Builder Control Box](https://github.com/ids/cluster-builder-control) README.

#### General Preparation

* For all cluster types ensure that the host names specified in the inventory file also resolve.  For ESXi deployments these should resolve via DNS.  For Fusion deployments you can use __/etc/hosts__ on the host, but DNS resolution still works best.

* It is necessary that the **id_rsa.pub** value of the **cluster-builder** operator account be set in the **node-packer/keys/authorized_keys**. This is required as the scripts use passwordless SSH to access the 
VMs for provisioning.

* You will like want to adjust your __sudo__ timeout if you are doing local workstation deployments with minimal resources.  This can be done with __visudo__ and setting the [timestamp_timeout](https://lifehacker.com/make-sudo-sessions-last-longer-in-linux-1221545774) value.

* The cluster provisioning scripts rely on a **VM template OVA** that corresponds to the cluster type.  These are built by packer and located in **node-packer/output_ovas**.  See the cluster node packer [readme](https://github.com/ids/cluster-builder/blob/master/node-packer/README.md).  The **cluster-deploy** script will attempt to build the ova if it isn't found where expected.

__Note for Red Hat Deployments__
The cluster definition package (folder) you create in the __clusters__ folder will need to contain a valid __rhel7-setup.sh__ file and __rhel.lic__ file. Additionally, the ISO needs to be manually downloaded and place in **node-packer/iso**.

### Cluster Definition Packages

Everything is based on the **Ansible inventory file**, which defines the cluster specifications. These are defined in **hosts** files located in a folder given the cluster name:

Eg. In the **clusters/eg** folder there is:

```
demo-k8s
  |_ hosts
```

Sample cluster packages are located in the **clusters/eg** folder and can be copied into your own **clusters/org** folder and customized according to your infrastructure and networks.

For a fictional organization __ACME__, the **acme** subfolder is created, and the desired cluster definition package (folder) copied:

Eg.

```
clusters
 |_ acme
  |_ demo-k8s
	 - hosts
```
The following command would then deploy the cluster:

```
$ bash cluster-deploy acme/demo-k8s
```

> __Note__ that for all the cluster definition package examples you will need to ensure that the network specified, and DNS names used resolve correctly to the _IP Addresses_ specified in the __hosts__ files.
> Eg.  
```
[k8s_masters]
k8s-m1.idstudios.local ansible_host=192.168.1.220
``` 
> In the example, the inventory host name __k8s-m1.idstudios.local__ must resolve to __192.168.1.220__, and the subnet used must align with either the subnet of the local assigned VMware network interface, or the subnet of the assigned ESXi VLAN.

> The **demo** series of local deployments use DNS names hosted by __idstudios.io__, which resolve to local private network addresses.  These domain names can be used for local deployments if the subnet/addressing is also used sin your local environments.

### General Cluster Configuration

The following guides containe some specific setup information depending on the target deployment.

See the [Local Deployment Guide](docs/local_deployment_guide.md) for details about deploying on VMware Fusion and Workstation.

See the [ESXi Deployment Guide](docs/esxi_deployment_guide.md) for details about deploying to ESXi hypervisor(s).

### Kubernetes KubeAdm Configuration

With respect to `centos-k8s` and `fedora-k8s` based `kubeadm` clusters there are additional configuration parameters to those described in the _general_ guides:

	k8s_version=1.14.*

The __k8s_version__ setting controls what version of the kubernetes binaries are installed on the nodes.  
This can be used to set a specific version of __1.13__ or __1.14__, or it can be set to the latest patch release in the series using the __*__ wildcard.

	k8s_network_cni=calico-policy

The __k8s_network_cni__ setting can be one of: __canal__ or __calico__.  It defaults to __canal__.

> Only __canal__ supports network policy at the present time as __calico__ requires _Istio_ and is somewhat more complicated to stabilize.  Work is still underway on a __calico-policy__ variant.

	k8s_metallb_address_range=192.168.1.180-192.168.1.190

The __k8s_metallb_address_range__ setting, when populated, will trigger the install of [MetalLB](https://metallb.universe.tf/), the on-premise load balancer for Kubernetes. It must be set to a valid address range for the cluster, with a subnet routeable to the cluster nodes.

	k8s_ingress_controller=nginx

The __k8s_ingress_controller__ setting can be one of: __nginx__, __traefik-nodeport__, __traefik-daemonset__ or __traefik-deploymnet__.  It defaults to __nginx__ which is exposed over _NodePort_.

	k8s_cluster_cidr=10.10.0.0/16

This defaults to __10.244.0.0/16__ for Canal and __192.168.0.0/16__ for Calico, but may conflict with your environment if this network is already in use.  Use __k8s_cluster_cidr__ to override.

> As an example, my management network is `192.168.1.0/24`, and my local virtual network for VMware is `192.168.100.0/24`.  Therefore the default for _Calico_ will not work and many of the pods would not start due to network address conflict.

	k8s_control_plane_uri=k8s-admin.onprem.idstudios.io

The __k8s_control_plane_uri__ setting should be either a load balancer or round-robin DNS configuration that resolves to all of the __master__ nodes.

	k8s_ingress_url=k8s-ingress.onprem.idstudios.io

The __k8s_ingress_url__ setting should be either a load balancer or round-robin DNS configuration that resolves to all of the __worker__ nodes.

	k8s_cluster_token=9aeb42.99b7540a5833866a

The __k8s_cluster_token__ should be unique to each cluster.

	k8s_workloads_on_master=true/false

The __k8s_workloads_on_master__ setting removes all taints on the master node that prevent pods from being scheduled, allowing workloads on the master node.  Used mostly for single node development clusters.

	k8s_coredns_loop_check_disable=true

(optional) This can be used to fix a crashing _CoreDNS_ when deploying to some environments with __calico__, the cause is under invesigation, and the workaround does not appear to impair cluster function.  If it is not needed in your environment it can be left out of the configuration.

	k8s_cni_wait_min=7
	k8s_worker_wait_min=7
	k8s_calico_node_wait_min=3

The __k8s_XXX_wait_min__ settings allow control of various pauses during the cluster deployment.  The wait times will vary depending on your environment, and if deployments proceed too soon the PODS will not come up properly.  Adjust these values as required.  Larger clusters will require longer wait times.

#### Working KubeAdm Formulas

The following are based on the `centos-k8s` __kubeadm__ based Kubernetes deployment, but should also work with `fedora-k8s`.  Thus far testing has revealed that `centos-k8s` performs better and with greater stability.  

For local development single node deployments (`k8s_workloads_on_master`), as in the [demo-k8s example](clusters/eg/demo-k8s-single/hosts), when planning to install _Istio_ and _Knative_ ensure to allocate at least _5GB of RAM and 4 vCPU_ to your single node cluster.

##### Formula: Targetd Storage Appliance

The Targetd Storage Appliance provides backing iSCSI dynamic volumes to one or more Kubernetes clusters.  It can simulate a SAN appliance in pre-production scenarios.  It is configured with a 1TB thinly provisioned volume.  It provides persistent storage for stateful services, and can also be configured as an NFS server to provide shared storage to front end web farms, etc.

```
targetd_server=192.168.100.250
targetd_server_iqn=iqn.2003-01.org.linux-iscsi.minishift:targetd
targetd_server_volume_group=vg-targetd
targetd_server_provisioner_name=iscsi-targetd
targetd_server_account_credentials=targetd-account
targetd_server_account_username=admin
targetd_server_account_password=ciao
```

Adjust the settings to suit your environment, and then simply copy the settings block into any cluster configuration you wish to have access to the iSCSI services.

See the full examples for [local deployment](clusters/eg/demo-targetd/hosts) and [ESXi deployment](clusters/eg/targetd-server/hosts).

##### Formula: Basic Kubernetes (Stable)

A stable foundation to build on:

* __CentOS 7.6 (1810)__ minimal OS node
* `kubeadm` __1.13.x__, __1.14.x__ pr __1.15.x Kubernetes w/ __Canal CNI (3.5)__ network plugin w/ Network Policy
* __MetalLB (0.7.3)__ baremetal load balancer
* __NGINX Ingress Controller (0.21)__
* __Kubernetes Dashboard (1.10.1)__ w/ Heapster, Grafana, InfluxDB (1.5.4)

(As shown in the example below, deployed to the local VMware Fusion private network of `192.168.100.0/24`).

```
k8s_version=1.14.*
k8s_metallb_address_range=192.168.100.150-192.168.100.169
k8s_network_cni=canal
k8s_control_plane_uri=k8s-admin.demo.idstudios.io
k8s_advertise_addr=192.168.100.200
k8s_ingress_url=k8s-ingress.demo.idstudios.io
k8s_cluster_token=9aeb42.99b7540a5833866a
```

See the full examples for [local deployment](clusters/eg/demo-k8s/hosts) and [ESXi deployment](clusters/eg/esxi-k8s/hosts).

> Note that these examples are setup to make use of a Targetd Storage Appliance that had been previously deployed.

#### VMware Fusion/Workstation Complete Examples

* [Kubernetes 1.14 (Single Node) CentOS 7.6 - VMware Fusion/Workstation](clusters/eg/demo-k8s/hosts)
* [DC/OS in VMware Fusion/Workstation](clusters/eg/demo-dcos/hosts)
* [Docker CE in VMware Fusion/Workstation](clusters/eg/demo-swarm/hosts)

#### VMware ESXi Examples

* [Kubernetes 1.14 on CentOS 7.6 - ESXi ](clusters/eg/esxi-k8s/hosts)
* [DC/OS on ESXi](clusters/eg/esxi-dcos/hosts)
* [Docker CE on ESXi](clusters/eg/esxi-swarm/hosts)

### Cluster Builder Usage

The __Cluster Builder__ project is designed as a generic toolset for deployment.  All user specific configuration information is stored in the cluster definition packages which are kept in the __clusters__ folder.

It is recommended that an organization establish a base folder git repository within the __clusters__ folder to store their cluster definition packages.  Anything kept in __clusters__ will be ignored by the parent cluster-builder git repository.

__Eg.__

```
cluster-builder
 |_ clusters
  |_ ids          # an organization - git repo - named anything - shorter is better
   |_ swarm-dev   # a cluster definition package in the organization repo
    |_ hosts      # the cluster inventory hosts file
```
All resulting artifacts from __Cluster Builder__ are then stored within the cluster definition package.

### Deploying a Cluster
To deploy a cluster use **cluster-deploy**:

	$ bash cluster-deploy <inventory-package | cluster-name>

Eg.

	$ bash cluster-deploy eg/demo-swarm

### Connecting to a Cluster
Once a cluster has been deployed, all of the required and relevant artifacts for administering that cluster will be located in the cluster definition package folder.  Keep these safe (such as in a secure source control repository or vault).

In the case of __Kubernetes__, a __kube-config__ file will be located in the cluster package folder.  The cluster can then be managed using this configuration file:

```
$ kubectl --kubeconfig <cluster pkg folder path>/kube-config get pods --all-namespaces
```

Or the details in the `kube-config` file can be merged into your `~/.kube/config`.

> You will also find all other artifacts used in the creation of the cluster, such as the `kube-adm.yml`, cluster certificates, and scripts to join additional master and worker nodes.

### Kubernetes Dashboard
Connecting to the __Kubernetes Dashboard__ follows the standard process:

```
kubectl --kubeconfig <cluster pkg folder path>/kube-config proxy
```

Then browse to the following url:
http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login

> __Tip:__  Bookmark that!

Choose the `token` option for authentication.  You can find the token required in the cluster package folder in a file called `web-ui-token`.  Paste the contents into the login dialog and you will be authenticated to the __Kubernetes Dashboard__ in the cluster-admin role.

> Note the idle CPU and memory effeciency of the cluster in the heapster process resource allocation graphs.

### Change Cluster Password
Change password is now integrated into the cluster deployment process.

For __CentOS__ deployments, both the __root__ and __admin__ passwords are prompted for change at the end of the cluster deployment.

> A bit of an annoyance, but it is integrated to ensure that clusters are never deployed into production with default root passwords.  TODO: Enhance to support prompt-free deployments.

This functionality is also available as as top level script:

	bash cluster-passwd <cluster package> [user to change]

Eg.

	bash cluster-passwd eg/esxi-swarm admin

It is intended to be run on a regular basis as per the standard operating procedures for password change management.

### Controlling Cluster VM Nodes
There are ansible tasks that use the inventory files to execute VM control commands.

Use **cluster-control**:

	bash cluster-control <inventory-package | cluster-name> <action: one of stop|suspend|start|destroy>

__Eg.__

	$ bash cluster-control eg/demo-swarm suspend

### Kubernetes iSCSI Provisioner and Targetd Storage Appliance

As Kubernetes provides native storage support for __iSCSI__ and __NFS__, the cleanest most efficient path to providing __persistent volume ReadWriteOnce__ storage is to leverage iSCSI.

The __Cluster Builder__ `kubeadm` Kubernetes deployment can be paired with a __Targetd Server Appliance__ VM that can provide dynamically provisioned __PVCs__ using the __open-iscsi__ platform.

For details see the [Kubernetes iSCSI Storage Guide](docs/kubernetes-iscsi-storage.md)

### Host Mounted NFS Storage

Place the following file in the cluster definition package folder:

  nfs_shares.yml

In the format:

```
  nfs_shares:
    - folder: the name of the local mount folder
      fstab: the fstab entry
      group: an inventory group of hosts on which to setup this mount
```

__Eg.__

```
  nfs_shares:
    - folder: /mnt/nfs/shared
      fstab: "192.168.1.10:/Users/seanhig/NFS_SharedStorage  /mnt/nfs/shared   nfs      rw,sync,hard,intr  0     0"
      group: "docker_swarm_worker"
    - folder: /mnt/nfs/shared
      fstab: "192.168.1.10:/Users/seanhig/Google\\040Drive/Backups/NFS_Backups  /mnt/nfs/backups   nfs      rw,sync,hard,intr  0     0"
      group: "docker_swarm_worker"
```

And then run the ansible playbook for the platform:

__Eg.__

  ansible-playbook -i clusters/eg/esxi-swarm/hosts ansible/centos-nfs-shares.yml

And it will setup the mounts according to host group membership specified in the nfs_shares.yml configuration.

### Kubernetes ElasticSearch Logging
As of release __19.04__ all _Kubernetes_ clusters are configured for `json-file` logging to support log aggregation using `fluent-bit`.

> __Note__ that this configuration is designed to work OOTB with the __Targetd Storage Appliance__ and the __MetalLB__ load balancer.  If these are not part of the __cluster-builder__ configuration, the installation will need to be modified.  All logging services are configured to reside in the `kube-logging` namespace.

To install and configure __ElasticSearch__ for log aggregation:

1. Ensure that you have installed the __Targetd Storage Appliance__ and configured your cluster with the `iscsi-provisioner`.  Elastic log data will be stored on __PVCs__ hosted on the appliance.

2. Install the `elastic` stack, configured to use the iscsi storage provider.
```
kubectl apply -f xtras/k8s/elastic/elastic.yml
```

3. Wait for the installation to complete:
```
kubectl rollout status sts/es-cluster -n kube-logging
```

4. Install the `fluent-bit` collector __DaemonSet__:
```
kubectl apply -f xtras/k8s/elastic/fluent-bit.yml
```

5. Wait for the `fluent-bit` installation to complete:
```
kubectl rollout status ds/fluent-bit -n kube-logging
```

6. Install `kibana`:
```
kubectl apply -f xtras/k8s/elastic/kibana.yml
```

Verify the assigned __IP Addresses__ for the __ElasticSearch__ and __Kibana__ services:

```
kubectl get svc -n kube-logging
```

The output should resemble the following example:

```
NAME            TYPE           CLUSTER-IP       EXTERNAL-IP       PORT(S)                         AGE
elasticsearch   LoadBalancer   10.106.48.196    192.168.100.151   9200:31513/TCP,9300:30019/TCP   46m
kibana          LoadBalancer   10.107.197.119   192.168.100.152   5601:31667/TCP                  37m
```

You can verify the operation of __ElasticSearch__:

```
$ curl http://<external-ip>:9200

{
  "name" : "es-cluster-2",
  "cluster_name" : "k8s-logs",
  "cluster_uuid" : "TUAs0QJnTRinewzreumWUA",
  "version" : {
    "number" : "6.4.3",
    "build_flavor" : "oss",
    "build_type" : "tar",
    "build_hash" : "fe40335",
    "build_date" : "2018-10-30T23:17:19.084789Z",
    "build_snapshot" : false,
    "lucene_version" : "7.4.0",
    "minimum_wire_compatibility_version" : "5.6.0",
    "minimum_index_compatibility_version" : "5.0.0"
  },
  "tagline" : "You Know, for Search"
}

```

Open __Kibana__ at the external-ip address, on port :5601.

```
open http://192.168.100.151:5601
```

Look for the following __indexes__ from the `fluent-bit` configuration:

* __kube-*__, all the container logs from the cluster
* __node-cpu*__, a stream of node cpu metrics
* __node-mem*__, a stream of node memory metrics

### Kubernetes CI Job Service Accounts

Kubernetes RBAC and service accounts offer a popular model for granting controlled access to CI/CD processes.  It involves creating a `ClusterRole` with the necessary object/verb permission ACLs, and then associating it via `ClusterRoleBinding` to a Kubernetes __service account__, authenticated via an __access token__, stored as a `Secret`.

#### Step 1 - Create the Service Account

	kubectl create serviceaccount ci-runner

#### Step 2 - Get the Service Account Secret Tokens & Build Kube Config

  kubectl get secrets
  kubectl describe secret ci-runner-<hash>

This will show two tokens, the CA and the user token.  Use them to construct a kube-config for your cluster using the __ci-runner__ service account.

__Eg.__

```
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tL<blah>
    server: https://pks-k8s-01.onprem.idstudios.io:8443
  name: k8s-01-runner
contexts:
- context:
    cluster: k8s-01-runner
    user: ci-runner
  name: k8s-01-runner
current-context: k8s-01-runner
kind: Config
preferences: {}
users:
- name: ci-runner
  user:
    token: eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImNpLXJ1bm5lci10b2tlbi05N3dycCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJjaS1ydW5uZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI3ZTY4OTMyYS00M2FjLTExZTgtYjM1Zi0wMDUwNTY4YTVkNjciLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGVmYXVsdDpjaS1ydW5uZXIifQ.c6nkA8PK1-NJ2ObOwHpaARpDLddPlAgzHcyEh0xM1F88UbpTBh3DdkA_xc0dtJUOeTOn4CrUYgBOPgbFfurweSix53G4wOeOnYnxJrA7PtPJjXUn54peGse_LFp6UCaufPEPcCvVgc2UcRL4DSLPZWwziGhxhm4p-qsTbl_r9SQhvAC_CKYyrYX00q_vcZQS-cdqvo1e34YVIb7W7neWCmzEitKwslMz0IkFYkgJbrQU2RvkmVDEhzBTm0qf6DthzvnEzRXTkMPBvuIAZd6AMCKffzF-XKRWkkV9HTRc2Muu0rZEWkSsPqd_hEMxfrPCOhu2l8n9AVAZ4GrkWOC2_w
```

Save this as `ci-runner-kube-config`.

#### Step 3 - Switch to Service Account Context and Verify No Access to Namespace

```
kubectl --kubeconfig ci-runner-kube-config config use-context k8s-01-runner
kubectl --kubeconfig ci-runner-kube-config get pods
```
You will see a message indicating that the ci-runner service account does not have access.

#### Step 4 - Create ClusterRole and ClusterRoleBinding to Grant Access to Namespace

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
	name: ci-runner-role
rules:
- apiGroups: [""]
	resources: ["pods"]
	verbs: ["get", "list", "watch"]  
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
	name: ci-runner-role-binding
	namespace: default
roleRef:
	apiGroup: rbac.authorization.k8s.io
	kind: ClusterRole
	name: ci-runner-role
subjects:
- kind: ServiceAccount
	name: ci-runner
	namespace: default  
```

In this example __ci-runner__ has access to __get__,__list__ and __watch__ pods in the default namespace.

For a __CI/CD__ deployment your ACLs may look more like the following:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:	
	name: ci-runner-role
rules:
	- apiGroups: [""]
		resources: ["*"]
		verbs: ["*"]
```

Which grants full access to the service account namespace (in this case _default_).

#### Step 5 - Base64 the Service Account kube-config into a Gitlab CI/CD Secret

	cat ci-runner-kube-config | base64 | pbcopy

And paste it in the secrets stored in __Gitlab Project > Settings > CI/CD > Secret Variables__.

Then use the codeified kube-config to access the target Kubernetes cluster in Gitlab CI/CD:

```
deploy:
	stage: deploy
	image: lwolf/helm-kubectl-docker:v152_213
	before_script:
		- mkdir -p /etc/deploy
		- echo ${kube_config} | base64 -d > ${KUBECONFIG}
		- kubectl config use-context k8s-01
	script:
		- kubectl get pods -n kube-system
		- kubectl do some deployment stuff here
	only:
	- master
```

### Kubernetes Load Testing Sample Stack

A sample application stack has been included with cluster-builder that can be used to perform basic performance and load testing on deployed Kubernetes clusters.

It is comprised of a __MariaDB Galera Active/Active 3 or 5 Node Database Cluster__ paired with a __Drupal 7__ web front-end, which accesses the database through either a dedicated __HA Proxy__ (legacy mode), or via an internal native k8s load balanced service.

For guidance on generating the manifests for your __Cluster Builder__ cluster, deploying the stack, and performing load tests, see the [Drupal K8s Test Stack Guide](docs/drupal-k8s-test-stack.md).

There is also an experimental `ansible-playbook` that generates a standard __3 replica drupal cms + 3 node active/active mariadb galera database__ sample stack.  It generates all of the templates listed in the guide, and installs the stack as per a defined unified configuration file:

Eg. 'drupal-stack.conf'

```
[all:vars]
galera_cluster_name=k8s
galera_cluster_namespace=web
galera_cluster_docker_image=idstudios/mariadb-galera:10.3

galera_iscsi_storage_class=iscsi-targetd-vg-targetd

galera_cluster_volume_size=3Gi

galera_mysql_user=drupal
galera_mysql_password=Fender2000
galera_mysql_root_password=Fender2000
galera_mysql_database=drupaldb
galera_xtrabackup_password=Fender2000

drupal_stack_name=k8s
drupal_stack_namespace=web
drupal_docker_image=idstudios/drupal:plain

drupal_domain=drupal.onprem.idstudios.io

drupal_files_nfs_server=192.168.1.107
drupal_files_nfs_path="/idstudios-files-drupal-test"
drupal_files_volume_size=10Gi

drupal_db_host=k8s-galera-lb
drupal_db_name=drupaldb 
drupal_db_user=root 
drupal_db_password=Fender2000

[drupal_stack]
127.0.0.1
```

Store the `drupal-stack.conf` in the __cluster package folder__, and then execute the playbook from the root cluster-builder folder:

```
$ ansible-playbook -i clusters/<org>/<cluster>/drupal-stack.conf ansible/drupal-stack.yml
```

This will generate the template yaml files and install the stack.

> Note that this is based on a __MetalLB__ load balanced cluster and a configured __iscsi provisioner__, configured to use the default __Targetd Storage Appliance__ settings.  If this does not match your configuration you will need to manually adjust the manifests and execute them manually as per the guide.


### Helm Setup and KEDA

To install `helm` in the cluster, first apply the necessary `CRD` to give tiller the required permissions:

```
$ kubectl apply -f xtras/k8s/tiller-rbac.yml
```

Then download and install the `helm` binary locally, and run the `helm init` process.

Then patch the `tiller` deployment to use the provisioned __service account__:

```
bash xtras/k8s/tiller-patch
```

Now you should be able to use `helm` to install packages such as [KEDA](https://github.com/kedacore/keda).

To install __KEDA__, use the following:

```
 helm install kedacore/keda-edge --devel --set rbac.create=true --set logLevel=debug --namespace keda --name keda
```

> Note that this may also work `helm init --upgrade --service-account tiller`, TODO: explore a cleaner method for helm setup until they finally get rid of tiller. Eg.
``` 
kubectl --namespace kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller --upgrade
```

### Knative and Istio

Once inline to cluster-builder, _Istio_ and _Knative_ deployments have been moved into their own ansible playbooks to keep the cluster deployment clean.

Versions are specified using the following:

		k8s_knative_version= 0.3.0 | 0.4.0
		k8s_knative_install_monitoring= true | false

and 

		k8s_istio_version=1.0.1 | 1.0.2 | 1.0.4 | latest

__Defaults:__

		k8s_knative_version=0.3.0
		k8s_knative_install_monitoring=false
		k8s_istio_version=1.0.2

The playbooks can be executed:

```
$ ansible-playbook -i <path to cluster pkg folder>/hosts ansible/istio.yml
```

and/or

```
$ ansible-playbook -i <path to cluster pkg folder>/hosts ansible/knative.yml
```

> __Knative 0.3.0 and 0.4.0__ work best with __Istio 1.0.1 or 1.0.2__ at the present time.  Install __Istio__ first.

> Experience has called into question the value of _Knative_ for on-premise deployments.  While cost containment benefits of serverless are evident in the cloud pricing model, the overhead of complexity in requiring _Istio_ in support of _Knative_ tips the value proposition over.  Should _Knative_ be built into the platform in the future the merit of serverless may emerge, but at present, simple standard containerized services appear to nullify the value of serverless in on-premise deployments with orders of magnitude less complexity to manage at the cluster level.

### System Profile

A general overview of the highlights:

#### Docker Versions

__Docker CE:__ 17.12.1-ce (or later)

* centos-swarm
* rhel-swarm

__DC/OS__: 1.11 (or latest)

* centos-dcos

__Stock Kubernetes__: v1.13.x, v1.14.x, v1.15.x

* centos-k8s
* fedora-k8s

#### CentOS Based Clusters

* CentOS base VM image OVA template is based on the CentOS 7 Minimal 1708 iso and is  __1.1GB__, and contains one thinly provisioned SCSI based VMDK disk using __overlay2__, which is now supported on 1708 (CentOS/RHEL 7.4+).
* CentOS base VM image is a fully functioning and ready worker node.
* Default linux kernel is 3.10.x
* Use __packer centric__ approach for provisioning, VM OVA based nodes are ready to be added to swarms
* The __VMware Docker Volume Service__ Docker Volume Plugin has been pre-installed on all Swarm based cluster-builder VMs.
* Time synchronization of all the cluster nodes is done as part of the deployment process, and __chronyd__ or __ntpd__ services are configured and verified.
* Deployments can include configurable options for log shipping to ELK, using logstash.  
* Metrics are enabled (a configurable option), and cAdvisor/node-exporter options are available for deployment in support of Prometheus/Grafana monitoring for Docker Swarm.  Heapster provides metrics to the Kubernetes Dashboard, though additional metric capture platforms can be added as required.
* Remote API and TLS certificates are installed and configured on Docker CE deployments.

> Note that all details pertaining to the above exist within this codebase. The cluster-builder starts with the distribution iso file in the initial [node-packer](node-packer) phase, and everything from the initial __kickstart__ install through to the final __ansible playbook__ are documented within the _IaC_ codebase.
