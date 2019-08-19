![](https://raw.githubusercontent.com/kabanero-io/kabanero-website/master/src/main/content/img/Kabanero_Logo_Hero.png)

# kabanero-pipelines
The kabanero-pipelines repository contains a collection of build, test & deploy pipelines, intended to work out of the box with the featured Kabanero collections

# Manual pipeline execution

SSH to the master node of the cluster you want to drive the pipelines on and deploy to and execute the following commands.

## Clone the kabanero pipelines repo

```
git clone https://github.com/kabanero-io/kabanero-pipelines
cd kabanero-pipelines
```

## Switch to working in the kabanero namespace
```
oc project kabanero
```

## Setup the appropriate permissions to run the pipelines on OKD clusters

```
oc adm policy add-scc-to-user hostmount-anyuid -z kabanero-sa
cd common
kubectl apply -f appsody-service-account.yaml
kubectl apply -f appsody-cluster-role-binding.yaml
```

## Create a secret with your docker credentials to publish the image to the docker repo and update the appropriate service account

```
apiVersion: v1
kind: Secret
metadata:
  name: my-docker-secret
  annotations:
    tekton.dev/docker-0: https://index.docker.io/v1/ 
type: kubernetes.io/basic-auth
stringData:
  username: <your docker userid>
  password: <your docker password>
```
```
kubectl apply -f my-docker-secret.yaml
kubectl edit serviceaccount kabanero-sa
```
Add the following:
```
secrets:
- name: my-docker-secret
```

## Update the pipeline-resources.yaml with github & docker repo info

After updating the file, apply it

```
kubectl apply -f pipeline-resources.yaml
```

## The featured collections should have activated the tasks and pipelines already.  If you are creating a new task or pipeline, activate them manually

```
kubectl apply -f <task.yaml>
kubectl apply -f <pipeline.yaml>
```

## Run the pipeline

Update the pipeline-run.yaml to point to the pipeline you want run and apply it to run the pipeline.
```
kubectl apply -f pipeline-run.yaml
```

## Check the status of the pipeline run

