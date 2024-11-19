Cluster Builder
===============

[Ansible](https://www.ansible.com/) scripts to configure  [KubeAdm Stock Kubernetes](https://kubernetes.io/docs/setup/independent/) with:

- [Canal](https://docs.tigera.io/calico/latest/getting-started/kubernetes/flannel/install-for-flannel) Networking & Policy
- [MetalLB](https://metallb.universe.tf) Load Balancer
- [Longhorn](https://longhorn.io/) PV Storage
- [NGINX](https://github.com/kubernetes/ingress-nginx) Ingress
- [Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)

> Updated for 2024! 

> Many of the tips and how-to articles I used came from ex-VMware pros who migrated their home labs to [Proxmox VE](https://www.proxmox.com/en/) after Broadcom decided to kill ESXi and anyone's interest in it. The good news is that `Proxmox` is __a big step up__, in so many ways.  Migrating to the `kvm hypervisor` also meant tossing out `Packer` in favor of `cloud-init`, which offers a much more cloud centric deployment model, and has greatly simplified the codebase. With the `proxmox` deployment, everything happens on the `proxmox hosts`, including the node template build.  The proxmox CLI is simple and effective, and creating the necessary plays took only a few days.  

[Proxmox VE](https://www.proxmox.com/en/) feels like a private cloud, and no one misses ESXi.  

## Usage Scenarios

- Deploy [Rocky Linux 9](https://rockylinux.org) Kubernetes clusters on VMware Fusion/Desktop
- Deploy [Ubuntu 24.04 LTS](https://ubuntu.com/blog/tag/ubuntu-24-04-lts) Kubernetes clusters on [Proxmox VE](https://www.proxmox.com/en/)

A simple `ansible hosts` file describes the size and shape of the cluster, and `cluster-builder` does the rest.

### Requirements

#### macOS / Linux

For __VMware Fusion/Desktop__ local workstation deployment:

* VMware Fusion Pro / Workstation Pro 
* VMware's [ovftool](https://my.vmware.com/web/vmware/details?productId=614&downloadGroup=OVFTOOL420) in $PATH 
* Ansible `brew install/upgrade ansible`
* Hashicorp [Packer](https://www.packer.io/downloads.html) 
* __kubectl__ (Kubernetes - `brew install/upgrade kubernetes-cli`)
* Docker Desktop for Mac or __docker-ce__ 
* Python3 and `pip3`

For __Proxmox VE__ remote deployment:

* Proxmox VE Host(s)
* Ansible `brew install/upgrade ansible`
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

#### Proxmox VE

1. Ensure you have one or more [Proxmox VE](https://www.proxmox.com/en/proxmox-virtual-environment/overview) hypervisors available.
2. Configure the Proxmox Host(s) to support __passwordless SSH__, and the ansible host from which you deply is in the `authorized_keys`  (and make sure SSH is enabled for the ESXi hosts).
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

The following is an example of a `VMware fusion` deployment:

```
[all:vars]
cluster_type=rocky9-k8s
cluster_name=k8s-vm
remote_user=admin

ansible_python_interpreter=/usr/bin/python3

deploy_target=fusion
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
- `deploy_target` is either `fusion`, `workstation` (windows), or `proxmox`
- The `cluster_type` is currently `rocky9-k8s` or `proxmox-k8s` which is Ubuntu 24.04 LTS.
- `remote_user` is `admin` locally, or `root` for `proxmox`.
- `desktop_vm_folder` places the k8s VM files in `./virtuals` by default.
- `k8s_metallb_address_range` defines a set of address to for the `MetalLB`

This is an example of a `proxmox` deployment:

```

[all:vars]
cluster_type=proxmox-k8s
cluster_name=k8s-prox
remote_user=root

ansible_python_interpreter=/usr/bin/python3

deploy_target=proxmox
build_template=false

network_mask=255.255.255.0
network_gateway=192.168.1.1
network_dns=8.8.8.8
network_dns2=8.8.4.4
network_dn=home.idstudios.io

k8s_metallb_address_range=192.168.1.7-192.168.1.10

k8s_control_plane_uri=k8s-m1.home.idstudios.io
k8s_ingress_url=k8s-ingress.home.idstudios.io

pod_readiness_timeout=600s
use_longhorn_storage=false

# could also be set at the node level
proxmox_user=root
proxmox_host=192.168.1.167

template_vmid=777

[proxmox_hosts]
192.168.1.167 ansible_ssh_user=root #template_vmid=?

[k8s_masters]
k8s-m1.home.idstudios.io vmid=1001 ansible_host=192.168.1.11 numvcpus=2 memsize=4096 #template_vmid=? proxmox_host=?

[k8s_workers]
k8s-w1.home.idstudios.io vmid=1002 ansible_host=192.168.1.14 numvcpus=4 memsize=6128
k8s-w2.home.idstudios.io vmid=1003 ansible_host=192.168.1.15 numvcpus=4 memsize=6128

```
Once a template has been built on `proxmox`, setting `build_template` to `false` will re-use the existing template, reduce downloads and speed up deployment.

- The `template_vmid` can be set at the `proxmox_hosts` level if there is more then one.  It should then align with the `node` level `proxmox_host` setting, such that when deployed to a `proxmox host`, the node will use the locally available template.  Proxmox `template ids` must be unique across hosts (but this has not yet been tested and verified).

- the `vmid` must be set at the `node` level, and it must be unique within the proxmox cluster.

Other settings are fairly self explanatory.

## Setup Notes - Important

- Make sure that all of the hosts in your `inventory hosts` file resolve.  Deployment requires the DNS names resolve.

- Make sure that `node-packer/build` is using the correct `authorized_key`.  This should happen automatically, but deployment relies on `passwordless ssh`.

- Watch out for `dockerhub` __rate limits__ if you are doing a lot of deployments, and consider using a `VPN`.

- When using `proxmox` deployment, ensure all `promox hosts` have been configured for `passwordless ssh`.

- Proxmox template builds, and vm deployment progress can be viewed in the Proxmox GUI, as they tend to take a long time with no feedback to ansible.

## Deploying Clusters
The following command would deploy example cluster from above:

```
$ bash cluster-deploy acme/demo-k8s
```

When the cluster is deployed a message will be displayed, such as:

```
------------------------------------------------------------
SUCCESS: VMware Fusion Rocky 9.4 Kubernetes!
Deployed in: 10 min 7 sec
------------------------------------------------------------

The kube-config file can be found at clusters/acme/demo-k8s/kube-config

kubectl --kubeconfig=clusters/acme/demo-k8s/kube-config get pods --all-namespaces

To connect to the Kubernetes Dashboard:

kubectl --kubeconfig=clusters/acme/demo-k8s/kube-config proxy

Then open:
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

Enjoy your Rocky 9.4 Kubernetes!

------------------------------------------------------------

```

At this point your cluster is up and running.

__Longhorn__ can take some time, depending on your network connection, but eventually it will settle and:

```
 kubectl --kubeconfig=clusters/acme/demo-k8s/kube-config get pods --all-namespaces
```

Should result in:

```
NAMESPACE              NAME                                                    READY   STATUS      RESTARTS        AGE
ingress-nginx          ingress-nginx-admission-create-tg7md                    0/1     Completed   0               12m
ingress-nginx          ingress-nginx-admission-patch-99lt9                     0/1     Completed   0               12m
ingress-nginx          ingress-nginx-controller-7f9bbf6ddd-jtgcl               1/1     Running     0               12m
kube-system            calico-kube-controllers-8d95b6db8-jz4tj                 1/1     Running     1 (2m47s ago)   16m
kube-system            canal-4mhlf                                             2/2     Running     0               15m
kube-system            canal-6zgk5                                             2/2     Running     0               16m
kube-system            canal-zptbs                                             2/2     Running     0               15m
kube-system            coredns-76f75df574-8mdng                                1/1     Running     0               16m
kube-system            coredns-76f75df574-rgh2n                                1/1     Running     1 (2m47s ago)   16m
kube-system            etcd-k8s-m1.vm.idstudios.io                             1/1     Running     0               16m
kube-system            kube-apiserver-k8s-m1.vm.idstudios.io                   1/1     Running     0               16m
kube-system            kube-controller-manager-k8s-m1.vm.idstudios.io          1/1     Running     1 (2m47s ago)   16m
kube-system            kube-proxy-bpv9x                                        1/1     Running     0               15m
kube-system            kube-proxy-kqtkc                                        1/1     Running     0               15m
kube-system            kube-proxy-l7qbf                                        1/1     Running     0               16m
kube-system            kube-scheduler-k8s-m1.vm.idstudios.io                   1/1     Running     1 (2m47s ago)   16m
kubernetes-dashboard   kubernetes-dashboard-api-67c5cffbb6-xs7dz               1/1     Running     0               12m
kubernetes-dashboard   kubernetes-dashboard-auth-cf8c45468-4lglm               1/1     Running     0               12m
kubernetes-dashboard   kubernetes-dashboard-kong-75bb76dd5f-vns4v              1/1     Running     0               12m
kubernetes-dashboard   kubernetes-dashboard-metrics-scraper-5f645f778c-6pk46   1/1     Running     0               12m
kubernetes-dashboard   kubernetes-dashboard-web-5bf7668478-52h5t               1/1     Running     0               12m
longhorn-system        csi-attacher-7966f6d44c-jj5j5                           1/1     Running     5 (4m35s ago)   9m33s
longhorn-system        csi-attacher-7966f6d44c-qxq4q                           1/1     Running     5 (2m52s ago)   9m33s
longhorn-system        csi-attacher-7966f6d44c-rwxtj                           1/1     Running     4 (5m34s ago)   9m33s
longhorn-system        csi-provisioner-c79d98559-8q4l4                         1/1     Running     5 (4m22s ago)   9m33s
longhorn-system        csi-provisioner-c79d98559-l2hvl                         1/1     Running     4 (2m52s ago)   9m33s
longhorn-system        csi-provisioner-c79d98559-sh4pv                         1/1     Running     5 (4m12s ago)   9m33s
longhorn-system        csi-resizer-5885f7bb5f-7m4w2                            1/1     Running     5 (2m52s ago)   9m33s
longhorn-system        csi-resizer-5885f7bb5f-tm794                            1/1     Running     2 (3m28s ago)   9m33s
longhorn-system        csi-resizer-5885f7bb5f-wkjgt                            1/1     Running     2 (3m32s ago)   9m33s
longhorn-system        csi-snapshotter-54946f7f44-vdvcn                        1/1     Running     5 (3m57s ago)   9m33s
longhorn-system        csi-snapshotter-54946f7f44-wdwqb                        1/1     Running     4 (2m48s ago)   9m33s
longhorn-system        csi-snapshotter-54946f7f44-xbkx9                        1/1     Running     5 (3m47s ago)   9m33s
longhorn-system        engine-image-ei-51cc7b9c-4f2g9                          1/1     Running     0               10m
longhorn-system        engine-image-ei-51cc7b9c-xp94x                          1/1     Running     0               10m
longhorn-system        instance-manager-7abf2155155ca9be5d4067b024cc0aaa       1/1     Running     0               9m44s
longhorn-system        instance-manager-b6af5be1cdfb875481def9f9657ab159       1/1     Running     0               9m44s
longhorn-system        longhorn-csi-plugin-k75b8                               3/3     Running     1 (7m19s ago)   9m33s
longhorn-system        longhorn-csi-plugin-ls6wm                               3/3     Running     1 (7m12s ago)   9m33s
longhorn-system        longhorn-driver-deployer-799445c664-tsjjl               1/1     Running     0               12m
longhorn-system        longhorn-manager-gjplc                                  2/2     Running     0               12m
longhorn-system        longhorn-manager-qnmhw                                  2/2     Running     0               12m
longhorn-system        longhorn-ui-757d79dd7f-b8xdw                            1/1     Running     0               12m
longhorn-system        longhorn-ui-757d79dd7f-qv5g9                            1/1     Running     0               12m
metallb-system         controller-77676c78d9-5qfhj                             1/1     Running     0               13m
metallb-system         speaker-f2cq2                                           1/1     Running     1 (2m47s ago)   13m
metallb-system         speaker-j6675                                           1/1     Running     0               13m
metallb-system         speaker-kwt6r                                           1/1     Running     0               13m
```

### Controlling Cluster VM Nodes
There are ansible tasks that use the inventory files to execute VM control commands.  This is useful for __suspending__ or __restarting__ the entire cluster.  It also enables complete deletion of a cluster using the __destroy__ action directive.

Use **cluster-control**:

	bash cluster-control <inventory-package | cluster-name> <action: one of stop|suspend|start|destroy>

__Eg.__

	$ bash cluster-control eg/demo-k8s suspend

## Kubernetes Dashboard

`kubectl --kubeconfig <mycluster-kube-config> proxy`

http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/


## Longhorn Storage

Longhorn is a meaty deployment that uses a fair portion of cluster resources, and for this reason is optional, and off by default.
To include it in the cluster deployment add the following line to your cluster `hosts` file:

```
use_longhorn=true
```

An updated `targetd` solution is in the works.
