# Kabanero Pipelines Troubleshooting Guide

**1.** My pipelinerun failed in Tekton Dashboard with `Unable to fetch log`, what is wrong?
 
  Problem:
 
   - The pipelinerun never starts, and after one hour gives the above error.
   
  Reason:
   
   - The persistent volume `pv.yaml` is not applied so no persistent volume present.
 
  Throubleshooting steps
   - Check whether your pipelinerun failed due to `unbound PersistentVolumeClaims`
   
   Command:
   
   `kubectl get pipelineruns/pipelinerun-name -o yaml`
   
   Sample Output:
   
```
      lastTransitionTime: 2019-09-25T19:36:56Z
    message: Not all Tasks in the Pipeline have finished executing
    reason: Running
    status: Unknown
    type: Succeeded
    startTime: 2019-09-25T19:36:59Z
    taskRuns:
        kab-nodejs-express-wbh-2-1569440216-build-task-r8klh:
          pipelineTaskName: build-task
          status:
            conditions:
             lastTransitionTime: 2019-09-25T19:37:00Z
              message: "pod status "PodScheduled":"False"; message: "pod has unbound PersistentVolumeClaims
                (repeated 2 times)"
              reason: Pending
              status: Unknown
              type: Succeeded
            podName: kab-nodejs-express-wbh-2-1569440216-build-task-r8klh-pod-5172ba
            startTime: 2019-09-25T19:36:59Z
    [root@escapes1 common]# ls
   
```
   
   - If you see above message you have to check if persistent volume is applied for pipelinerun
   
    Command:   
`kubectl get PersistentVolume`<br>
   
    Sample output:
   
