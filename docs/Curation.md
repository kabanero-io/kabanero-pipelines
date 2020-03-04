Kabanero ships a default set of tasks and pipelines that illustrate a variety of CI/CD functions.  Some of the functions include validating the application stack is active on the cluster, building applications stacks using appsody, pushing the built image to an image repositiry, deploying the application to the cluster, amongst other things.  These tasks and pipelines  work with the default Kabanero application stacks and in many cases might work as is for new application stacks you might create.  However there are cases where you might want to update the tasks or pipelines or create new ones.  This guide will go over the steps to make those updates and how you can update your kabanero CR to use your new pipeline release.

# Creating and updating new tasks or pipelines in your pipelines repo

1. Clone the [Kabanero pipelines repository](https://github.com/kabanero-io/kabanero-pipelines
  
   ```shell
   git clone https://github.com/kabanero-io/kabanero-pipelines.git
   ```

1. The default pipelines and tasks are under the `pipelines/incubator` repository.

    ```shell
    cd pipelines/incubator
    ```
  
1. Edit the existing tasks, pipelines, or trigger files as needed or add your new tasks and pipelines here.  To learn more about pipelines and creating new tasks, see [the pipeline tutorial](https://github.com/tektoncd/pipeline/blob/master/docs/tutorial.md).

# Creating a pipelines release from your pipelines repo

The Kabanero operator expects all the pipelines artifacts to be packaged in an archive file.  The archive file should also include a manifest file that lists out each file in the archive along with it's sha256 hash.  The kabanero-pipelines repo  contains a set of artifacts under the `ci` directory that lets you create and publish a release of your pipelines easily.  

## Creating the pipelines release artifacts locally 

You can build your pipeline repo locally and generate the necessary pipeline archive to use in the Kabanero CR.  The archive file can then be hosted someplace of your chooseing and used in the Kabanero CR.  To generate the archive file locally

1. Run the following command from the root directory of your local copy of the pipelines repo:

    ```
    . ./ci/package.sh
    ```

2. Locate the archive file under the `ci/assests` directory.

3. Upload the archive file to your preferred hosting location and use the URL in the Kabanero CR as described in the next section.

## Creating the pipelines release artifacts from your public Github pipelines repo using travis

If your pipelines are hosted on a public github repo, you can setup a Travis build against a release of your pipelines repo.   This will generate the archive file and attach it to your release.  The kabanro-piplelines repo provides a sample `.travis.yml` file.

Use the location of the archive file under the release in the Kabanero CR as described in the next section. 

## Creating the pipelines release artifacts from your GHE pipelines repo using a tekton pipeline on the OpenShift cluster

Use these steps below to trigger a Tekton pipeline build of your pipelines repository. The pipeline will build the pipelines and deploy a `pipelines-index` container into your cluster.  The `pipelines-index` container will host the Kabanero pipeline archive on a NGINX server.

1. Login to your OpenShift cluster.

1. cd into the `ci` directory of your pipelines repo.

1. Activate the pipeline.
    ```
    oc -n kabanero apply -f tekton/pipelines-build-pipeline.yaml 
    ```
1. Activate the task.
    ```
    oc -n kabanero apply -f tekton/pipelines-build-task.yaml 
    ```

1. Configure security constraints for service account `pipelines-index`
    ```
    oc -n kabanero adm policy add-scc-to-user privileged -z pipelines-index
    ```

1. Create `pipelines-build-git-resource.yaml` file with the following contents. Modify `revision` and `url` properties as needed to point to your pipelines repository and revision you want to build.

    ```
    apiVersion: tekton.dev/v1alpha1
    kind: PipelineResource
    metadata:
      name: pipelines-build-git-resource
    spec:
      params:
      - name: revision
        value: master
      - name: url
        value: https://github.com/kabanero-io/kabanero-pipelines.git
      type: git
    ```

1. Activate the `pipelines-build-git-resource.yaml` file.

    ```
    oc -n kabanero apply -f pipelines-build-git-resource.yaml
    ```
    
1. Create a `pipelines-build-pipeline-run.yaml` file with the following contents.

    ```
    apiVersion: tekton.dev/v1alpha1
    kind: PipelineRun
    metadata:
      name: pipelines-build-pipeline-run
      namespace: kabanero
    spec:
      pipelineRef:
        name: pipelines-build-pipeline
      resources:
      - name: git-source
        resourceRef:
          name: pipelines-build-git-resource
      params:
        - name: deploymentSuffix
          value: latest
      serviceAccountName: pipelines-index
      timeout: 60m
    ```

1. [create a secret](https://github.com/tektoncd/pipeline/blob/master/docs/auth.md#basic-authentication-git) for your git account and associate it with the `pipelines-index` service account. For example:
    ```
    oc -n kabanero secrets link pipelines-index basic-user-pass
    ```

1. Trigger the pipeline.
    ```
    oc -n kabanero delete --ignore-not-found -f pipelines-build-pipeline-run.yaml
    sleep 5
    oc -n kabanero apply -f pipelines-build-pipeline-run.yaml
    ```

    You can track the pipeline execution in the Tekton dashboard or via CLI:
    ```
    oc -n kabanero logs $(oc -n kabanero get pod -o name -l tekton.dev/task=pipelines-build-task) --all-containers -f 
    ```

   After the build completes successfully, a `pipelines-index-latest` container is deployed into your cluster.

1. Get the route for the `pipelines-index-latest` pod.

    ```
    PIPELINES_URL=$(oc -n kabanero get route pipelines-index-latest --no-headers -o=jsonpath='https://{.status.ingress[0].host}/default-kabanero-pipelines.tar.gz')
    echo $PIPELINES_URL
    ```

1. Use the URL in the Kabanero CR as described in the next section.

## Update the Kabanero CR to use the new release

Follow the [configuring a Kabanero CR instance](https://kabanero.io/docs/ref/general/configuration/kabanero-cr-config.html) documentation to configure or deploy a Kabanero instance with the pipeline archive URL obtained in the previous step.  You will also have to generate the digest of the pipelines archive contained at this URL and specify it in the Kabanero CR.   Typically a command like sha256sum is used to obtain the digest.

An example is shown below, where the pipelines pulished in the `https://github.com/kabanero-io/kabanero-pipelines/releases/download/0.6.0/default-kabanero-pipelines.tar.gz` archive are assocaited with each of the stacks that exist in the stack repository.

```
apiVersion: kabanero.io/v1alpha1
kind: Kabanero
metadata:
  name: kabanero
spec:
  version: "0.6.0"
  stacks:
    repositories:
    - name: central
      https:
        url: https://github.com/kabanero-io/collections/releases/download/v0.6.0/kabanero-index.yaml
    pipelines:
    - id: default
      sha256: 14d59b7ebae113c18fb815c2ccfd8a846c5fbf91d926ae92e0017ca5caf67c95
      https:
        url: https://github.com/kabanero-io/kabanero-pipelines/releases/download/0.6.0/default-kabanero-pipelines.tar.gz
```

Alternatively, you can specify the pipelines under the stacks section also.  This will result in the the pipelines in the archive getting associated with all the application stacks in all the repositories listed under stacks.
