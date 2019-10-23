NFS
===

cluster-builder contains the ability to automatically deploy the __NFS Client Provisioner__ by simply supplying following values in the cluster configuration hosts file:

k8s_nfs_external_server
k8s_nfs_external_path

This will generate the necessary YAML templates to install the provisioner during deployment.

However, it is also possible to install via the helm chart (once Helm is configured in your cluster):

https://github.com/kubernetes-incubator/external-storage/tree/master/nfs-client

If you would like to leverage the iSCSI storage of the Targetd Storage Appliance and would like to run the NFS server instance within Kubernetes, consider the NFS Server Provisioner:

https://github.com/helm/charts/tree/master/stable/nfs-server-provisioner

This will install and run a complete NFS server, which will use the specified Storage Class to provision the PVC/PV volumes.
