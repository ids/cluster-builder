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

k8s_control_plane_uri=k8s-m1.vm.idstudios.io
k8s_ingress_url=k8s-ingress.vm.idstudios.io

metallb_address_range=192.168.42.160-192.168.42.179

# These are legacy ansible install directives

install_package_longhorn=false
install_package_metallb=false
install_package_nginx=false
install_package_dashboard=false

# This sets up the cluster for Flux CD GitOps using external keys

install_package_flux=true
install_package_sealedsecrets=true

sealedsecrets_ns=sealed-secrets
sealedsecrets_cert_folder=/path/to/keys
sealedsecrets_cert_file=acme-tls.crt
sealedsecrets_key_file=acme-tls.key

[k8s_masters]
k8s-m1.vm.acme.io ansible_host=192.168.42.200 

[k8s_workers]
k8s-w1.vm.acme.io ansible_host=192.168.42.210
k8s-w2.vm.acme.io ansible_host=192.168.42.211

[vmware_vms]
k8s-m1.vm.acme.io numvcpus=4 memsize=2048
k8s-w1.vm.acme.io numvcpus=4 memsize=4096
k8s-w2.vm.acme.io numvcpus=4 memsize=4096

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

# These are legacy ansible install directives

install_package_longhorn=false
install_package_metallb=false
install_package_nginx=false
install_package_dashboard=false

# This sets up the cluster for Flux CD GitOps using external keys

install_package_flux=true
install_package_sealedsecrets=true

sealedsecrets_ns=sealed-secrets
sealedsecrets_cert_folder=/path/to/keys
sealedsecrets_cert_file=acme-tls.crt
sealedsecrets_key_file=acme-tls.key

pod_readiness_timeout=600s

# could also be set at the node level
proxmox_user=root
proxmox_storage=vm-thinpool

[proxmox_hosts]
scs-1.lab.acme.io template_vmid=777 #ansible_ssh_user=root  
scs-2.lab.acme.io template_vmid=778 #ansible_ssh_user=root  

[k8s_masters]
k8s-m1.lab.acme.io vmid=1001 template_vmid=777 proxmox_host=scs-1.lab.acme.io ansible_host=192.168.2.101 numvcpus=2 memsize=4096 

[k8s_workers]
k8s-w1.lab.acme.io vmid=1002 template_vmid=778 proxmox_host=scs-2.lab.acme.io ansible_host=192.168.2.111 numvcpus=4 memsize=6128
k8s-w2.lab.acme.io vmid=1003 template_vmid=777 proxmox_host=scs-1.lab.acme.io ansible_host=192.168.2.112 numvcpus=4 memsize=6128

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

## GitOps and Flux
The recommended approach for cluster building is to bypass the legacy install packages and setup a base cluster with:

