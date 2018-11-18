Release Notes
=============

v18.12
------

* Initial implementation of cluster deployment to local machines on Windows and Linux VMware Workstation hosts.
* Removed advanced swarm deployment model with seperate control and data plane configuration as this approach will not be carried forward.
* Removed PhotonOS related artifacts as PhotonOS is no longer relevant due to VMware's misstep with PKS.  Proof that better technology does not always trump legacy enterprise software politics.
* Removed UCP/Docker EE related artifacts as Docker EE is no longer supported, and not likely to have a future.
* Cleaned up the code base and pruned out artifacts no longer required or relevant.
* Initial packer build of candidate Windows2016 node in preparation for Windows 2019 Kubernetes networking support.
* Verified and tested __DC/OS 1.11__ deployment locally on Windows and macOS. _Linux mileage may vary for some reason still under investigation_.
* Verified and tested __Docker CE Swarm__ on CentOS deployment locally on Windows, Linux and macOS.
* __Most importantly__, verified and tested __CentOS 7.5 Vanilla Kubernetes 1.12__ deployment locally on Windows, Linux and macOS.  A solid up to date reference Kubernetes.

v18.09
------

* Updated `kubeadm` custom built Kubernetes variants for __CentOS 7.5__ and __Fedora 28__ for Kubernetes 1.12 and updated the configuration format and Canal networking manifests.  Also removed the explicit `etcd` install in the scripts as `kubeadm` now handles creation of the KV store.
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
