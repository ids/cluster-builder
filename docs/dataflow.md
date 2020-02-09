# Dataflow

A _Kubernetes_ based data science and business intelligence platform.  

Leveraging the open source [cluster-builder](https://cluster-builder.idstudios.io) VMware based _Kubernetes_ environment, __Dataflow__ layers on a unifed _platform of platforms_:

## Core

[StreamSets](https://streamsets.com) provides a full DataOps toolset for both ELT and streaming use cases.

[Dremio](https://dremio.com) _The Data Lake Engine_ offers a unifed curation layer with distributed query engine and in-memory query optimization using columnar database technology while leveraging _cloud provider storage_.  Dremio is the core curated _data source_ for the entire _Dataflow_ system, available directly to most modern Bi tools, but also as _ODBC_, _JDBC_ and _Apache Flight_.

[Kubeflow](https://kubeflow.org) provides a large and integrated Machine Learning and Jupyter analysis platform in its own right.  Integrated __Istio__ service mesh provides a direct notebook-to-containerized-predictive-service work flow.

## Optional

[Kafka](https://kafka.apache.org/) as an optional intermediary stream engine to fascilitate event driven stateful streaming workflows and audit trails.  With additional components from the [Confluent OSS Platform](https://www.confluent.io/download)

[Gitlab](https://gitlab.org) offering integrated, in-cluster team development and SCM Ci/CD tooling for storing all pre and post deployment artifacts.  Also provides the in-cluster private container registry.

[KEDA](https://github.com/kedacore/keda) providing an _Event Driven Serverless_ programming model for reacting to and enriching the data via customized stream processing and micro-services.

# StreamSets

_Todo_

# Dremio

> Ensure you have __Helm 3__ installed.

__Note__ that due to a gap in the current Helm chart the `values.yaml` _storageClass_ value is not picked up by the zookeeper installation, and will hang Pending PVC allocation.  To work around this there are a few options:

* Use the IDStudios fork at https://github.com/ids/dremio-cloud-tools
* Use the `targetd-default-sc` script in `cluster-builder/xtras/k8s` to make an associated __targetd__ server the default storage class for the cluster.
* Set another storage class as default.

## Dremio Helm Installation Steps

1. Clone the [dremio-cloud-tools](https://github.com/dremio/dremio-cloud-tools) repo.
2. Make a copy of the `charts/dremio/values.yaml` file and store it in your cluster folder as `dremio-values.yaml`.  Adjust the file to support the capacity of your cluster.

> As the _Dremio_ values.yaml contains potentially confidential and _secret_ information, it is best stored with the other cluster configuration files.

3. Ensure your `kubectl` config is set to the target cluster
4. Create the target `dremio` namepace (the namespace name is used below in the helm command): `kubectl create ns dremio`
5. Open a command prompt: `cd dremio-cloud-tools/charts`
6. Execute the __Dremio__ Helm 3 installation:

```
helm install -f <path to cluster folder>/dremio-values.yaml -n dremio dremio dremio
```

> This command uses the dremio-values.yaml to create a dremio release in the dremio namespace, the final `dremio` in the command refers to the local __dremio__ charts folder.

When the _Helm_ install completes _Dremio_ should be alive and functioning.  

```
kubectl get pods -n dremio
```

Check the service allocation:

```
kubectl get svc -n dremio
```

This should return output similar to the following:

```
NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                          AGE
dremio-client        LoadBalancer   10.97.1.49       192.168.1.181   31010:30157/TCP,9047:31082/TCP   6m35s
dremio-cluster-pod   ClusterIP      None             <none>          9999/TCP                         6m35s
zk-cs                ClusterIP      10.110.116.193   <none>          2181/TCP                         6m35s
zk-hs                ClusterIP      None             <none>          2181/TCP,2888/TCP,3888/TCP       6m35s
```

> Assuming the cluster is using __MetalLB__, it will allocate a dedicated IP address to the _Dremio Web Client_, which is available on port: __9047__.


In the above example, browse to http://192.168.1.181:9047 for the Dremio Web UI.

# Kubeflow

_Todo_
