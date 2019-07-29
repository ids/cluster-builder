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
helm install ./ -f ../cluster-builder/xtras/k8s/kafka/confluent/targetd-helm-values.yml --name  confluent-oss
```

If you would like your `control-center` (or any other service) to expose a dedicated IP address via __MetalLB__, simply edit the `svc` defintion and change the type from __ClusterIP__ to __LoadBalancer__.

