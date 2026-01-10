---
title:  Cluster Builder
layout: default
---
Using freely available tools and only an annotated Ansible inventory file [cluster-builder](https://codeberg.org/idstudios/cluster-builder) enables the configuration and deployment of Kubernetes clusters to [Proxmox VE](https://www.proxmox.com/en/) or local `QEMU`.

> One command... and the cluster is deployed and re-deployed as needed. 

<script src="https://asciinema.org/a/EefvOquP3o4Tx91ectQIFnSJN.js" id="asciicast-EefvOquP3o4Tx91ectQIFnSJN" async data-autoplay="true" data-rows="50" data-theme="solarized-dark" data-size="small" data-speed="10" data-idle-time-limit="25"></script>

> Cluster-Builder has moved to [Codeberg](https://codeberg.org/idstudios/cluster-builder) You probably should too.

<script
  src="https://code.jquery.com/jquery-3.3.1.min.js"
  integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8="
  crossorigin="anonymous"></script>

[cluster-builder](https://codeberg.org/idstudios/cluster-builder) uses [Ansible](https://www.ansible.com) and Bash to deploy [Kubernetes kubeadm clusters](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/) to [Proxmox VE](https://www.proxmox.com/en/).  Ansible executes commands (plays) as a human operator might, making the entire cluster configuration process transparent and configurable. Easy to see what is happening, easy to diagnose problems.  Easy to customize.  Over the years __cluster-builder__ has been used to deploy __kubeadm k8s__ to __VSphere/VMWare ESXi__, __Virtual Box__, but those legacy platforms have been replaced with modern __Proxmox VE__ and __QEMU__ deployments.

__Kubernetes__ clusters are configured and deployed using only an __Ansible hosts__ file.  `Simple`. `cluster-builder` is designed to deploy the virtual machines and the Kubernetes for a complete one command solution.

> Deploying stable `kubeadm k8s` since `1.12`.

Recently updated with support for:

- [Proxmox VE](https://www.proxmox.com/en/) deployment of `Ubuntu 24.04 LTS Kubernetes 1.35`
- `QEMU` for multi-node local workstation clusters of `Ubuntu 24.04 LTS Kubernetes 1.35`.

Clusters currently include:

- [Canal](https://docs.tigera.io/calico/latest/getting-started/kubernetes/flannel/install-for-flannel) Networking & Policy
- [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
- [Flux CD Operator](https://fluxcd.control-plane.io/operator/)

Enabling all other package deployments via [Flux CD](fluxcd.io) and a _FluxInstance_.  See the [README](https://codeberg.org/idstudios/cluster-builder/README.md) for more details.

---
<div class="center" style="margin-left: -20px;">
<img style="width: 100px;box-shadow:none;margin-bottom:0px" src="/assets/images/cbLogo2-100.png" >
</div>
<div class="center" style="margin-left: -20px;">
<a id="try-cb-link" href="https://codeberg.org/idstudios/cluster-builder">Try Cluster Builder</a>
</div>
---
<style>

</style>