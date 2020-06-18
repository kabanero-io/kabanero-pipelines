#!/bin/bash

function retry() {
    local -r -i max_attempts="$1"
    local -r -i sleep_time="$2"
    local -r cmd="$3"
    local -i attempt_num=1
    until eval $cmd
    do
        rc=$?
        if (( attempt_num == max_attempts ))
        then
            return $rc
        else
            echo "attempt "$attempt_num" of "$max_attempts" for command: "$cmd
            sleep $sleep_time
            ((attempt_num++))
        fi
    done
    return 0
}

cd /workspace/$gitsource/pipelines/incubator/events
find . -type f -name '*.yaml' -exec sed -i 's/@Digest@/nodejs/g' {} \;
find . -type f -name '*.yaml' -exec kubectl apply -f  {} \;


git_url="https://github.com/smcclem/"
docker_url="index.docker.io/smcclem/"
collection="nodejs"

declare -a active_collections
active_collections=( nodejs )

#./kabanero-pipelines/pipelines/incubator/manual-pipeline-runs/manual-pipeline-run-script.sh
#./manual.sh -r https://github.com/kvijai82/kabanero-nodejs -i index.docker.io/smcclem/manual -c nodejs

echo
echo "Starting pipeline run for collection: "$collection
echo
cd /workspace/$gitsource/pipelines/sample-helper-files/
command="./manual-pipeline-run-script.sh -r $git_url/$collection  -i $docker_url/ -c $collection"
echo $command
eval $command 
cd -
   
# Sample commands used during test
# retry 10 "kubectl get pod $pod && [[ \$(kubectl get pipelinerun $collection"-manual-pipeline-run"--no-headers 2>&1 | grep -c -v -E -q '(Running|Completed|Terminating)') -eq 0 ]]"
# retry 1000 "kubectl logs $pod --all-containers | grep -q '$MESSAGE'"
  
# Wait for the pipeline run to start  
retry 20 6 "kubectl get pipelinerun $collection"-manual-pipeline-run" --no-headers 2>&1"
# Handle error if the pod doesn't start
   
# Wait for pipeline run to finish
retry 120 10  "[[ \$(kubectl get pipelinerun $collection"-manual-pipeline-run" --no-headers 2>&1 |  awk '{ printf \$2 }' | grep -c -v -E '(True|False)') -eq 0 ]]"
succeeded=$( kubectl get pipelinerun $collection"-manual-pipeline-run" --no-headers 2>&1 |  awk '{ printf $2 }' )
          
if [ "$succeeded" != "True" ]; then
   # Piplerun failed, collect logs
   build_pod_id=$( kubectl get pods | grep $collection.*build-push-task)
   deploy_pod_id=$( kubectl get pods | grep $collection.*deploy-task)
   declare $( echo $build_pod_id | awk '{printf "build_pod="$1}')
   declare $( echo $deploy_pod_id | awk '{printf "deploy_pod="$1}')
   log_dir=$collection/$(date +%Y-%m-%d-%H-%M-%S)
   mkdir -p $log_dir
   echo
   echo "Pipeline run for collection "$collection" failed. Collecting logs to: "$log_dir", succeeded: "$succeeded
   echo
   kubectl logs $build_pod --all-containers > $log_dir/$build_pod.log 
   kubectl logs $deploy_pod --all-containers > $log_dir/$deploy_pod.log 
else  
   echo
   echo "Pipeline run for collection "$collection" succeeded."    
   echo         
fi 

# Delete the pipeline run and application
# kubectl delete pipelineruns --all
# kubectl delete appsodyapplications  --all
