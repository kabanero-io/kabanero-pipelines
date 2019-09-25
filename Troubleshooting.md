# Kabanero Pipelines Troubleshooting Guide

1. My pipelinerun failed in Tekton Dashboard with `Unable to fetch log`, what is wrong?
   
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
     is supposed to be applied as manual pre-requisite step before running any pipelinerun.
    
   
