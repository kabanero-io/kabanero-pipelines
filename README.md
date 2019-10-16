![](https://raw.githubusercontent.com/kabanero-io/kabanero-website/master/src/main/content/img/Kabanero_Logo_Hero.png)

# Kabanero Pipelines

# Introduction

Kabanero leverages Tekton Pipelines to illustrate a CI/CD work flow.  Each of the featured Kabanero collections contain a default pipeline that will build the collection, publish the image to a docker repo, and then deploy the image to the k8s cluster to illustrate an end to end flow.  You can add additional tasks and pipelines to the collections.  All the tasks and pipelines will be activated by Kabanero operator.

To learn more about Tekton Pipelines and creating new tasks, please review these resources:
https://github.com/tektoncd/pipeline/tree/master/docs#usage
https://github.com/tektoncd/pipeline/blob/master/docs/tutorial.md

# Tasks and Pipelines

The Kabanero Collections contain the tasks & pipelines associated with the collection under <collection-name>/pipelines once the collection is built.

Note: Currently the featured collections share the same tasks & pipelines and the collections build process will copy the files from https://github.com/kabanero-io/collections/tree/master/incubator/common/pipelines/default to <collection-name>/pipelines during build.  If you are building a new collection, you can leverage the existing pipelines as is if it satisfies your requirements to build and deploy.  They will automatically be pulled into your collection when you build your collections repo.

Build-deploy-pipeline.yaml (https://github.com/kabanero-io/collections/blob/master/incubator/common/pipelines/default/build-deploy-pipeline.yaml) is the primary pipeline associated with the collections that will validate the collection is active, build the git source, publish the container image, and deploy the application.  It looks for git-source and docker-image resources that will be used by the build-task and deploy-task.

Build-task.yaml (https://github.com/kabanero-io/collections/blob/master/incubator/common/pipelines/default/build-task.yaml) builds a container image from the artifacts in the git-source repository using buildah.  Once the image is built, it will publish it to the docker-image URL using buildah.

Deploy-task.yaml (https://github.com/kabanero-io/collections/blob/master/incubator/common/pipelines/default/build-task.yaml) will modify the app-deploy.yaml, which describes the deployment options for the application, to point to the image that was published and will deploy the application using the appsody operator.

For additional tasks and more information about kabanero pipelines, visit the kabanero-pipelines (https://github.com/kabanero-io/kabanero-pipelines) repo.

# Running the pipelines

## Prereqs

You have the Kabanero foundation installed on Red Hat Origin Community Distribution of Kubernetes (OKD) or OpenShift Container Platform (OCP) cluster.  It has the necessary Kabanero, Isito, Knative, and Tekton components installed.  Please refer to https://github.com/kabanero-io/kabanero-foundation for more details on installing the Kabanero foundation.

Identify the Tekton Dashboard URL after your have completed the installation.  You can login to your OKD cluster and run ```oc get routes``` to find this or check in the OKD console.  This is useful for a few of the steps documented below.  You can find more details about the dashboard at https://github.com/tektoncd/dashboard.

NOTE: By default the pipelines will run in `kabanero` namespace and deploy the application there as well.  If you would like to deploy the application in a different namespace, please update the app-deploy.yaml to point to the namespace to deploy to.

### Setup dynamic volume provisioning or a persistent volume

Tekton pipelines requires a volume to be configured that will be used by the framework to share data across tasks.  The build task, which leverages buildah, also requires a volume mount.  The minimum required volume size is 5 Gi.  

If your cluster is running in a public cloud, dynamic volume provisioning is the easier and preferred option.  Please refer to the following doc that describes how to point to the storage class using a config map.   https://github.com/tektoncd/pipeline/blob/master/docs/install.md#how-are-resources-shared-between-tasks

Note:  If this is not configured and based on how your cloud provider's default storage class is configred, your pipelines might create a new volume for each run which will increase your pipeline run execution time.

Alternatively, if you are using an unmanaged cluster you can setup a persistent volume to be used by the pipeline.  A simple example pv definition is provided.  Update path and other values in pv.yaml to suit your requirements.  For example, NFS is the preferred configuration in a production environment verus using local storage as shown in the example.

Login to your cluster.  For example for OKD,

```
oc login <master node IP>:8443
```

Clone the pv.yaml in this repo and apply it.

```
cd ./pipelines/common
oc apply -f pv.yaml -n kabanero
```

### Create secrets to pull from git repo and push to docker registry

This has to be created in the `kabanero` namespace and associated with the service account that pipelines are run with.  The secrets can be created in a few different ways.  Simplest option is to go configure this is the Tekton Dashboard under the secrets section as given [here](https://github.com/tektoncd/experimental/blob/master/webhooks-extension/docs/GettingStarted.md#create-credentials-git).

Alternatively you can configure this in the OKD console or you can setup the secret using the OKD CLI. 


Below is a video that walks through setting up the prereqs to run the pipelines:

<iframe width="560" height="315" src="https://www.youtube.com/embed/MfS05SU9yIM" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Pipeline execution using Tekton Dashboard Webhook Extension

You can leverage the Tekton Dashboard Webhook Extensions to drive the pipelines automatically by configuring webhooks to github.  This enables the CI/CD flow by automatically building and deploying the applications with code updates in your git repo.  Events such as commits or pull requests in a github repo can be setup to automatically trigger pipeline runs.

For detailed description on creating a web hook to git, please visit these resources:
https://kabanero.io/docs/ref/general/tekton-webhooks.html
https://github.com/tektoncd/experimental/blob/master/webhooks-extension/docs/GettingStarted.md

## Manual pipeline execution using a script

If you are developing a new pipeline and would like to manually test it in a tight loop, using the script or manually driving pipelines might be more helpful than using a webhook.  Steps below describe how to do that.

Login to your cluster.  For example for OKD,

```
oc login <master node IP>:8443
```

### Clone the kabanero pipelines repo

```
git clone https://github.com/kabanero-io/kabanero-pipelines
```

### Run the script with the appropriate parameters
```
cd ./pipelines/incubator/manual-pipeline-runs/

./manual-pipeline-run-script.sh -r [git_repo of the Appsody project] -i [docker registery path of the image to be created] -c [collections name of which pipeline to be run]"
```

For example:
```
./manual-pipeline-run-script.sh -r https://github.com/mygitid/appsody-test-project -i index.docker.io/mydockeid/my-java-microprofile-image -c java-microprofile"
```

## Manual pipeline execution via command line

Login to your cluster.  For example for OKD,

```
oc login <master node IP>:8443
```

### Clone the kabanero pipelines repo

```
git clone https://github.com/kabanero-io/kabanero-pipelines
cd kabanero-pipelines
```

### Create PipelineResources

Update the pipeline-resources.yaml with github & docker repo info to create the PipelineResources.  Sample pipeline-resources.yaml files are provided for each featured collection under the manual-pipeline-runs dir.  Update the docker-image URL.  You can use the sample github repo provided or update it to point to your github repo.

After updating the file, apply it

```
oc apply -f <collection-name>-pipeline-resources.yaml
```

### Activate the tasks & pipelines
The installations will activate the featured collections should have activated the tasks and pipelines already.  If you are creating a new task or pipeline, activate them manually

```
oc apply -f <task.yaml>
oc apply -f <pipeline.yaml>
```

### Run the pipeline

Sample PipelineRun files are provided under ./pipelines/manual-pipeline-runs.  Locate the appropriate pipeline-run file and execute it.
```
oc apply -f <collection-name>-pipeline-run.yaml
```

# Checking the status of the pipeline run

You can check the status of the pipeline run from the OKD console, command line, or Tekton dashboard.

### Tekton dashboard

Login to the Tekton Dashboard and navigate to the "Pipeline runs" section in the menu on the left hand menu.  Find your pipeline run and click on it to check the status and find logs.  You can looks the logs and status of each step and task over here.

### Command line:
```
oc get pipelineruns
oc -n kabanero describe pipelinerun.tekton.dev/<pipeline-run-name> 
```
You should also see pods for the pipeline runs that you can ```oc describe``` and ```oc logs``` to get more details of your run.

If the pipeline run was successful, you should see a docker image in your docker registry and you should see a pod that's running your application.

# Troubleshooting 

For a list of common issues and troubleshooting problems with the pipelines, please visit the troubleshooting guide here:  https://github.com/kabanero-io/kabanero-pipelines/blob/master/Troubleshooting.md
