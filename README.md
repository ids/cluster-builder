Cluster Builder
===============

[Ansible](https://www.ansible.com/) and [Packer](https://www.packer.io) IaC() scripts to configure  [KubeAdm Stock Kubernetes](https://kubernetes.io/docs/setup/independent/) on [Rocky Linux 9]()

## Usage Scenarios

- Deploy locally to VMware Fusion or VMware Workstation
- Deploy to ESXi servers directly

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

## Deploying Clusters
The following command would deploy the cluster:

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

> The **demo** series of local deployments use DNS names hosted by __idstudios.io__, which resolve to local private network addresses.  These domain names can be used for local deployments if the subnet/addressing is also used in your local environments.

### Controlling Cluster VM Nodes
There are ansible tasks that use the inventory files to execute VM control commands.  This is useful for __suspending__ or __restarting__ the entire cluster.  It also enables complete deletion of a cluster using the __destroy__ action directive.

Use **cluster-control**:

	bash cluster-control <inventory-package | cluster-name> <action: one of stop|suspend|start|destroy>

__Eg.__

	$ bash cluster-control eg/demo-k8s suspend
