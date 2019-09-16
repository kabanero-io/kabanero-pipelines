![](https://raw.githubusercontent.com/kabanero-io/kabanero-website/master/src/main/content/img/Kabanero_Logo_Hero.png)

# Kabanero Pipelines
The kabanero-pipelines repository contains a collection of Tekton tasks and pipelines that are intended to work out of the box with the featured Kabanero collections to illustrate a CI/CD work flow.  The pipelines and tasks can be executed manually or via a webhook.  The steps below walk through how to drive a pipeline manually (using a script or CLI), which is useful for pipeline development, or driving it via a webhook, which is perfect for CI/CD workflows once there is a functional pipeline.

# Prereqs

You have the Kabanero foundation installed on Red Hat Origin Community Distribution of Kubernetes (OKD) or OpenShift Container Platform (OCP) cluster.  It has the necessary Kabanero, Isito, Knative, and Tekton components installed.  Please refer to https://github.com/kabanero-io/kabanero-foundation for more details on installing the Kabanero foundation.

Identify the Tekton Dashboard URL after your have completed the installation.  You can login to your OKD cluster and run ```oc get routes``` to find this or check in the OKD console.  This is useful for a few of the steps documented below.  You can find more details about the dashboard at https://github.com/tektoncd/dashboard.

NOTE: Everything is assumed to be running in `kabanero` namespace.

### Create a persistent volume
The persistent volume is used by the pipelines.  An example pv definition is provided.  Update path and other values in pv.yaml to suit your requirements.

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

This has to be created in the `kabanero` namespace and associated with the `kabanero-operator` service account.  The secrets can be created in a few different ways.  Simplest option is to go configure this is the Tekton Dashboard under the secrets section as given [here](https://github.com/tektoncd/experimental/blob/master/webhooks-extension/docs/GettingStarted.md#create-credentials-git).  
Alternatively you can configure this in the OKD console or you can setup the secret using the OKD CLI. 


# Execute pipelines using Tekton Dashboard Webhook Extension

You can leverage the Tekton Dashboard Webhook Extensions to drive the pipelines automatically by configuring webhooks to github.  Events such as commits or pull requests in a github repo can be setup to automatically trigger pipeline runs.

Visit https://github.com/tektoncd/experimental/blob/master/webhooks-extension/docs/GettingStarted.md for instructions on configuring a webhook.

# Manual pipeline execution using a script

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

# Manual pipeline execution via CLI

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

### Command line:
```
oc get pipelineruns
oc -n kabanero describe pipelinerun.tekton.dev/<pipeline-run-name> 
```
You should also see pods for the pipeline runs that you can ```oc describe``` and ```oc logs``` to get more details of your run.

If the pipeline run was successful, you should see a docker image in your docker registry and you should see a pod that's running your application.

### Tekton dashboard

Login to the Tekton Dashboard and navigate to the Pipeline runs section in the menu on the left hand menu.  Find your pipeline run and click on it to check the status and find logs.
