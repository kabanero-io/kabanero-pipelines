#!/bin/bash

# Parameters
# [github url] [docker url]


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

# Retries a COMMAND on failure.
# $1 - the max number of attempts
# $2 - the amount of time to sleep between attempts
# $2... - the COMMAND to run
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
            echo "attempt: "$attempt_num
            sleep $sleep_time
            ((attempt_num++))
        fi
    done
    return 0
}


GIT_URL=$1
DOCKER_URL=$2

# Process oc get collections  output to get an array of active collections
declare -a ACTIVE_COLLECTIONS
eval $( printf "ACTIVE_COLLECTIONS=("; oc get collections | awk '{if ($1 !~ "NAME"){printf " "$1" "}'}; printf ")"  )

# Remove any previously running applications and pipelines
oc delete pipelineruns --all
oc delete appsodyapplications --all

#  Clone scripts
rm -rf ./kabanero-pipelines/
git clone https://github.com/kabanero-io/kabanero-pipelines.git

#./kabanero-pipelines/pipelines/incubator/manual-pipeline-runs/manual-pipeline-run-script.sh
#./manual.sh -r https://github.com/kvijai82/kabanero-nodejs -i index.docker.io/smcclem/manual -c nodejs


for COLLECTION in "${ACTIVE_COLLECTIONS[@]}"
do
   echo
   echo "Starting pipeline run for collection: "$COLLECTION
   echo
   COMMAND="./kabanero-pipelines/pipelines/incubator/manual-pipeline-runs/manual-pipeline-run-script.sh -r $GIT_URL/$COLLECTION  -i $DOCKER_URL/$COLLECTION -c $COLLECTION"
   echo $COMMAND
   eval $COMMAND 
   
   # Sample COMMANDs used during test
   # retry 10 "oc get pod $POD && [[ \$(oc get pipelinerun $COLLECTION"-manual-pipeline-run"--no-headers 2>&1 | grep -c -v -E -q '(Running|Completed|Terminating)') -eq 0 ]]"
   # retry 1000 "oc logs $POD --all-containers | grep -q '$MESSAGE'"
  

   # Wait for the pipeline run to start  
   retry 10 6 "oc get pipelinerun $COLLECTION"-manual-pipeline-run" --no-headers 2>&1"
   # Handle error if the pod doesn't start
   
   # Wait for pipeline run to finish
   retry 60 10  "[[ \$(oc get pipelinerun $COLLECTION"-manual-pipeline-run" --no-headers 2>&1 |  awk '{ printf \$2 }' | grep -c -v -E '(True|False)') -eq 0 ]]"
   SUCCEEDED=$( oc get pipelinerun $COLLECTION"-manual-pipeline-run" --no-headers 2>&1 |  awk '{ printf $2 }' )
          
   if [ "$SUCCEEDED" != "True" ]; then
      # Piplerun failed, collect logs
      POD_ID=$( oc get pods | grep $COLLECTION.*build-task)
      declare $( echo $POD_ID| awk '{printf "POD="$1}')
      LOG_DIR=$COLLECTION/$(date +%Y-%m-%d-%H-%M-%S)
      mkdir -p $LOG_DIR
      echo
      echo "Pipline run for collection "$COLLECTION" failed. Collecting logs to: "$LOG_DIR
      echo
      oc logs $POD --all-containers > $LOG_DIR/$POD.log 
    else  
      echo
      echo "Pipline run for collection "$COLLECTION" succeeded."    
      echo         
   fi  

   # Delete the pipeline run and application
   oc delete pipelineruns --all
   oc delete appsodyapplications  --all
   
done

