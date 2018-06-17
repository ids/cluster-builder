Kubernetes iSCSI Dynamic Storage and the Targetd Storage Appliance
==================================================================

The following diagram illustrates the approach to __persistent volume storage__ on  Kubernetes using iSCSI direct:

![Kubernetes iSCSI Storage Strategy](images/coreos-iscsi-storage.png)

The diagram illustrates two types of persistent volume storage:

1. __Dynamic__ (for pre-production)
2. __Static__ (for production)

__Dynamically__ provisioned volumes are accomplished using the [iscsi-provisioner](https://github.com/kubernetes-incubator/external-storage/tree/master/iscsi/targetd).  In a pre-production environment the agility of dynamic provisioning is helpful in support of dynamic feature branch QA deployments.  Since it is pre-production, we are less concerned with __High Availability__ and so a single __Targetd Storage Appliance__ can fit the need.

__Statically__ provisioned volumes are pre-allocated iSCSI LUNs on an external production grade storage appliance.  In production, data must be cared for and managed for __High Availability__ and __Disaster Recovery__.  In this case, technology like the __Amazon Storage Gateway__ or direct Compellant allocated iSCSI LUNs are the best strategy.

By combining these two approaches we achieve a lightweight, minimalist and robust persistent volume strategy that is not subject to periodic breakage due to complex software interactions like ESXi Kernel module VIBS or 3rd party storage providers.

## The Targetd Storage Appliance

__cluster-builder__ supports the automated deployment of dedicated Kubernetes Cluster Targetd storage appliances.  As depicted in the diagram above, these can be paired with Kubernetes Clusters to provide controlled dynamic storage.

> The __Targetd Storage Appliance__ supports up to 255 persistent volumes per server instance.  If this is insufficient, multiple provisioners can be deployed with multiple targetd storage appliance backends in the same Kubernetes cluster.

The default configuration of the appliance is a __1 TB thinly provisioned LVM volume on VMDK__.  This can be resized as needed but represents a solid initial storage footprint for a pre-production environment.

The [Targetd Host Configuration File](../clusters/eg/targetd-server/hosts) illustrates the settings required for deploying a targetd storage appliance (it should look familiar):

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
    storage-server numvcpus=4 memsize=6144 esxi_host=esxi-6 esxi_user=root esxi_ds=datastore6-ssd

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

> __Note__ that the iSCSI configuration has been bundled into the deployment process and should happen automatically.  It can be manually re-applied via `coreos-init.yml` at any point, but should already be configured.  You can also re-run the playbooks below at any point to regenerate the artifacts.

Once the CoreOS cluster has been deployed via the [PXE method](README_CoreOS.md) we need to prep CoreOS for ansible management.  This makes use of an __ansible-galaxy__ [module](https://coreos.com/blog/managing-coreos-with-ansible.html) to bootstrap CoreOS with a lightweight version of __python__ to enable ansible modules.

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

        kubectl apply -f coreos-iscsi-bench-pvc.yml
        (wait 10 secs)
        kubectl get pvc
        kubectl get pv
        kubectl apply -f coreos-iscsi-bench-job.yml

> For better performance consider using Thickly provisioned VMware VMDK volumes.

Once your pod is running and you see the the PVCs are bound, your CoreOS cluster is ready to use dynamic iSCSI PVC provisioning and static iSCSI PVC storage.

Enjoy :)

## Viewing the Targetd PVC Volumes

On the __Targetd Storage Appliance__ you can view the allocated volumes using the `targetcli ls` command (as root).

![Targetd targetcli ls example](images/targetcli-ls-example.png)

In the example screenshot we can see four `pvc-` volumes allocated in the `vg-targetd` volume group.  These map directly to  provisioned Kubernetes persistent volumes (PV) and persistent volume claims (PVC):

```
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM                                     STORAGECLASS               REASON    AGE
core-drupal-files-volume                   10Gi       RWX            Retain           Bound     web/core-drupal-files-volume-claim                                             2d
ghost-files-volume                         5Gi        RWO            Retain           Bound     idstudios/ghost-files-volume-claim                                             2d
mysql-main-iscsi-volume                    10Gi       RWO            Retain           Bound     idstudios/mysql-main-iscsi-volume-claim                                        2d
pvc-f67ca813-65de-11e8-bcca-000c298174b4   3Gi        RWO            Delete           Bound     web/core-galera-seed-volume-claim         iscsi-targetd-vg-targetd             2d
pvc-f67f1d81-65de-11e8-bcca-000c298174b4   3Gi        RWO            Delete           Bound     web/core-galera-node1-volume-claim        iscsi-targetd-vg-targetd             2d
pvc-f681c73f-65de-11e8-bcca-000c298174b4   3Gi        RWO            Delete           Bound     web/core-galera-node2-volume-claim        iscsi-targetd-vg-targetd             2d
pvc-f6842a73-65de-11e8-bcca-000c298174b4   3Gi        RWO            Delete           Bound     web/core-galera-node3-volume-claim        iscsi-targetd-vg-targetd             2d
```

If we launch our benchmarking utility job, we will see an `iscsi-benchmark-volume-claim` created with a corresponding PV, which will map to a dynamically allocated `pvc-` volume we can verify with `targetcli ls`.

        kubectl apply -f coreos-iscsi-bench.yml

And

        kubectl get pvc

Will show a PVC of:

```
NAME                                  STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS               AGE
iscsi-benchmark-target-volume-claim   Bound     pvc-f09f473d-6809-11e8-97f1-000c298174b4   3Gi        RWO            iscsi-targetd-vg-targetd   5s
```

With a corresponding PV of (`kubectl get pv`):

```
pvc-f09f473d-6809-11e8-97f1-000c298174b4   3Gi        RWO            Delete           Bound     default/iscsi-benchmark-target-volume-claim   iscsi-targetd-vg-targetd             1m
```

Note the name of the volume: __pvc-f09f473d-6809-11e8-97f1-000c298174b4__.  We see it has been allocated 3Gi, and using `targetcli ls` on the __Targetd Storage Appliance__, we can verify it has in fact been allocated (2nd from the top):

![Targetd pvc volume allocated](images/targetd-volume-allocated.png)

Going back to the __benchmark job__ we launched, we can check the job (`kubectl get jobs`) and view the logs:

```
IDStudios Cluster Toolbox
-------------------------
mode: disk-bench

Performing dd performance test on target volume /target...
-----
WRITE (1st pass bs=1G count=1):
1+0 records in
1+0 records out
1073741824 bytes (1.1 GB) copied, 4.75949 s, 226 MB/s
WRITE (2nd pass):
1+0 records in
1+0 records out
1073741824 bytes (1.1 GB) copied, 4.98027 s, 216 MB/s
WRITE (1st pass bs=1M count=1024):
1024+0 records in
1024+0 records out
1073741824 bytes (1.1 GB) copied, 14.2731 s, 75.2 MB/s
WRITE (1st pass bs=1k count=10240):
10240+0 records in
10240+0 records out
10485760 bytes (10 MB) copied, 89.5945 s, 117 kB/s
READ (1st pass bs=1M):
10+0 records in
10+0 records out
10485760 bytes (10 MB) copied, 0.00142444 s, 7.4 GB/s
READ (2nd pass bs=1M):
10+0 records in
10+0 records out
10485760 bytes (10 MB) copied, 0.00136206 s, 7.7 GB/s
sysctl: setting key "vm.drop_caches": Read-only file system
READ (no cache bs=1M):
10+0 records in
10+0 records out
10485760 bytes (10 MB) copied, 0.00126906 s, 8.3 GB/s
LATENCY (seconds / 1000 = latency in ms):
1000+0 records in
1000+0 records out
512000 bytes (512 kB) copied, 0.00142748 s, 359 MB/s
By using 1000 writes, the time in seconds is the latency for a single write in milliseconds.
-----

...

Run status group 0 (all jobs):
   READ: bw=19.3MiB/s (20.2MB/s), 4339KiB/s-9747KiB/s (4443kB/s-9981kB/s), io=528MiB (554MB), run=3749-27388msec
  WRITE: bw=9415KiB/s (9641kB/s), 4401KiB/s-8857KiB/s (4507kB/s-9070kB/s), io=272MiB (285MB), run=3749-29596msec

Disk stats (read/write):
  sdf: ios=135139/64471, merge=0/971, ticks=53341/936230, in_queue=989559, util=99.71%
fio: file hash not empty on exit
-----

IOPing -R /target (disk seek rate (iops, avg))

--- /target (ext4 /dev/sdf) ioping statistics ---
10.1 k requests completed in 3.0 s, 3.4 k iops, 13.3 MiB/s
min/avg/max/mdev = 237 us / 293 us / 8.7 ms / 192 us
-----

IOPing -RL /target (disk sequential speed (MiB/s))

--- /target (ext4 /dev/sdf) ioping statistics ---
2.7 k requests completed in 3.0 s, 929 iops, 232.3 MiB/s
min/avg/max/mdev = 820 us / 1.1 ms / 9.4 ms / 464 us
-----

IOPing for 10 count...
4.0 KiB from /target (ext4 /dev/sdf): request=1 time=8.3 ms
4.0 KiB from /target (ext4 /dev/sdf): request=2 time=1.1 s
4.0 KiB from /target (ext4 /dev/sdf): request=3 time=1.5 ms
4.0 KiB from /target (ext4 /dev/sdf): request=4 time=505 us
4.0 KiB from /target (ext4 /dev/sdf): request=5 time=501 us
4.0 KiB from /target (ext4 /dev/sdf): request=6 time=2.6 ms
4.0 KiB from /target (ext4 /dev/sdf): request=7 time=940 us
4.0 KiB from /target (ext4 /dev/sdf): request=8 time=2.6 ms
4.0 KiB from /target (ext4 /dev/sdf): request=9 time=2.0 ms
4.0 KiB from /target (ext4 /dev/sdf): request=10 time=1.5 ms

--- /target (ext4 /dev/sdf) ioping statistics ---
10 requests completed in 10.1 s, 8 iops, 35.7 KiB/s
min/avg/max/mdev = 501 us / 112.2 ms / 1.1 s / 329.7 ms
-----


Benchmark complete... sleeping 300s (kill me anytime).
```

> Thos are great numbers for an iSCSI volume hosted over 1GbE, showing near 2x improvement with the recent disk scheduler optimization of `elevator=deadline`.

Now we will do as suggested, and kill (remove) our benchmark job:

        kubectl delete -f coreos-iscsi-bench.yml

This will also remove the 3Gi PVC volume used for the test, which we can verify with `targetcli ls`:

![Targetd pvc volume reclaimed](images/targetd-volume-reclaimed.png)

And we see that the volume __pvc-f09f473d-6809-11e8-97f1-000c298174b4__ has been removed and the disk space has been reclaimed by LVM.

## Extending the Targetd Storage Appliance

You can extend the __Targetd Storage Appliance__ by adding another virtual hard disk to the VM, and then provisioning it manually:

        sudo pvcreate /dev/sd_
        sudo vgcreate vg-targetd-thick /dev/sd_

Where `sd_` is the newly added volume.  Targetd supports hosting multiple physical disks as block pools.

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

And then of course you will need to restart the service:

        sudo systemctl restart targetd

And validate the configuration:

        sudo targetcli ls

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

The __Targetd Storage Appliance__ has been tuned for ESXi Disk I/O as per [the following article](https://kb.vmware.com/s/article/2011861), as have all CentOS/RHEL VMs.  It makes a remarkable difference.