Release Notes
=============

v17.12-beta1
------------

> __Note__ that this release requires all Packer output OVA VM images to be rebuilt due to signifcant changes in the ova profile.

* Migrated to a __Packer centric__ node provisioning approach moving most of the ansible logic from post OVA provisioning into the packer OVA creation process.  This includes the monitoring agents and underlying plugin dependencies. This results in a __ready-to-go__ node OVA that can be deployed into service simply by:
  * Assigning a static IP
  * Assigning a hostname (and DNS entries)
  * Joining a Swarm
* The __Packer centric__ approach favors a model where OVAs are versioned along with deployments for reliable recovery (TODO: future releases should build this into the model explicitly). It should also enable the creation of simple "add node to cluster" scripts for easily expanding existing cluster deployments.
* Updated the CentOS variant to use __Overlay2__ (supported on 1708/7.4).  This simplifies the CentOS/RHEL images eliminating the need for a dedicated 2nd VMDK and the rather cumbersome __direct-lvm__ approach
* Updated the CentOS variant to __Docker 17.12.0-ce__, with explicit versioning
* Added __ovftool_parallel=true__ option to speed up ESXI ovftool deployments
* Added __docker_swarm_mgmt_cn__ and __docker_swarm_mgmt_gw__ to allow external DNS names to be used in the advanced deployment model (where access is through a load balancer external to the cluster)
* Added the __cluster-passwd__ high level script for managing cluster admin/root user passwords and integrated this into the deployment process
* Cleaned up the CE based Swarm Secure API implementation and migrated __dockerd__ settings to standardize on __daemon.json__ configuration
* Changed the designation of target node for __prometheus__ from an ansible group definition of **[docker_prometheus_server]** to a simple variable of __docker_prometheus_server=servername__
* Underlying metric support from __dockerd__, __cAdvisor__ and __Node Exporter__ has been built into the OVA and is no longer optional (docker_enable_metrics is now deprecated - any need to upgrade or adjust these components can be considered a post-deployment activity - considering moving the entire monitoring system to an independent stack deployment)
* Added support for separate __Control__ and __Data__ interface swarm deployments where each node has 2 NICS on separate subnets, partitioned accordingly.
* Enabled ELK Logging via __logstash__ and __gelf__.  When the __docker_elk_target__ variable is set, logstash containers are distributed via service mode=global, and the __Docker daemon.json__ is configured for __gelf__ logging to the local logstash instance.
* Added __"dns"__ entry to __Docker daemon.json__ based on the __data_network_dns__ and __network_dns__ respectively.  The first two DNS entries will be entered into the __Docker daemon.json__ to support DNS name resolution in containers.
* Cleaned up the base CentOS OVA and moved DC/OS specific items into post-ova ansible deployment 
* __FIXED__: issue with cAdvisor not being accessible to prometheus when prometheus is running on the node.  All targets now show as __UP__ immediately after deployment.
* Updated the __PhotonOS Swarm__ variant to __Docker 17.12.0-ce__ and migrated to a __Packer centric__ approach.
* __Atomic Swarm__ !Deprecated, what is the point?  I fought with rpm-ostree enough just trying to get it to stay on __their antiquated idea of docker-latest as 1.13__, and it kept reverting back to 1.12... and I think I've had enough.  __Docker 1.13__ in 2018 is of no use to anyone.