```
     NAME                      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                    STORAGECLASS   REASON    AGE
     manual-pipeline-run-pvc   5Gi        RWO            Recycle          Available                                                     1s
     registry-volume           10Gi       RWX            Retain           Bound       default/registry-claim                            13d
```
   
  NOTE: You should see two persistent volumes as shown above, `registry-volume` is by default present for you and `manual-pipeline-run-pvc` 
     is supposed to be applied as manual pre-requisite step before running any pipelinerun. Follow steps [here](https://github.com/kabanero-io/kabanero-pipelines/blob/master/README.md#create-a-persistent-volume)
 
 ********
 
   
   **1.1** My pipelinerun is shown started, however the first step itself is shown with loading symbol in tekton dashboard and the pod of build task is not started.
 
 Problem:
 
   - The pipelinerun never brings up any build task pod.
    
 Assumptions:
   - The persistent volume `pv.yaml` is already applied.
   - We can see the PV created on `oc get pv` command.
    
 Reason:
   - If you have applied the pv.yaml and you are running the pipelinerun on a public cloud cluster, you might have a default [Storage Class](https://kubernetes.io/docs/concepts/storage/storage-classes/#introduction) in that cluster that is not provisioning the persistent volumes when a [persistent volume claim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims) is created by the pipeline.
    
 Troubleshooting Steps :
   - We recommend to first find out if you have the custom storage class in that cluster
    
```
     oc get storageclass
     
```
    
    Sample output
    
```
    NAME                             PROVISIONER         AGE
    ibmc-block-bronze (default)      ibm.io/ibmc-block   20d

```
    
   - Try to find if the default storage class provisons Persistent Volumes when PVC(persistent volume claim) request comes in.
     If not, then try to either tweak the storage class to provison persistent volume when PVC comes in, else delete the default storage class so the PVC when comes in it will bound to the `pv.yaml` PV which was statically created as per the assumptions.
    
********

**2**. I see the error below while running the building step of a Kabanero Pipeline.The cause of this could be either of the 3 situations mentioned below before running the pipelines

    - The user has created a secret for github but not patched that secret onto the service account used by the PipelineRun or TaskRun in question, or
    - The user has not created a secret for github, but has tried to patch the relevant service account, or
    - The user has not created a secret for github and has not patched the relevant service account

Error Snippet:
{"level":"warn","ts":1568057939.538,"logger":"fallback-logger","caller":"logging/config.go:69","msg":"Fetch GitHub commit ID from kodata failed: \"KO_DATA_PATH\" does not exist or is empty"}
{"level":"error","ts":1568057939.8545134,"logger":"fallback-logger","caller":"git/git.go:35","msg":"Error running git [fetch --depth=1 --recurse-submodules=yes origin fc7fe7fb8d87779dd5419b509dd2c91e63ba87b7]: exit status 128\nfatal: could not read Username for 'https://github.ibm.com': No such device or address\n","stacktrace":"github.com/tektoncd/pipeline/pkg/git.run\n\t/go/src/github.com/tektoncd/pipeline/pkg/git/git.go:35\ngithub.com/tektoncd/pipeline/pkg/git.Fetch\n\t/go/src/github.com/tektoncd/pipeline/pkg/git/git.go:88\nmain.main\n\t/go/src/github.com/tektoncd/pipeline/cmd/git-init/main.go:36\nruntime.main\n\t/usr/local/go/src/runtime/proc.go:198"}
{"level":"error","ts":1568057940.1771348,"logger":"fallback-logger","caller":"git/git.go:35","msg":"Error running git [pull --recurse-submodules=yes origin]: exit status 1\nfatal: could not read Username for 'https://github.ibm.com': No such device or address\n","stacktrace":"github.com/tektoncd/pipeline/pkg/git.run\n\t/go/src/github.com/tektoncd/pipeline/pkg/git/git.go:35\ngithub.com/tektoncd/pipeline/pkg/git.Fetch\n\t/go/src/github.com/tektoncd/pipeline/pkg/git/git.go:91\nmain.main\n\t/go/src/github.com/tektoncd/pipeline/cmd/git-init/main.go:36\nruntime.main\n\t/usr/local/go/src/runtime/proc.go:198"}
{"level":"warn","ts":1568057940.1772096,"logger":"fallback-logger","caller":"git/git.go:92","msg":"Failed to pull origin : exit status 1"}
{"level":"error","ts":1568057940.1798232,"logger":"fallback-logger","caller":"git/git.go:35","msg":"Error running git [checkout fc7fe7fb8d87779dd5419b509dd2c91e63ba87b7]: exit status 128\nfatal: reference is not a tree: fc7fe7fb8d87779dd5419b509dd2c91e63ba87b7\n","stacktrace":"github.com/tektoncd/pipeline/pkg/git.run\n\t/go/src/github.com/tektoncd/pipeline/pkg/git/git.go:35\ngithub.com/tektoncd/pipeline/pkg/git.Fetch\n\t/go/src/github.com/tektoncd/pipeline/pkg/git/git.go:94\nmain.main\n\t/go/src/github.com/tektoncd/pipeline/cmd/git-init/main.go:36\nruntime.main\n\t/usr/local/go/src/runtime/proc.go:198"}
{"level":"fatal","ts":1568057940.179904,"logger":"fallback-logger","caller":"git-init/main.go:37","msg":"Error fetching git repository: exit status 128","stacktrace":"main.main\n\t/go/src/github.com/tektoncd/pipeline/cmd/git-init/main.go:37\nruntime.main\n\t/usr/local/go/src/runtime/proc.go:198"}

Step failed


 Throubleshooting steps
  - When running your Tekton Pipelines, if you see a `fatal: could not read Username for *GitHub  repository*: No such device or address` message in your failing Task logs, this indicates there is no `tekton.dev/git`  annotated GitHub secret in use by the ServiceAccount that launched this PipelineRun. You need to create one via the Tekton Dashboard. The annotation will be added and the specified ServiceAccount will be patched.
 
 *******
 
 **3**. Unable to load PipelineRun details: CouldntGetResource

Error message:
PipelineRun kabanero/web-mon-1571161246 can't be Run; it tries to bind Resources that don't exist: Couldn't retrieve PipelineResource: couldn't retrieve referenced input PipelineResource "web-mon-git-source-1571161246": pipelineresource.tekton.dev "web-mon-git-source-1571161246" not found

Cause:
This is caused due to a timing issue in Tekton where the PipelineRun triggered by the webhook gets kicked off before the git-source resource is fully created.  Bug open in Tekton for this:  https://github.com/tektoncd/experimental/issues/240.

Workaround:
Rerun the PipelineRun from the Tekton dashboard.  Usually seems to happen with the first PipelineRun triggered by the webhook.

*****

 **4**. I do not have dockerhub container registry but the local container registry provided by Openshift, how would I use it ?
  
  Troubleshooting Steps: 
   - Find the local container registry URL given by Openshift in your cluster.
     - Goto Openshift web console and select the workspace `default`.
     - Click the pod with name `docker-registry`.
     - Go to the tab `Environment` for `docker-registry` pod.
     - You will get the URL `OPENSHIFT_DEFAULT_REGISTRY` = `docker-registry.default.svc:5000`
   - Once you found the local container registry use it while setting the webhook as value for `Docker Registry` , or mention it when you are running the pipelinerun manually as a pipeline resource `docker-image`.
   
   example1 : In Tekton dashboard via a Webhook
   
   `Docker Registry : image-registry.openshift-image-registry.svc:5000/kabanero`
     
   example2 : In manual pipelinerun pipelineresource as
   
   `docker-image : docker-registry.default.svc:5000/kabanero/my-image-name`

 **5** When using OpenShift Container Platform on a cloud with Kubernetes service and an internal Docker registry, performing a `docker push` into the internal Docker
registry might result in a gateway time-out error.  

  Reason:

This happens in cases where the input-output operations per second (IOPS) setting for the backing storage
of the registry's persistent volume (PV) is too low.

  Troubleshooting step:
   - To resolve this problem, change the IOPS setting of the PV's backing storage device.
   
   `docker-image : image-registry.openshift-image-registry.svc:5000/kabanero/my-image-name`
   
**6**. Error initializing source docker://kabanero/nodejs-express:0.2: unable to retrieve auth token: invalid username/password[Info]

Error Message:
```
The following failures happened while trying to pull image specified by "kabanero/nodejs-express:0.2" based on search registries in /etc/containers/registries.conf:[Info] * "localhost/kabanero/nodejs-express:0.2": Error initializing source docker://localhost/kabanero/nodejs-express:0.2: pinging docker registry returned: Get https://localhost/v2/: dial tcp [::1]:443: connect: connection refused[Info] * "docker.io/kabanero/nodejs-express:0.2": Error initializing source docker://kabanero/nodejs-express:0.2: unable to retrieve auth token: invalid username/password[Info]
```

Possible reason:

Sometimes if the docker secret is set by the user and that is with invalid credentials, while pulling the kabanero stacks it may try to validate the docker credentials in the docker secret and it gives above mentioned error.

Workaround:

If you see such error of invalid username/password while pulling the kabanero stack it tries to pull, you can delete your docker secret and try to run the pipeline and check if it is getting passed this error. 
If it does get ahead and fails in the pipeline to push the image to your docker repository , then you need to put back your docker secret with correct credentials so the pipeline could push the image to your docker repository.

**7**. My persistant volume claims are not deleted after my pipelinerun has completed.

This is the default behavior of Tekton & Kubernetes.  When a pipelinerun has completed, the associated pods will be in completed state.  The PV claims are bounds to this resource and will be in terminating state til the pods are deleted.  This helps preserve logs for debugging.  All the associated pods and PV claims will get deleted when the the pipelinerun is deleted.  You can check on the pipelineruns using ```oc get pipelineruns``` and the appropriate run using ```oc delete pipelinerun <pipelinerun_name>```.

