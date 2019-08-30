![](https://raw.githubusercontent.com/kabanero-io/kabanero-website/master/src/main/content/img/Kabanero_Logo_Hero.png)

# kabanero-pipelines
The kabanero-pipelines repository contains a collection of Tekton tasks and pipelines that are intended to work out of the box with the featured Kabanero collections to illustrate a CI/CD work flow.  The pipelines and tasks can be executed manually or via a webhook.  The steps below walk through how to drive a pipeline manually, which is useful for pipeline development, and driving it via a webhook, which is perfect for CI/CD workflows once there is a functional pipeline.

# Prereqs

### Create a peristant volume
The persistant volume is used by the pipelines.  An example pv definition is provided.  Update path and other values in pv.yaml to suit your requirements.

```
cd ./pipelines/common
kubectl apply -f pv.yaml -n kabanero
```

### Create secrets to pull from git repo and push to docker registry

This has to be created in the *kabanero* namespace and associated with the *kabanero-operator* service account.  The secrets can be created in a few different ways.  Simplest option is to go configure this is the Tekton Dashboard under the secrets section.  You can configure this in the OKD console or you can setup the secret using the OKD CLI. 


# Execute pipelines using Tekton Dashboard Webhook Extension

You can also leverage the Tekton Dashboard Webhook Extensions to drive the pipelines automatically by configuring webhooks to github.  Events such as commits or pull requests in a github repo can be setup to automatically trigger pipeline runs.

Visit https://github.com/tektoncd/experimental/blob/master/webhooks-extension/docs/GettingStarted.md for instructions on configuring a webhook.

# Manual pipeline execution using a script

# Manual pipeline execution

Login to your cluster.  For example for OKD,

```
oc login <master node IP>:8443
```

### Clone the kabanero pipelines repo

```
git clone https://github.com/kabanero-io/kabanero-pipelines
cd kabanero-pipelines
```

### Update the pipeline-resources.yaml with github & docker repo info to create the PipelineResources

Sample pipeline-resources.yaml files are provided for each featured collection under the manual-pipeline-runs dir.  Update the docker-image URL.  You can use the sample github repo provided or update it to point to your github repo.

After updating the file, apply it

```
kubectl apply -f <collection-name>-pipeline-resources.yaml
```

### The featured collections should have activated the tasks and pipelines already.  If you are creating a new task or pipeline, activate them manually

```
kubectl apply -f <task.yaml>
kubectl apply -f <pipeline.yaml>
```

### Run the pipeline

Sample PipelineRun files are provided under ./pipelines/manual-pipeline-runs.  Locate the appropriate pipeline-run file and execute it.
```
kubectl apply -f <collection-name>-pipeline-run.yaml
```

# Checking the status of the pipeline run

You can check the status of the pipeline run from the OKD console, command line, or Tekton dashboard.

Command line:
```
kubectl get pipelineruns
kubectl -n kabanero describe pipelinerun.tekton.dev/<pipeline-run-name> 
```

Tekton dashboard

Login to the Tekton Dashboard and navigate to the Pipeline runs section in the menu on the left hand menu.  Find your pipeline run and click on it to check the status and find logs.