- The [Flux Operator](https://fluxcd.control-plane.io/operator/)
- [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) using an external keypair

With these components in place, it is possible to `kubectl apply -f` a _FluxInstance_ and have the entire cluster profile reconciled using [Flux CD GitOps](fluxcd.io).  These are the configurations shown in the example `hosts` files above.

> It is important to use an external keypair with Sealed Secrets so that clusters can be re-created and used with the same GitOps repo.  It also supports the management of multiple clusters from the same GitOps repo.

### Generate the Keypair

```
export PRIVATEKEY="acme-tls.key"
export PUBLICKEY="acme-tls.crt"

openssl req -x509 -nodes -newkey rsa:4096 -keyout "$PRIVATEKEY" -out "$PUBLICKEY" -subj "/CN=sealed-secret/O=sealed-secret"
```

Copy the keypair to a safe place and then reference it in the `hosts` configuration:

```
sealedsecrets_ns=sealed-secrets
sealedsecrets_cert_folder=/path/to/keys
sealedsecrets_cert_file=acme-tls.crt
sealedsecrets_key_file=acme-tls.key
```

This sets the sealed-secrets target namespace to sealed-secrets, and uses the pre-generated keys for encrypting secrets (and decrypting them within the cluster).

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

The kubeconfig file can be found at clusters/acme/demo-k8s/kubeconfig

kubectl --kubeconfig=clusters/acme/demo-k8s/kubeconfig get pods --all-namespaces

To connect to the Kubernetes Dashboard:

kubectl --kubeconfig=clusters/acme/demo-k8s/kubeconfig proxy

Then open:
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

Enjoy your Rocky 9.4 Kubernetes!

------------------------------------------------------------

```

At this point your cluster is up and running.

__Longhorn__ can take some time, depending on your network connection, but eventually it will settle and:

```
 kubectl --kubeconfig=clusters/acme/demo-k8s/kubeconfig get pods --all-namespaces
```

Should result in:

```
NAMESPACE        NAME                                           READY   STATUS              RESTARTS   AGE
flux-system      flux-operator-5dff77b8b4-4ggfg                 1/1     Running             0          10m
kube-system      calico-kube-controllers-576865d959-p55pk       1/1     Running             0          11m
kube-system      canal-9mlwm                                    2/2     Running             0          11m
kube-system      canal-mzrpg                                    2/2     Running             0          10m
kube-system      canal-p2nnn                                    2/2     Running             0          10m
kube-system      canal-ptjkj                                    2/2     Running             0          10m
kube-system      coredns-674b8bbfcf-r2gdd                       1/1     Running             0          11m
kube-system      coredns-674b8bbfcf-wjtkm                       1/1     Running             0          11m
kube-system      etcd-kb-m1                                     1/1     Running             0          11m
kube-system      kube-apiserver-kb-m1                           1/1     Running             0          11m
kube-system      kube-controller-manager-kb-m1                  1/1     Running             0          11m
kube-system      kube-proxy-2ksqg                               1/1     Running             0          11m
kube-system      kube-proxy-bsbfs                               1/1     Running             0          10m
kube-system      kube-proxy-pb722                               1/1     Running             0          10m
kube-system      kube-proxy-rpr86                               1/1     Running             0          10m
kube-system      kube-scheduler-kb-m1                           1/1     Running             0          11m
sealed-secrets   sealed-secrets-controller-859768467-r5fzj      1/1     Running             0          5m11s
```

> At this point it is a good idea to merge the cluster package `kubeconfig` into your main `~/.kube/config`, or however you manage `k8s` context.

### Completing the GitOps Deployment
Once the base cluster has been deployed and all pods are up and running, the flux instance can be deployed.  This involves a few setup steps:

1. Ensure a supported Flux Operator repository exists with the credentials to access it, in the example we use a fork of [cluster-builder-flux-template]() in Github, and a Github App to grant Flux the permissions to access it.
2. Ensure the [flux](https://fluxcd.io) tool is installed.  On `macOS` this is `brew install flux`.
3. Create and deploy a manifest for the _FluxInstance_, along with a secret storing the Github App credentials for accessing the GitOps repo

#### Create Github App
In the Github account, create a new Github App.  Note the `App ID`.  Create a private access key for the application, this will download a `pem` file.  Store this securely with other secrets.

Once the app has been created, install it into the account.  Select to restrict the access only to the forked [cluster-builder-flux-template](https://github.com/ids/cluster-builder-flux-template) repo. After the Github App is installed, there will be a `Configure` button.  Selecting this button will review the `App Instance ID` in the url to configure.  Note this value.

#### Create FluxInstance Manifest and Secret

```
apiVersion: fluxcd.controlplane.io/v1
kind: FluxInstance
metadata:
  name: flux
  namespace: flux-system
spec:
  distribution:
    version: "2.x"
    registry: "ghcr.io/fluxcd"
  components:
    - source-controller
    - kustomize-controller
    - helm-controller
    - notification-controller
    - image-reflector-controller
    - image-automation-controller
  sync:
    interval: 3m
    kind: GitRepository
    provider: github
    url: "https://github.com/<your account>/<gitops repo | forked cluster-builder-flux-template>.git"
    ref: "refs/heads/main"
    path: "cluster/baseline" 
    pullSecret: "flux-system"
```
`kubectl apply -f` the manifest and create the secret with the Github App credentials:

```
flux create secret githubapp flux-system \
  --app-id=<App ID from above> \
  --app-installation-id=< App Instance ID from above> \
  --app-private-key=../../certs/<downloaded access key file>.pem
```

This will install the specified instance of [Flux](https://fluxcd.io) and boostrap the cluster using the supplied GitOps repo.

##### View Flux Logs
```
flux logs
```
##### Reconcile Flux Repo
```
flux reconcile source git flux-system
```
##### Check Flux Kustomizations
```
flux get kustomizations
``` 
##### Check Flux HelmReleases
```
flux get helmreleases
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

## Legacy Ansible Install Packages
The following packages can be included with the cluster deployment using the `install_package_xxx` directives, or can be added after deployment using the `install-package <cluster spec folder> <package name>` script.

> This approach is deprecated in favor of a Flux CD GitOps model.

Default settings for deployments are:

```
install_package_metallb		= false 
install_package_nginx		= false
install_package_dashboard	= false
install_packqge_longhorn	= false

install_package_flux			= true
install_package_sealedsecrets	= false

sealedsecrets_version = 2.6.x
```

These can be overriden in the `hosts` file and added after the fact using the `install-package` script.

Package versions can be set with `<pkg name>_version=<value>`.  See the [ansible config play](./ansible/roles/config/tasks/main.yml) for details on default values.

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

`kubectl --kubeconfig <mycluster-kubeconfig>  -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443`

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
Can be controlled with the option `install_package_flux | true`.

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

Copy the keys to a safe place, for this example: `~/Keys`.

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