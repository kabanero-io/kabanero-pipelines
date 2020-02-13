#!/bin/bash

# Parameters
# [github url] [docker url]
# ./test.sh https://github.com/smcclem index.docker.io/smcclem


# Prerequisites
# -------------
# 1. This script needs to be directly run on a OKD/OpenShift env that already had the Kabanero operator installed. 
# 2. The Kab operator has activated all the collections that are needed
# 3. A github and docker account are needed. This script will create repositories with the Kabanero collection name, 
#    so it assumed that for these provided accounts, these repo names are available to be overwritten.
# 4. The manual pipeline instructions have been followed. That means a pv.yaml and secret.yaml have been applied
#    to create a persistent volume and docker secret for my-docker-secret


# oc get collections formatting:

# NAME                AGE
# java-microprofile   4d
# java-spring-boot2   4d
# nodejs              4d
# nodejs-express      4d
# nodejs-loopback     4d

# Retries a command on failure.
# $1 - the max number of attempts
# $2 - the amount of time to sleep between attempts
# $2... - the command to run
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

git_url=$1
docker_url=$2

# Process oc get collections  output to get an array of active collections
declare -a active_collections
eval $( printf "active_collections=("; oc get stacks | awk '{if ($1 !~ "NAME"){printf " "$1" "}'}; printf ")"  )

# Remove any previously running applications and pipelines
oc delete pipelineruns --all
oc delete appsodyapplications --all

#  Clone scripts
rm -rf ./kabanero-pipelines/
git clone https://github.com/kabanero-io/kabanero-pipelines.git

#./kabanero-pipelines/pipelines/incubator/manual-pipeline-runs/manual-pipeline-run-script.sh
#./manual.sh -r https://github.com/kvijai82/kabanero-nodejs -i index.docker.io/smcclem/manual -c nodejs

for collection in "${active_collections[@]}"
do
   echo
   echo "Starting pipeline run for collection: "$collection
   echo
   command="./kabanero-pipelines/pipelines/sample-helper-files/manual-pipeline-run-script.sh -r $git_url/$collection  -i $docker_url/$collection -c $collection"
   echo $command
   eval $command 
   
   # Sample commands used during test
   # retry 10 "oc get pod $pod && [[ \$(oc get pipelinerun $collection"-manual-pipeline-run"--no-headers 2>&1 | grep -c -v -E -q '(Running|Completed|Terminating)') -eq 0 ]]"
   # retry 1000 "oc logs $pod --all-containers | grep -q '$MESSAGE'"
  
   # Wait for the pipeline run to start  
   retry 20 6 "oc get pipelinerun $collection"-manual-pipeline-run" --no-headers 2>&1"
   # Handle error if the pod doesn't start
   
   # Wait for pipeline run to finish
   retry 120 10  "[[ \$(oc get pipelinerun $collection"-manual-pipeline-run" --no-headers 2>&1 |  awk '{ printf \$2 }' | grep -c -v -E '(True|False)') -eq 0 ]]"
   succeeded=$( oc get pipelinerun $collection"-manual-pipeline-run" --no-headers 2>&1 |  awk '{ printf $2 }' )
          
   if [ "$succeeded" != "True" ]; then
      # Piplerun failed, collect logs
      build_pod_id=$( oc get pods | grep $collection.*build-push-task)
      deploy_pod_id=$( oc get pods | grep $collection.*deploy-task)
      declare $( echo $build_pod_id | awk '{printf "build_pod="$1}')
      declare $( echo $deploy_pod_id | awk '{printf "deploy_pod="$1}')
      log_dir=$collection/$(date +%Y-%m-%d-%H-%M-%S)
      mkdir -p $log_dir
      echo
      echo "Pipeline run for collection "$collection" failed. Collecting logs to: "$log_dir", succeeded: "$succeeded
      echo
      oc logs $build_pod --all-containers > $log_dir/$build_pod.log 
      oc logs $deploy_pod --all-containers > $log_dir/$deploy_pod.log 
    else  
      echo
      echo "Pipeline run for collection "$collection" succeeded."    
      echo         
   fi  
   # Delete the pipeline run and application
   oc delete pipelineruns --all
   oc delete appsodyapplications  --all
done
