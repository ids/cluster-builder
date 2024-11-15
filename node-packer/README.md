# Cluster Builder Node Packer
Packer builds VMware cluster nodes for use by `cluster-builder`.

> Note: To save time you may want to seed the __iso__ folder with `Rocky-94-x86_64-minimal.iso`.

> Make sure to have an rsa key found in **~/.ssh/id_rsa.pub**.

## Building cluster-node.ova

```
./build
```

## Output
The builder creates `cluster-node-x86_64.ova` in the [output_ovas](./output_ovas/) folder.


> This script will be called by [cluster-deploy](../cluster-deploy) if the `ova` does not exist.

