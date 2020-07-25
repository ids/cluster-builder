---
title:  Cluster Builder
---

With freely available tools and only an annotated Ansible inventory file [cluster-builder](https://github.com/ids/cluster-builder) enables the configuration and deployment of fleets of container orchestration cluster VMs to vSphere/ESXi hypervisors as well as VMware Workstation/Fusion Pro local environments.

> One command... and the cluster is deployed!

<script id="asciicast-r6irOhfrbkTKvdo7SlVbGEyUL" src="https://asciinema.org/a/r6irOhfrbkTKvdo7SlVbGEyUL.js"  async data-autoplay="true" data-rows="41" data-theme="solarized-dark" data-size="small" data-speed="5"></script>

<script
  src="https://code.jquery.com/jquery-3.3.1.min.js"
  integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8="
  crossorigin="anonymous"></script>

[cluster-builder](https://github.com/ids/cluster-builder) is a _Packer_, _Ansible_ and _Bash_ based infrastructure as codebase that can deploy _identical cluster VM images in both local development and production VMware environments_, supporting both  _development_ and _operational_ workflows. __DevOps__.  Clusters can be deployed and re-deployed locally, _and_ into production, identically, _in minutes!_

[cluster-builder](https://github.com/ids/cluster-builder) embraces minimalism wherever possible.  Simple, freely available tools.  Readable and fungible scripts.

[cluster-builder](https://github.com/ids/cluster-builder) follows an [immutable infrastructure](https://www.digitalocean.com/community/tutorials/what-is-immutable-infrastructure) philosophy at the cluster node level.  Container orchestration clusters are defined in a simple text file and then deployed using a single command.  Always repeatable and documented, this re-usable framework can deploy numerous and varied orchestration clusters with a clear separation of configuration and deployment artifacts.

[cluster-builder](https://github.com/ids/cluster-builder) is currently deploying the following __Kubernetes__ container orchestration clusters using __kubeadm__:

* `centos-k8s` - __CentOS 7.8__ VM nodes (baseline)
* `fedora-k8s` - __Fedora 31__ VM nodes (5.x kernel)  
* `ubuntu-k8s` - __Ubuntu 20.04 LTS__ VM nodes

[cluster-builder](https://github.com/ids/cluster-builder) can also deploy associated __Targetd Storage Appliance__ and __iSCSI Provisioners__ to provide backing persistent iSCSI block storage, and NFS shared file volume persistent storage for K8s clusters.  This is especially useful in pre-production cluster environments.

[cluster-builder](https://github.com/ids/cluster-builder) makes generic on-premise Kubernetes easy.  It is a single infrastructure codebase that can automatically deploy K8s and/or DC/OS container orchestration systems as production ready VMware VM clusters.  

[cluster-builder](https://github.com/ids/cluster-builder) unites _VMware_ and _Kubernetes_ using accessible, open technology delivering an on-premise _Hybrid Cloud_ service model. It's __fully open__, __forkable__ and __hackable__.  

_Why do things the hard way?_

---
<div class="center" style="margin-left: -20px;">
<img style="width: 100px;box-shadow:none;margin-bottom:0px" src="/assets/images/cbLogo2-100.png" >
</div>
<div class="center" style="margin-left: -20px;">
<a id="try-cb-link" href="https://github.com/ids/cluster-builder">Try Cluster Builder</a>
</div>
---
<style>

</style>