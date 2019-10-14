# Kabanero Pipelines Troubleshooting Guide

1. My pipelinerun failed in Tekton Dashboard with `Unable to fetch log`, what is wrong?
   
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
    `kubectl get PersistentVolume`
   
    Sample output:
   
     ```
     NAME                      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                    STORAGECLASS   REASON    AGE
     manual-pipeline-run-pvc   5Gi        RWO            Recycle          Available                                                     1s
     registry-volume           10Gi       RWX            Retain           Bound       default/registry-claim                            13d
     ```
   
     NOTE: You should see two persistent volumes as shown above, `registry-volume` is by default present for you and `manual-pipeline-run-pvc` 
     is supposed to be applied as manual pre-requisite step before running any pipelinerun. Follow steps [here](https://github.com/kabanero-io/kabanero-pipelines/blob/master/README.md#create-a-persistent-volume)
    
2. I see the error below while running the building step of a Kabanero Pipeline.The cause of this could be either of the 3 situations mentioned below before running the pipelines

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
