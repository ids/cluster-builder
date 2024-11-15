---
title:  Cluster Builder
layout: default
---

##### Updated for 2024!

Using only freely available tools and only an annotated Ansible inventory file [cluster-builder](https://github.com/ids/cluster-builder) enables the configuration and deployment of Kubernetes clusters to vSphere/ESXi hypervisors and local VMware Workstation/Fusion Pro environments.

> One command... and the cluster is deployed!

<script id="asciicast-r6irOhfrbkTKvdo7SlVbGEyUL" src="https://asciinema.org/a/r6irOhfrbkTKvdo7SlVbGEyUL.js"  async data-autoplay="true" data-rows="41" data-theme="solarized-dark" data-size="small" data-speed="5"></script>

<script
  src="https://code.jquery.com/jquery-3.3.1.min.js"
  integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8="
  crossorigin="anonymous"></script>

[cluster-builder](https://github.com/ids/cluster-builder) uses [Packer](https://www.packer.io), [Ansible](https://www.ansible.com),  Bash and VMware tools to deploy [Kubernetes kubeadm clusters](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/) into VMware environments.  

[cluster-builder](https://github.com/ids/cluster-builder) has been updated for __2024__ with `Kubernetes 1.29` and `rocky9-k8s`, using `Rocky Linux 9.4` with:

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