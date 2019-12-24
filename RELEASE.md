Release Notes
=============

v19.12
------

* Added support for Kubernetes __1.17__
* Updated defaults, including updating the default cluster version to __1.15__.
* Upgraded __CentOS7__ nodes to __1908__.

v19.11
------

* Added __Ubuntu 18.04 LTS__ variant of `kubeadm k8s` as `ubuntu-k8s`
* Added the `cluster-update` command.  Although still experimental - this command updates Kubernetes clusters in place (minor _and_ major release upgrades and underlying OS security patching). See the [README](https://github.com/ids/cluster-builder#updating-a-cluster) for more details.
* Verified HA Kubernetes __1.13__ through __1.16__ for:
  * `centos-k8s`
  * `fedora-k8s`
  * `ubuntu-k8s`
* Cleaned up Ansible output with `ANSIBLE_DISPLAY_SKIPPED_HOSTS=True`

v19.10
------

* Updated to __Fedora 30__.
* Added secrets encryption to all Kubernetes clusters.
* Added __Kubeflow__ setup scripts in __xtras__.  
* Validated __Calico__ CNI as a working option to __Canal__ (the default).
* Aligned component versions for __NGINX__ and __Canal__ from __1.12__ to __1.16__.

_Experimental_

* Added initial scaffold for __CentOS 8__, but thus far no luck installing `kubeadm k8s`, still hung up on the CNI.
* Added initial scaffold for the __CRI-O__ runtime as alternative to __containerd__, but with no stable version yet.


v19.09
------

* Added initial support for __Kubernetes 1.16__.
* Upgraded __NGINX__ to __0.25__.
* Introduced __Kubernetes Dashboard 2.0__ and __Metrics Server__ into the __1.15 and 1.16__ cluster deployments.
* Re-introduce __Kubernetes 1.12.x__ series as this is the current stable GKE version (who knew Google's GCP would trail their own releases so many versions)
* Removed __Docker Swarm__ provisioning; a deprecated, never-was orchestration system.
* Standardize toolset on _Python3_ and _pip3_.
* Removed _Python2_ dependency on _CentOS7_ nodes.

> In preparation for the deprecation of _Python2_, please rebuild your _CentOS_ ova templates, and ensure that `ansible_python_interpreter=/usr/bin/python3` in all your __centos-k8s__ hosts files going forward.  

* Renamed all `fusion_` parameters to `desktop_` parameters as they apply to both __VMware Fusion__ and __VMware Workstation__ desktop products.

> Make sure to update all locally deployed cluster `hosts` files accordingly as the following parameters have changed for desktop deployment:

__Old__
```
vmware_target=fusion
fusion_vm_folder="../virtuals"

fusion_net="vmnet2"         # this should be vmnet8 for Windows and Linux
fusion_net_type="custom"    # this should be nat for Windows and Linux
```

__New__
```
vmware_target=desktop
desktop_vm_folder="../virtuals"

desktop_net="vmnet2"         # this should be vmnet8 for Windows and Linux
desktop_net_type="custom"    # this should be nat for Windows and Linux
```

v19.07
------

* Created configuration template and verified __CentOS/Fedora Kubernetes 1.15__.
* Updated __Canal__ to version __3.8__.
* Updated to `docker-ce` stable on _Fedora 29_.
* Removed _Python2_ dependency on _Fedora 29_ nodes.

> In preparation for the deprecation of _Python2_, please rebuild your _Fedora_ nodes, and ensure that `ansible_python_interpreter=/usr/bin/python3` in all your __fedora-k8s__ hosts files going forward.  In the future this will be the default.

* Removed deprecations and tested with __Packer 1.4.5__.
* New __xtras__:
  * Working __EFK__ stack in __xtras/k8s/elastic__ will automatically aggregate new container logs, along with base node metrics, using the targetd storage class.
  * Basic Kafka manifests and a port of the Lenses dev box in __xtras/k8s/kafka__ that also uses the targetd storage class.
  * Tiller RBAC patch to enable Helm installation, to enable [KEDA](https://github.com/kedacore/keda) installation.
  

v19.04
------

* Updated and verified __CentOS Kubernetes 1.14__.
* Tested and validated multi-master HA configuration for __1.13/1.14__ on __centos-k8s__ and __fedora_k8s__ deployments. HA deployments are now fully supported by __cluster-builder__.
* Removed support for __1.12__ as this is now approaching EOL.
* Removed __calico-policy__ until a working version can be completed.
* Moved custom __Istio__  and __Knative__ deployments into standalone ansible playbooks to reduce the complexity and dependency matrix in cluster deployment. __Knative__ now installs the required __Istio__ dependency.
* __Fedora 29 1.13 and 1.14__ stable on the __5.x__ kernel series.
* __CentOS 7.6__ __DC/OS 1.12__ and __Docker Swarm CE 17.12.1__ updated with fixes for deprecated ansible modules.
* Added durability and retry logic to mitigate `vmrun` instability issues on macOS with Fusion 11+.
* Added __kube-config__ and __web-ui-token__ instructions to the __cluster-deploy__ output for _Kubernetes_ deployments.

v19.03
------

> Please rebuild all OVA template images.

* Added durability and retry logic to many of the ansible deployment tasks, and replaced several hard VM restarts with soft.
* Pruned OVA templates, with numerous fixes, re-instating firmware for increased disk stability in vmware.
* Script cleanup, numerous fixes in stability of ESXi deployment.
* Working __fedora-k8s 1.13.4__ cluster wih __Knative 0.30__.  Surprisingly stable for _fedora_ and the __4.20__ kernel is a bit less dated.
* Added __protected=true|false__ option to cluster hosts file that guards against __cluster-control destroy__ or __cluster-deploy__ re-deployment to prevent accidental destruction of a deployed cluster.

v19.02
------

* Streamlined the ESXi deployment scripts by reducing the arbitrary wait times and improving unattended execution performance.
* Fixed latest stable defaults for __CentOS 7__ `kubeadm` Kubernetes:
  * __CentOS 7.6 1810__ w/ updates
  * Kubernetes - __v1.13.4__
  * Canal CNI w/ Network Policy - __v3.5__
  * MetalLB Native Load Balancer - __v0.73__
  * NGINX Ingress Controller - __v0.21__
  * Knative Serverless Platform - __v0.3.0__
* Updated examples and readme to reflect new stable formula.
* Added experimental __Kafka__ manifests in `xtras`
* Set base `node-packer` __CentOS__ ova to use base distro docker version by default, as this is preferred by __k8s__ and __DC/OS__.
* Removed last remnants of Tectonic CoreOS and updated documentation accordingly.
* Added __CentOS__ kernel parameter tuning for network performance on nodes.

v18.12
------

* Initial implementation of cluster deployment to local machines on __Windows and Linux VMware Workstation hosts__.  Windows can now deploy to both rvSphere/ESXi and local VMware Workstation environments.  Windows is now a first class cluster builder!
* Verified and tested __DC/OS 1.11__ local deployment on Windows and macOS. _Linux mileage may vary for some reason still under investigation_.
* Verified and tested __Docker CE Swarm__ on CentOS deployment locally on Windows, Linux and macOS.
* Verified and tested __CentOS 7.5 Vanilla Kubernetes 1.12__ deployment __locally on Windows, Linux and macOS__.  A solid up to date reference Kubernetes.  Early support for __1.13__.
* Updated all `CentOS 7` clusters from __7.5 (1804)__ to __7.6 (1810)__.  Rebuild __ova template__ images to upgrade.
* Integrated [MetalLB](https://metallb.universe.tf/) into the __Vanilla Kubernetes__ configuration.
* Added support for __Calico CNI Plugin w/ Istio and Network Policy__ for both __CentOS 7.5__ and __Fedora 29__. __k8s_network__cni__ allows selection of __canal__ (default), __calico__ and __calico-policy__ (whcih includes Istio and Network Policy).  Load tested and validated _Network Policy_ functionality on `centos-k8s` with __calico-policy__.  However, testing of __canal__ and __metal-lb__ shows a performance delta as compared to _Calico_ so as to make the overhead of _Istio_ a consideration.  Likely not worth it unless you plan on using _Istio_, and even then...
* Changed default ingress controller on `kubeadm` clusters to `nginx`, and added setting for selecting: __k8s_ingress_controller__ is one of __nginx__ (default), __traefik-nodeport__, __traefik-daemonset__ and __traefik-deployment__.
* Completed and tested initial packer build of candidate Windows 2016 node in preparation for Windows 2019 Kubernetes networking support.
* Bugs in __Fusion vmrun__ appear to be fixed in _11.02_ release and Fusion 11.02 has been tested with Packer 1.3.2, with applicable fixes applied.
* Removed advanced swarm deployment model with seperate control and data plane configuration as this approach will not be carried forward.
* Removed PhotonOS related artifacts as PhotonOS is no longer relevant due to VMware's misstep with PKS.  Proof that better technology does not always trump legacy enterprise software politics.
* Removed UCP/Docker EE related artifacts as Docker EE is no longer supported, and not likely to have a future.
* Cleaned up the code base and pruned out artifacts no longer required or relevant.

> With support now on Windows and Linux workstations, ESXi deployment should work as expected on all platforms, however the [cluster-builder-control](https://github.com/ids/cluster-builder-control) station is still recommended. _Also known conceptually as a bastion server or jump box. This is no longer limited to the CentOS version supplied and can, in fact, be a Windows based jump box_.

v18.09
------

* Updated `kubeadm` custom built Kubernetes variants for __CentOS 7.5__ and __Fedora 29__ for Kubernetes 1.12 and updated the configuration format and Canal networking manifests.  Also removed the explicit `etcd` install in the scripts as `kubeadm` now handles creation of the KV store.
* Fixed `kubeadm` Kubernetes deployments to `1.12.1`.
* Added `coreDNS` patch to increase available memory and correct the CrashLoopBackoff [issue mentioned here](https://github.com/kubernetes/kubeadm/issues/1037).
* Verified and tested __DC/OS__.
* Verified and tested __Docker Swarm__ on CentOS.
* PhotonOS is now deprecated and no longer supported.

v18.06
------

> An _OVA rebuild_ is recommended with this release due to performance optimizations introduced in the Packer phase kickstart files.

* Included custom built Kubernetes variants for __CentOS 7.5__ and __Fedora 28__, using `kubeadm`, and implementing Canal CNI for network policy and the iSCSI provisioner for persistent storage.
* Updated CentOS7 to 7.5 (1804).
* Added `coreos-ansible.yml` wrapper script for bootstrapping CoreOS with `PyPy` to enable __Ansible__ management of CoreOS nodes.
* Initial implementation of __Ansible__ based CoreOS __iSCSI__ configuration playbook.
* Initial implementation of __Targetd Storage Appliance__ VM with dynamic iSCSI provisioning and an integrated __iscsi-provisioner__ __Tectonic CoreOS__ configuration.
* Fixes in support of Ansible 2.5.
* Implemented recommendations for `elevator=deadline` in all CentOS7/RHEL and CoreOS VMs as per the [Redhat documentation](https://access.redhat.com/solutions/5427).  Kickstart files for RHEL based VMs and the `coreos-init.yml` ansible playbook for optimizing CoreOS post PXE deployment after the `coreos-ansible.yml` install playbook.
* Tested with __VMware Fusion Pro 10 for Mac__.
* Tested with __VMware Workstation Pro 14 for Linux__ on the cluster control station appliance.
* Updated and validated __Tectonic CoreOS__ install for __1.9.6-tectonic.1__.
* Validated installation of __DC/OS 1.11__, still no changes required to cluster-builder after 4 version upgrades.
* Fully automated the CoreOS PXE deployment process, including the `coreos-init.yml` and __iscsi-provisioner__ deployment.
* Included __static ip assignment__ into the post deployment `coreos-init.yml` configuration to remove dependency on the __coreos provisioner__ for runtime operation of the clusters.  It is now only needed temporarily during new cluster deployment.
* The `coreos-init.yml` script has been tuned so it can be properly re-applied, in support of node additions, recovery, etc.
* Fixed a bug in the grep logic for VM ID derrivation that caused conflicts with subset names.
* Included the ability to trigger __coreos provisioner__ Matchbox CoreOS version image downloads by specifying `coreos_linux_version` and `coreos_linux_channel` in the Ansible hosts file.
* Integrated the __MariaDB Galera/Drupal7 Load Testing Stack__ into the core __cluster-builder__ codebase to enable regular load testing and performance validation of deployed clusters.

v18.04
------

* Fixed default volume layout for CentOS/RHEL.  Customized allocation so that **/var** now has a dedicated 180GB volume, **/** is allocated 40GB, **/boot** 1GB and **/tmp** 10GB.  **Note** that Nodes remain thinly provisioned.
* Increase system wide file descriptor limit via `fs.file-max = 100000` and adjusted __/etc/security/limits.conf__ to raise service level limits to 65536.
* Ensured that **/etc/hosts** on the nodes can be correctly populated with FQDN host names.

v18.04-beta4
------------

* Added wrappers for optional DNS entries in nic configuration
* Updated and validated __Tectonic CoreOS__ install for __1.8.9-tectonic.1__.
* More README and documentation cleanup.

v18.04-beta3
------------

* Added additional documentation for iSCSI configuration for __Tectonic CoreOS__.
* Cleaned up READMEs and documentation.


v18.04-beta2
------------

* Added __cluster-update__ functionality for applying rolling updates to __CentOS7__ and __RHEL__ __Docker Swarm__ cluster nodes (in support of regular patching).
* Pinned Docker engine version on __CentOS7__ and __RHEL__ CE to __Docker 17.09.1-ce__.
* Added support for __Tectonic CoreOS__ with [documentation](docs/README_CoreOS.md)

> Tectonic is a late addition but moving into the top spot quickly - it has the polish and stability of DC/OS, with the momentum of Kubernetes.  If you have a Docker Swarm headache (as I do), this is the cure.

v18.04-beta1
------------

> __Note__ that this release requires all Packer output OVA VM images to be rebuilt due to significant changes in the ova profile.

* ~~Updated the CentOS to __Docker 17.12.0-ce__, with explicit versioning.~~
* Already downgraded back to __Docker 17.09.1-ce__, as this issue appeared almost immediately in the swarm: https://github.com/docker/libnetwork/issues/2045.  Likely a better policy to skip Docker's .0 releases.
* Migrated to a __Packer centric__ node provisioning approach moving most of the ansible logic from post OVA provisioning into the packer OVA creation process.  This includes the monitoring agents and underlying plugin dependencies. This results in a __ready-to-go__ node OVA that can be deployed into service simply by:
  * Assigning a static IP
  * Assigning a hostname (and DNS entries)
  * Joining a Swarm
* The __Packer centric__ approach favors a model where OVAs are versioned along with deployments for reliable recovery (TODO: future releases should build this into the model explicitly). It should also enable the creation of simple "add node to cluster" scripts for easily expanding existing cluster deployments.
* Updated the CentOS variant to use __Overlay2__ (supported on 1708/7.4).  This simplifies the CentOS/RHEL images eliminating the need for a dedicated 2nd VMDK and the rather cumbersome __direct-lvm__ approach
* Added __ovftool_parallel=true__ option to speed up ESXI ovftool deployments
* Added __docker_swarm_mgmt_cn__ and __docker_swarm_mgmt_gw__ to allow external DNS names to be used in the advanced deployment model (where access is through a load balancer external to the cluster)
* Added the __cluster-passwd__ high level script for managing cluster admin/root user passwords and integrated this into the deployment process
* Cleaned up the CE based Swarm Secure API implementation and migrated __dockerd__ settings to standardize on __daemon.json__ configuration
* Changed the designation of target node for __prometheus__ from an ansible group definition of **[docker_prometheus_server]** to a simple variable of __docker_prometheus_server=servername__
* Underlying metric support from __dockerd__, __cAdvisor__ and __Node Exporter__ has been built into the OVA and is no longer optional (docker_enable_metrics is now deprecated - any need to upgrade or adjust these components can be considered a post-deployment activity - considering moving the entire monitoring system to an independent stack deployment)
* Added support for separate __Control__ and __Data__ interface swarm deployments where each node has 2 NICS on separate subnets, partitioned accordingly.
* Enabled ELK Logging via __logstash__ and __gelf__.  When the __docker_elk_target__ variable is set, logstash containers are distributed via service mode=global, and the __Docker daemon.json__ is configured for __gelf__ logging to the local logstash instance.
* Added __"dns"__ entry to __Docker daemon.json__ based on the data_network_dns and network_dns respectively.  The first two DNS entries will be entered into the __Docker daemon.json__ to support DNS name resolution in containers.  If a custom dns entry is desired for the Docker daemon.json , the "docker_daemon_dns_override" variable can be used.
* Cleaned up the base CentOS OVA and moved DC/OS specific items into post-ova ansible deployment 
* __FIXED__: issue with cAdvisor not being accessible to prometheus when prometheus is running on the node.  All targets now show as __UP__ immediately after deployment.
* __Atomic Swarm__ !Deprecated, what is the point?  I fought with rpm-ostree enough just trying to get it to stay on __their antiquated idea of docker-latest as 1.13__, and it kept reverting back to 1.12... and I think I've had enough.  __Docker 1.13__ in 2018 is of no use to anyone.
