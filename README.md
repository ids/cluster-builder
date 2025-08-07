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
3. Make sure you have your SSH key setup and that it exists as `~/.ssh/id_rsa.pub`, as this will be built int the `Packer` node template as the `authorized_keys` for __passwordless SSH__ to the node
4. Provision DNS entries
5. Follow the steps in the readme below to start deploying clusters

#### Proxmox VE

1. Ensure you have one or more [Proxmox VE](https://www.proxmox.com/en/proxmox-virtual-environment/overview) hypervisors available
2. Configure the Proxmox Host(s) to support __passwordless SSH__, and the ansible host from which you deply is in the `authorized_keys`  (and make sure SSH is enabled for the ESXi hosts)
3. Provision DNS entries for each cluster node and ensure the resolve
4. Follow the steps in the readme below to start deploying clusters

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

metallb_address_range=192.168.42.160-192.168.42.179

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
- `metallb_address_range` defines a set of address to for the `MetalLB`

The following is an example of a `proxmox multi-host` deployment using __two__ Proxmox VE hosts joined to a `proxmox cluster` with no shared storage:

```

[all:vars]
cluster_type=proxmox-k8s
cluster_name=k8s-prox
remote_user=root

deploy_target=proxmox
build_template=false

network_cidr=24
network_gateway=192.168.2.1
network_dns=8.8.8.8
network_dns2=8.8.4.4
network_dn=lab.idstudios.io

metallb_address_range=192.168.2.220-192.168.2.235
k8s_control_plane_uri=k8s-m1.lab.idstudios.io
k8s_ingress_url=k8s-ingress.lab.idstudios.io

pod_readiness_timeout=600s
use_longhorn_storage=false

# could also be set at the node level
proxmox_user=root
proxmox_storage=vm-thinpool

[proxmox_hosts]
scs-1.lab.idstudios.io template_vmid=777 #ansible_ssh_user=root  
scs-2.lab.idstudios.io template_vmid=778 #ansible_ssh_user=root  

[k8s_masters]
k8s-m1.lab.idstudios.io vmid=1001 template_vmid=777 proxmox_host=scs-1.lab.idstudios.io ansible_host=192.168.2.101 numvcpus=2 memsize=4096 

[k8s_workers]
k8s-w1.lab.idstudios.io vmid=1002 template_vmid=778 proxmox_host=scs-2.lab.idstudios.io ansible_host=192.168.2.111 numvcpus=4 memsize=6128
k8s-w2.lab.idstudios.io vmid=1003 template_vmid=777 proxmox_host=scs-1.lab.idstudios.io ansible_host=192.168.2.112 numvcpus=4 memsize=6128

```
> Note that in the above example, each `proxmox host` in the `proxmox cluster` specifies a unique `template_vmid`, which is then also referenced by the nodes deployed on that host.

- The `template_vmid` can be set at the `proxmox_hosts` level.  If it differs per host, it should then align with the `node` level `proxmox_host` setting, such that when deployed to a `proxmox host`, the node will use the locally available template.  

Once a template has been built on the `proxmox` host, setting `build_template` to `false` will re-use the existing template, reduce downloads and speed up deployment.  This can be set on a per host basis.

- `proxmox_storage` can be used on the `proxmox_hosts` to specify where the template is stored, and at the `k8s` node level to specify where the VM will be stored.  It may also be set globally to place everything on the same disk/storage device.

- the `vmid` must be set at the `node` level, and should be unique within the `proxmox cluster`.

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

	bash cluster-control <inventory-spec | cluster-name> <action: one of stop|suspend|start|destroy>

__Eg.__

	$ bash cluster-control eg/demo-k8s suspend

## Adding Cluster VM Nodes
To add additional worker nodes:

1. Copy the `hosts` file in the cluster package folder to `hosts_add`.
2. Remove all existing hosts but leave the file intact.
3. Add new worker nodes in `[k8s_workers]`.
4. Run the `./cluster-addnodes <cluster package folder>` script.
5. This will deploy specified new node VMs ready to join the cluster.  When it completes, follow the instructions displayed on screen by connecting to a MASTER NODE and executing: 

`kubeadm token create --print-join-command`

6. Copy the command created.
7. SSH into the new node(s) and apply the JOIN COMMAND output in step #5.

Verify the new node(s) have joined the cluster.

__Note:__ make sure to copy added workers into the main `hosts` file, and delete the `hosts_add` when node has been created.

> As this simply creates a compatible VM, it can also be used to add additional `masters`.

## Extra Packages
The following packages can be included with the cluster deployment using the `install_package_xxx` directives, or can be added after deployment using the `install-package <cluster spec folder> <package name>` script.

Default settings for deployments are:

```
install_package_metallb		= true 
install_package_nginx		= true
install_package_dashboard	= true
install_packqge_longhorn	= false
```

These can be overriden in the `hosts` file and added after the fact using the `install-package` script.

### MetalLB
Can be controlled with the option `install_package_metallb=true | false`.

When `true`, the `hosts` file must also contain a list of addresses for the pool.

Eg.

```
metallb_address_range=192.168.2.220-192.168.2.235
```

If not specified, `metallb` will not be installed.

### NGINX
Can be controlled with the option `install_package_nginx=true | false`.

### Kubernetes Dashboard
Can be controlled with the option `install_package_dashboard=true | false`.

Launch the proxy:

`kubectl --kubeconfig <mycluster-kube-config>  -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443`

Browse to `https://localhost:8443`

Enter the token found in the cluster spec folder, or use the `dashboard-token.sh` script to retrieve it.

### Longhorn Storage
Can be controlled with the option `install_package_longhorn=true | false`.

Longhorn is a meaty deployment that appears to bump `CPU utilization` on the cluster by about `2%` (which is not bad), but for this reason it is off by default.

To include it in the cluster deployment add the following line to your cluster `hosts` file:

```
install_package_longhorn=true
```

### Flux Operator
Can be controlled with the option `install_package_flux | false`.

This will install the flux operator, enabling for declarative management of the flux instance:

To include it in the cluster deployment add the following line to your cluster `hosts` file:

```
install_package_flux=true
install_package_sealedsecrets=true
...

# recommend deploying all other packages via Flux, but keeping sealed-secrets a part of cluster-builder
# deployment to enable cluster recreation with the same externally managed sealed-secret cert

install_package_longhorn=false
install_package_metallb=false
install_package_nginx=false
install_package_dashboard=false

```

The sealed-secrets package is designed to work with the flux package to enable all other deployments to be flux driven

### Sealed Secrets
Can be controlled with the option `install_package_sealedsecrets | false`.

The `cluster-builder` sealed secrets deployment is designed to use pre-generated keys to enable cluster re-creation in concert with a `Flux CD` backend.

First, generate the necessary certificate:

```
export PRIVATEKEY="my-tls.key"
export PUBLICKEY="my-tls.crt"

openssl req -x509 -nodes -newkey rsa:4096 -keyout "$PRIVATEKEY" -out "$PUBLICKEY" -subj "/CN=sealed-secret/O=sealed-secret"
```

Copy the keys somewhere safe, for this example: `~/Keys`.

Then to include `sealed-secrets` in the cluster deployment add the following configuration to your cluster `hosts` file:

```
install_package_sealedsecrets=true
sealedsecrets_ns=sealed-secrets
sealedsecrets_cert_folder=~/Keys
sealedsecrets_cert_file=my-tls.crt
sealedsecrets_key_file=my-tls.key
```

Create a test secret:
```
kubectl create secret generic secret-name --dry-run=client --from-literal=foo=bar -o yaml | kubeseal --controller-name=sealed-secrets-controller --controller-namespace=sealed-secrets -o yaml --cert=$PUBLICKEY | kubectl apply -f -
```

Verify:
```
kubectl logs sealed-secrets-controller -n sealed-secrets
```