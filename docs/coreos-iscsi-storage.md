CoreOS iSCSI Dynamic Storage and the Targetd Storage Appliance
==============================================================

The following diagram illustrates the approach to __persistent volume storage__ on CoreOS Kubernetes using iSCSI direct:

![CoreOS iSCSI Storage Strategy](images/coreos-iscsi-storage.png)

The diagram illustrates two types of storage:

1. Dynamic (for pre-production)
2. Static (for production)

__Dynamically__ provisioned volumes are accomplished using the [iscsi-provisioner](https://github.com/kubernetes-incubator/external-storage/tree/master/iscsi/targetd) developed by the folks at CoreOS.  In a pre-production environment the agility of dynamic provisioning is helpful in support of dynamic feature branch QA deployments.  Since it is pre-production, we are less concerned with __High Availability__ and so a single __Targetd Storage Appliance__ can fit the need.

__Statically__ provisioned volumes are pre-allocated iSCSI LUNs on an external production grade storage appliance.  In production, data must be cared for and managed for __High Availability__ and __Disaster Recovery__.  In this case, technology like the __Amazon Storage Gateway__ or direct Compellant allocated iSCSI LUNs are the best strategy.

By combining these two approaches we achieve a lightweight, minimalist and robust persistent volume strategy that is not subject to periodic breakage due to complex software interactions like ESXi Kernel module VIBS or 3rd party storage providers.

## The Targetd Storage Appliance

__cluster-builder__ supports the automated deployment of dedicated CoreOS Cluster Targetd storage appliances.  As depicted in the diagram above, these can be paired with CoreOS Clusters to provide controlled dynamic storage.

> The __Targetd Storage Appliance__ supports up to 255 persistent volumes per server instance.  If this is insufficient, multiple provisioners can be deployed with multiple targetd storage appliance backends in the same CoreOS cluster.

The default configuration of the appliance is a __1 TB thinly provisioned LVM volume on VMDK__.  This can be resized as needed but represents a solid initial storage footprint for a pre-production environment.

The [Targetd Host Configuration File](../examples/targetd-server/hosts) illustrates the settings required for deploying a targetd storage appliance (it should look familiar):

    [all:vars]
    cluster_type=targetd-server
    cluster_name=targetd
    remote_user=admin

    vmware_target=esxi
    overwrite_existing_vms=true

    esxi_net="VM Network"
    esxi_net_prefix=192.168.1

    network_mask=255.255.255.0
    network_gateway=192.168.1.1
    network_dns=8.8.8.8
    network_dns2=8.8.4.4
    network_dn=onprem.idstudios.io

    targetd_server=192.168.1.205
    targetd_server_iqn=iqn.2003-01.org.linux-iscsi.minishift:targetd
    targetd_server_volume_group=vg-targetd
    targetd_server_provisioner_name=iscsi-targetd
    targetd_server_account_credentials=targetd-account
    targetd_server_account_username=admin
    targetd_server_account_password=ciao
    targetd_server_namespace=default

    [targetd_server]
    storage-server ansible_host=192.168.1.205 esxi_host=esxi-6 esxi_user=root

    [vmware_vms]
    storage-server numvcpus=4 memsize=6144 esxi_host=esxi-6 esxi_user=root esxi_ds=datastore-ssd

__targetd_server__= The ip address of the targetd server (as per the anisble_host value)

__targetd_server_iqn__= A valid and unique [iSCSI IQN](https://en.wikipedia.org/wiki/ISCSI#Addressing)

__targetd_server_volume_group=__ vg-targetd is the default but can be modified.

__targetd_server_provisioner_name__= A unique name given to the iscsi provisioner

__targetd_server_account_credentials__= The name of the K8s secret that will store the targetd server credentials

__targetd_server_account_username__= The username for targetd RPC remote access (used by the provisioner)

__targetd_server_account_password__= The password for targetd RPC remote access (used by the provisioner)

__targetd_server_namespace__= This should be default, but may support additional namespaces with configuration

Once the __hosts__ file has been prepared, deployment uses the familiar __cluster-builder__ convention:

    bash cluster-deploy <targetd package folder>

Which should result in a deployed __Targetd Server Appliance__ with __1 TB__ of thinly provisioned LVM storage to be allocated dynamically as K8s __PVCs__ are requested.

## The iSCSI Provisioner and CoreOS iSCSI Configuration

Out of the box Tectonic CoreOS does not ship with iSCSI support fully enabled.  Enabling iSCSI is a relatively simple matter of mapping the correct utilities into the __kubelet__ service container.  An ansible playbook has been created to take care of this task.

Before beginning the CoreOS iSCSI configuration make sure to copy the __targetd__ configuration into the CoreOS cluster package hosts file:

    targetd_server=192.168.1.205
    targetd_server_iqn=iqn.2003-01.org.linux-iscsi.minishift:targetd
    targetd_server_volume_group=vg-targetd
    targetd_server_provisioner_name=iscsi-targetd
    targetd_server_account_credentials=targetd-account
    targetd_server_account_username=admin
    targetd_server_account_password=ciao
    targetd_server_namespace=default

These same settings will be used to create the corresponding __ISCSI provisioner manifests__ that will bind the provisioner to the __Targetd Storage Appliance__.

Once the CoreOS cluster has been deployed via the [PXE method](README_CoreOS.md) we need to prep CoreOS for ansible management.  This makes use of an __ansible-galaxy__ [module](https://coreos.com/blog/managing-coreos-with-ansible.html) to bootstrap CoreOS with a lightweight version of __python__ to enable ansible modules.

First we need to add the following section to our __CoreOS Cluster hosts file__:

    [coreos]
    core-01
    (list of all hosts...)

    [coreos:vars]
    ansible_ssh_user=core
    ansible_python_interpreter="PATH=/home/core/bin:$PATH python"

This will direct Ansible to use the correct python.  Then we need to fetch the module:

    ansible-galaxy install defunctzombie.coreos-bootstrap

And then execute a wrapper script to use the module against our CoreOS cluster to install __pypy__:

    ansible-playbook -i clusters/ids/core ansible/coreos-ansible.yml

After this completes successfully we can use __Ansible__ to manage our __CoreOS cluster nodes__.

With the __Targetd Storage Appliance configuration__ values in our __CoreOS Cluster configuration file__ we can run the __cluster-builder__ ansible script to configure CoreOS for iSCSI direct:

    ansible-playbook -i clusters/ids/core ansible/coreos-iscsi-setup.yml

> There is also an alternative `ansible-playbook -i clusters/ids/core ansible/coreos-iscsi-script.yml` that generates a raw bash script to accomplish the same configuration.  This is now deprecated but can still be used to correct or troubleshoot the ansible script based installation.

When the `coreos-iscsi-setup.yml` completes, there will be an __iscsi-manifests__ folder in your cluster package folder for the CoreOS cluster.

__At this stage you must setup your `kubectl` configuration before proceeding - ensure you can connect to your CoreOS cluster__

We will then install the iSCSI Provisioner:

    ./coreos-iscsi-secret.sh

This will create the secret credentials that the iSCSI provisioner will use to connect to the Targetd server.

    kubectl apply -f coreos-iscsi.yml

This will create the necessary roles, as well as install the __iscsi-provisioner__ deployment and the corresponding storage class.

    kubectl get sc

Will show the storage class.

    kubectl get pods

Will show the running iscsi-provisioner.  Check the logs and you should see something like this:

    time="2018-05-31T23:30:11Z" level=debug msg="start called"
    time="2018-05-31T23:30:11Z" level=debug msg="creating in cluster default kube client config"
    time="2018-05-31T23:30:11Z" level=debug msg="kube client config created" config-host="https://10.3.0.1:443"
    time="2018-05-31T23:30:11Z" level=debug msg="creating kube client set"
    time="2018-05-31T23:30:11Z" level=debug msg="kube client set created"
    time="2018-05-31T23:30:11Z" level=debug msg="targed URL http://admin:ciao@192.168.1.205:18700/targetrpc"
    time="2018-05-31T23:30:11Z" level=debug msg="iscsi provisioner created"

The iSCSI provisioner is now ready to deploy iSCSI PVC volumes:

        kind: PersistentVolumeClaim
        apiVersion: v1
        metadata:
            name: iscsi-test-volume
            annotations:
            volume.beta.kubernetes.io/storage-class: "iscsi-targetd-vg-targetd"
        spec:
            accessModes:
            - ReadWriteOnce
            resources:
            requests:
                storage: 1Gi

And you can run a benchmark test job on the Targetd iSCSI volumes:

        kubectl apply -f coreos-iscsi-benchmark.yml

> For better performance consider using Thickly provisioned VMware VMDK volumes.

Once your pod is running and you see the the PVCs are bound, your CoreOS cluster is ready to use dynamic iSCSI PVC provisioning and static iSCSI PVC storage.

Enjoy :)

## Extending the Targetd Storage Appliance

You can extend the __Targetd Storage Appliance__ by adding another virtual hard disk to the VM, and then provisioning it manually:

        sudo pvcreate /dev/sd_
        sudo vgcreate vg-targetd-thick /dev/sd_

Where `sd_` is the newly added volume.

Edit the `/etc/target/target.yaml` file to support the additional block volume:

password: ciao

        # defaults below; uncomment and edit
        # if using a thin pool, use <volume group name>/<thin pool name>
        # e.g vg-targetd/pool
        # Use the multi pool syntax to support multiple volumes:
        block_pools: [vg-targetd, vg-targetd-thick]
        # pool_name: vg-targetd
        user: admin
        ssl: false
        target_name: iqn.2003-01.org.linux-iscsi.minishift:targetd

Create a new storage class that uses the `vg-targetd-thick` pool (it is easiest to copy the one generated by cluster-builder as it contains the necessary initiator ids):

        kind: StorageClass
        apiVersion: storage.k8s.io/v1
        metadata:
        name: iscsi-targetd-vg-targetd-thick
        provisioner: iscsi-targetd
        parameters:
        # this id where the iscsi server is running
        targetPortal: 192.168.1.205:3260
        iqn: iqn.2003-01.org.linux-iscsi.minishift:targetd
        fsType: ext4
        volumeGroup: vg-targetd-thick

        # this is a comma separated list of initiators that will be give access to the created volumes, they must correspond to what you have configured in your nodes.
        initiators: iqn.2016-04.com.coreos.iscsi:1459208749854afebb99c5953e7b2c36,iqn.2016-04.com.coreos.iscsi:21dfca155e2940b69824a35fc98ab4be,iqn.2016-04.com.coreos.iscsi:b4c735d4d7f545d4907b966947218be5,iqn.2016-04.com.coreos.iscsi:3805f9ad51fc40aca73e57c6787dab2e,iqn.2016-04.com.coreos.iscsi:4df8a3d976494f56b0405f3a1edcbdb4,iqn.2016-04.com.coreos.iscsi:95a1744390d641fe93da94a35fde654c,iqn.2016-04.com.coreos.iscsi:39839a9f9d8d480a89107b13cbce9eb1,iqn.2016-04.com.coreos.iscsi:6938c01c1b274a40948380063255f274

        ---

And then reference that class when creating PVCs.