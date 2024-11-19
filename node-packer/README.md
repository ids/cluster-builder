# Cluster Builder Node Packer

> Proxmox doesn't use packer at all, so this section is only useful for VMware desktop builds.  For Proxmox there are ansible scripts that will build the node template on the Proxmox host(s) directly using `cloud-init`, very much in the style of a cloud provider.  A lot cleaner then the `ova` template model.

Packer builds VMware cluster nodes for use by `cluster-builder`.

## Important Setup

- Make sure to download the  `Rocky-94-x86_64-minimal.iso` and place it in the __iso__ folder.
- Make sure to have an rsa key found in **~/.ssh/id_rsa.pub** that can be used for __authorized_keys__.

## Building cluster-node.ova

```
./build
```

## Output
The builder creates `cluster-node-x86_64.ova` in the [output_ovas](./output_ovas/) folder.

> This script will be called by [cluster-deploy](../cluster-deploy) if the `ova` does not exist.

