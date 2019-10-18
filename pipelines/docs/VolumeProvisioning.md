# Volume Provisioning for Kabanero Pipelineruns

Tekton pipelines require a configured volume that is used by the framework to share data across tasks. The build task, which uses Buildah, also requires a volume mount. The pipelinerun should be creating a [Persistent Volume Claim PVC](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#introduction) with a requirement for 5 Gi persistent volume.

1. Log in to your cluster. For example, for OKD

```
oc login <master node IP>:8443
```

2. Clone the [kabanero-pipeplines repo](https://github.com/kabanero-io/kabanero-pipelines.git)

```
git clone https://github.com/kabanero-io/kabanero-pipelines
```

## Static Persistent Volumes

The example `pv.yaml` shows how to configure a [Persistent Volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#introduction) using a `hostPath` type on the Persistent Volume. This is shown just for the ease of creating the simplest Persistent Volume to enable a pipeline run. It is not the recommended approach to use hostPath in anything beyond a test environment.Update the path and other values in your `pv.yaml` file provided in this repository, to suit your requirements. Please find all the different types of Persistent Volumes [here](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#types-of-persistent-volumes)

For instance, the following example is configured for local storage. You might edit this file to configure it for NFS, the standard configuration in a production environment.

- Clone the `pv.yaml` file in this repository and apply it.

```
cd ./pipelines/common
oc apply -f pv.yaml -n kabanero
```

## Dynamic Volume Provisioning

If your cluster is running in a public cloud, dynamic volume provisioning is an easier option. For more information on how to use storage class and configMap through Tekton for dynamic provisioning of the persistent volumes	, see the document [How are resources shared between tasks](https://github.com/tektoncd/pipeline/blob/master/docs/install.md#how-are-resources-shared-between-tasks).

Your persistent volume must be configured in accordance with your cloud provider’s default [storage class](https://kubernetes.io/docs/concepts/storage/storage-classes/#introduction). Below are some of the recommendations for dynamic volume provisioning while running Kabanero pipelines.

1. For running the Kabanero pipelines you should have your [storage class](https://kubernetes.io/docs/concepts/storage/storage-classes/#introduction) to be configured to provision atleast 5Gi of persistent volume dynamically.

2. The storage class used for dynamic provisioning should have the reclaiming policy of `Recycle` if you have the requirement to run multiple pipelines and that too frequently. 
Usually if the `default` [storage class](https://kubernetes.io/docs/concepts/storage/storage-classes/#introduction) is configured in the public cloud the reclaiming policy is `delete` and in that case your pipelines might create a new volume for each run, which increases your pipeline run execution time. To know more about the reclaiming policy go [here](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaiming)

#### Feature Coming soon for Dynamic provisioning using customized [storage class](https://kubernetes.io/docs/concepts/storage/storage-classes/#introduction)

1. Create your customized [storage class](https://kubernetes.io/docs/concepts/storage/storage-classes/#introduction) for dynamic provisioning for the persistent volumes.

example: Example showing the `storageclass` template

2. Tell the Tekton to use your storage class via [configMap](https://github.com/tektoncd/pipeline/blob/master/docs/install.md#how-are-resources-shared-between-tasks), so when the kabanero pipelines are run, tekton can use your custom storage class to provision dynamic persistent volumes.

example : Example showing the `configMap` template