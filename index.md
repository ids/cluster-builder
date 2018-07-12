---
title:  cluster-builder
---

##### Automating the Creation of Container Orchestration Clusters in VMware Environments

---

Using freely available tools and only an annotated Ansible inventory file [cluster-builder](https://github.com/ids/cluster-builder) enables the configuration and deployment of fleets of VMware VMs to ESXi and Fusion hypervisors.

---

###### Auto-Magic: One Command... Cluster Deployed!

<script src="https://asciinema.org/a/h32J527aKzUHHedqDA6KlQn0F.js" id="asciicast-h32J527aKzUHHedqDA6KlQn0F" async data-autoplay="true" data-size="small" data-speed="10"></script>

__cluster-builder__ is a unique toolset in that it can deploy _the identical cluster VM images from production_ to local VMware Fusion development workstations.  This enables both advanced local stack development, as well as meta orchestration cluster development, accelerating all development workflows.  Clusters can be deployed and re-deployed locally _in minutes!_

__cluster-builder__ follows an [immutable infrastructure](https://www.digitalocean.com/community/tutorials/what-is-immutable-infrastructure) philosophy even at the cluster node level.  Container orchestration clusters are defined in a simple text file and then deployed using a single command.  Always repeatable and documented, this single re-usable toolset can deploy numerous and varied orchestration clusters with a clear separation of configuration and deployment artifacts, while offering a mechanism for managing the various cluster definitions packages.

---


