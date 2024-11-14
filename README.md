Cluster Builder
===============
> This project has been deprecated since 2020 and has likely fallen out of date.  A newer cloud based approach is starting up over at [cluster-builder-cloud](https://github.com/ids/cluster-builder-cloud), for those that like to play with `kubeadm`.

[Ansible](https://www.ansible.com/) and [Packer](https://www.packer.io) IaC() scripts to configure  [KubeAdm Stock Kubernetes](https://kubernetes.io/docs/setup/independent/) on [Rocky Linux 9](https://rockylinux.org)

## Usage Scenarios

- Deploy Kubernetes clusters locally to VMware Fusion or VMware Workstation
- Deploy Kubernetes clusters to ESXi servers directly

A simple `ansible hosts` file describes the size and shape of the cluster, and `cluster-builder` does all the rest!

### Requirements

#### macOS / Linux

* VMware Fusion Pro / Workstation Pro
* VMware ESXi 6.5+ (optional)
* VMware's [ovftool](https://my.vmware.com/web/vmware/details?productId=614&downloadGroup=OVFTOOL420) in $PATH
* Ansible `brew install/upgrade ansible`
* Hashicorp [Packer](https://www.packer.io/downloads.html)
* __kubectl__ (Kubernetes - `brew install/upgrade kubernetes-cli`)
* Docker Desktop for Mac or __docker-ce__ 
* Python3 and `pip3`
### Quick Start Steps

#### Local Workstation

1. Setup the VMware network.  The example uses `vmnet2` with a network of `192.168.42.0`.
2. Make sure all required software is installed and in the __PATH__:
	- `vmrun`
	- `ansible`
	- `ovftool`
3. Make sure you have your SSH key setup and that it exists as `~/.ssh/id_rsa.pub`.
4. Provision DNS entries
5. Follow the steps in the readme below to start deploying clusters!

#### ESXi/vSphere

1. Ensure you have one or more VMware ESXi hypervisors available.
2. Configure the ESXi hypervisors to support __passwordless SSH__, and the ansible host from which you deply is in the `authorized_keys`  (and make sure SSH is enabled for the ESXi hosts).
2. Make sure all required software is installed and in the __PATH__:
	- `vmrun`
	- `ansible`
	- `ovftool`
4. Make sure you have your SSH key setup and that it exists as `~/.ssh/id_rsa.pub`.
5. Provision DNS entries
6. Follow the steps in the readme below to start deploying clusters!

### Cluster Definition Packages

Everything is based on the **Ansible inventory file**, which defines the cluster specifications. These are defined in **hosts** files located in a folder given the cluster name:

Eg. In the **clusters/eg** folder there is:

```
demo-k8s
  |_ hosts
```

Sample cluster packages are located in the **clusters/eg** folder and can be copied into your own **clusters/org** folder and customized according to your infrastructure and networks.

Eg.

```
clusters
 |_ acme
  |_ demo-k8s
	 - hosts
```

The files are as follows:

```
[all:vars]
cluster_type=rocky9-k8s
cluster_name=k8s-vm
remote_user=admin

ansible_python_interpreter=/usr/bin/python3

vmware_target=fusion
desktop_vm_folder="../virtuals"

desktop_net="vmnet2"         # this should be vmnet8 for Windows and Linux
desktop_net_type="custom"    # this should be nat for Windows and Linux

network_mask=255.255.255.0
network_gateway=192.168.42.1
network_dns=8.8.8.8
network_dns2=8.8.4.4
network_dn=vm.idstudios.io

k8s_metallb_address_range=192.168.42.160-192.168.42.179

k8s_control_plane_uri=k8s-m1.vm.idstudios.io
k8s_ingress_url=k8s-ingress.vm.idstudios.io

[k8s_masters]
k8s-m1.vm.idstudios.io ansible_host=192.168.42.200 

[k8s_workers]
k8s-w1.vm.idstudios.io ansible_host=192.168.42.210
k8s-w2.vm.idstudios.io ansible_host=192.168.42.211

[vmware_vms]
k8s-m1.vm.idstudios.io numvcpus=4 memsize=2048
k8s-w1.vm.idstudios.io numvcpus=4 memsize=4096
k8s-w2.vm.idstudios.io numvcpus=4 memsize=4096

```

- The `cluster_type` is currently `rocky9-k8s`.
- `remote_user` is always `admin`, as this is configured in the packer build.
- `desktop_vm_folder` places the k8s VM files in `./virtuals` by default.
- `k8s_metallb_address_range` defines a set of address to for the `MetalLB`

Other settings are fairly self explanatory.

## Setup Notes - Important

- Make sure that all of the hosts in your `inventory hosts` file resolve.  Deployment requires the DNS names resolve.

- Make sure that `node-packer/build` is using the correct `authorized_key`.  This should happen automatically, but deployment relies on `passwordless ssh`.

## Deploying Clusters
The following command would deploy example cluster from above:

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

> The **demo** series of local deployments use DNS names hosted by __idstudios.io__, which resolve to local private network addresses.  These domain names can be used for local deployments if the same subnet/addressing is also used in your local environments.

### Controlling Cluster VM Nodes
There are ansible tasks that use the inventory files to execute VM control commands.  This is useful for __suspending__ or __restarting__ the entire cluster.  It also enables complete deletion of a cluster using the __destroy__ action directive.

Use **cluster-control**:

	bash cluster-control <inventory-package | cluster-name> <action: one of stop|suspend|start|destroy>

__Eg.__

	$ bash cluster-control eg/demo-k8s suspend
