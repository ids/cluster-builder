---
title:  Cluster Builder
layout: default
---

##### Updated for 2025!

Using freely available tools and only an annotated Ansible inventory file [cluster-builder](https://github.com/ids/cluster-builder) enables the configuration and deployment of Kubernetes clusters to [Proxmox VE](https://www.proxmox.com/en/) KVM hypervisors and local legacy VMware Fusion environments.

> One command... and the cluster is deployed and re-deployed as needed. 

<script src="https://asciinema.org/a/EefvOquP3o4Tx91ectQIFnSJN.js" id="asciicast-EefvOquP3o4Tx91ectQIFnSJN" async data-autoplay="true" data-rows="50" data-theme="solarized-dark" data-size="small" data-speed="10" data-idle-time-limit="25"></script>

<script
  src="https://code.jquery.com/jquery-3.3.1.min.js"
  integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8="
  crossorigin="anonymous"></script>

[cluster-builder](https://github.com/ids/cluster-builder) uses [Ansible](https://www.ansible.com) and Bash to deploy [Kubernetes kubeadm clusters](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/) to [Proxmox VE](https://www.proxmox.com/en/).  Ansible executes commands (plays) as a human operator might, making the entire cluster configuration process transparent and configurable. Easy to see what is happening, easy to diagnose problems.  Easy to customize.  Over the years `cluster-builder` has been used to deploy `kubadm k8s` to VSphere/VMWare ESXi, Virtual Box and now Proxmox VE.  

Deploying stable `kubeadm k8s` since `1.12`.

Updated for __2025__ with:

- [Proxmox VE](https://www.proxmox.com/en/) deployment of `Ubuntu 24.04 LTS Kubernetes 1.33`
- VMware Fusion/Desktop deployment of `Rocky Linux 9.4 Kubernetes 1.33`
- VMware ESXi is _long_ gone.
- The [Flux CD Operator](https://fluxcd.control-plane.io/operator/) and [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) packages have been added to support GitOps clusters.

Clusters may also optionally include:

- [Canal](https://docs.tigera.io/calico/latest/getting-started/kubernetes/flannel/install-for-flannel) Networking & Policy
- [MetalLB](https://metallb.universe.tf) Load Balancer
- [Longhorn](https://longhorn.io/) PV Storage
- [Nginx Ingress](https://github.com/kubernetes/ingress-nginx) Ingress
- [Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
- [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
- [Flux CD Operator](https://fluxcd.control-plane.io/operator/)

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