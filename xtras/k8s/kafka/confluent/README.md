Installing Confluent using the Helm Charts
==========================================

At the time of this writing the cp-helm-charts are considered BETA, and are still in development.

If you would like to have the __Confluent Control Center__ also installed, you need to checkout the latest version of these charts from github:

```
git clone github.com/confluent/cp-helm-charts
cd cp-helm-charts
```

In this example the cp-helm-charts repo is a peer to cluster builder in the file system heirarchy:

```
Workspace
    /cluster-builder
    /cp-helm-charts
```

So to use the `targetd-helm-values.yml` values file specific to cluster-builder, issue the following command once `helm` has been properly installed and configured.

```
cd cp-helm-charts
helm install ./ -f ../cluster-builder/xtras/k8s/kafka/confluent/cb-helm-values.yml --name  confluent-oss
```

> Note that right after you run this command, check to see that the PVCs bound successfully and didn't fall victim to a Targetd race condition:

```
[admin@cluster-control cp-helm-charts]$ kubectl get pvc
NAME                                  STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS               AGE
datadir-0-confluent-cp-kafka-0        Bound    pvc-971aa0af-0a17-444c-bd45-5c33739e1b66   10Gi       RWO            iscsi-targetd-vg-targetd   3s
datadir-confluent-cp-zookeeper-0      Bound    pvc-ff29d3e6-fa5d-4879-9990-358041d1f490   5Gi        RWO            iscsi-targetd-vg-targetd   3s
datalogdir-confluent-cp-zookeeper-0   Bound    pvc-6e2f459b-eef8-4de6-ae58-56e48f7ce42a   5Gi        RWO            iscsi-targetd-vg-targetd   3s
```

If you would like your `control-center` (or any other service) to expose a dedicated IP address via __MetalLB__, simply edit the `svc` defintion and change the type from __ClusterIP__ to __LoadBalancer__.

You can edit and apply the `cb-services.yml` file to expose the Kafka services using external __MetalLB__ IP addresses.