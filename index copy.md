---
title:  Cluster Builder
layout: default
---

##### Updated for 2025!

Using freely available tools and only an annotated Ansible inventory file [cluster-builder](https://github.com/ids/cluster-builder) enables the configuration and deployment of Kubernetes clusters to [Proxmox VE kvm](https://www.proxmox.com/en/) hypervisors and local legacy VMware Fusion environments.

> One command... and the cluster is deployed!

<script id="asciicast-r6irOhfrbkTKvdo7SlVbGEyUL" src="https://asciinema.org/a/r6irOhfrbkTKvdo7SlVbGEyUL.js"  async data-autoplay="true" data-rows="41" data-theme="solarized-dark" data-size="small" data-speed="5"></script>

<script
  src="https://code.jquery.com/jquery-3.3.1.min.js"
  integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8="
  crossorigin="anonymous"></script>

[cluster-builder](https://github.com/ids/cluster-builder) uses primarily [Ansible](https://www.ansible.com) and Bash (and sometimes [Packer](https://www.packer.io)) to deploy [Kubernetes kubeadm clusters](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/) into [Proxmox VE](https://www.proxmox.com/en/) and VMware desktop environments.  

[cluster-builder](https://github.com/ids/cluster-builder) has been updated for __2024__ with:

- [Proxmox VE](https://www.proxmox.com/en/) `Ubuntu 24.04 LTS Kubernetes 1.30`
- VMware Fusion/Desktop `Rocky Linux 9.4 Kubernetes 1.30`
- VMware ESXi is gone.

[cluster-builder](https://github.com/ids/cluster-builder) clusters include:
- [Canal](https://docs.tigera.io/calico/latest/getting-started/kubernetes/flannel/install-for-flannel) Networking & Policy
- [MetalLB](https://metallb.universe.tf) Load Balancer
- [Longhorn](https://longhorn.io/) PV Storage
- [NGINX](https://github.com/kubernetes/ingress-nginx) Ingress
- [Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)


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