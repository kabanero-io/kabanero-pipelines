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

git_url="https://github.com/smcclem/"
docker_url="smcclem"
collection=$( date +%s%N  )

cd /workspace/$gitsource/pipelines/incubator/events
find . -type f -name '*.yaml' -exec sed -i "s/@Digest@/$collection/g" {} \;
find . -type f -name '*.yaml' -exec kubectl apply -f  {} \;

#./kabanero-pipelines/pipelines/incubator/manual-pipeline-runs/manual-pipeline-run-script.sh
#./manual.sh -r https://github.com/kvijai82/kabanero-nodejs -i index.docker.io/smcclem/manual -c nodejs

echo
echo "Starting pipeline run for collection: "$collection
echo
cd /workspace/$gitsource/pipelines/sample-helper-files/
command="./manual-pipeline-run-script.sh -r $git_url/nodejs  -i $docker_url -c $collection"
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
   echo
   echo "Pipeline run for collection "$collection" failed. See inlined logs for failure:"
   RC=1
   echo
else
   echo
   echo "Pipeline run for collection "$collection" succeeded."    
   RC=0
   echo         
fi 
pod_id=$( kubectl get pods | grep "$collection-manual-pipeline-run-build")
declare $( echo $pod_id | awk '{printf "pod="$1}')
echo $pod" logs_______________________________________________________________________________________________"
echo
kubectl logs $pod --all-containers
echo
echo $pod" logs_______________________________________________________________________________________________"
  
# Delete the pipeline run and application
kubectl delete pipelinerun $collection-manual-pipeline-run 
#TODO appsody applcation delete
cd /workspace/$gitsource/pipelines/incubator/events
find . -type f -name '*.yaml' -exec kubectl delete -f  {} \;

exit $RC