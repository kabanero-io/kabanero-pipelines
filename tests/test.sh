#!/bin/bash

# Prerequisites
# -------------
# 1. This script needs to be directly run on a OKD/OpenShift env that already had the Kabanero operator installed. 
# 2. The Kab operator has activated all the collections that are needed
# 3. A github and docker account are needed. This script will create repositories with the Kabanero collection name, 
#    so it assumed that for these provided accounts, these repo names are available to be overwritten.
# 4. The manual pipeline instructions have been followed. That means a pv.yaml and secret.yaml have been applied
#    to create a persistent volume and docker secret for my-docker-secret

# Notes:
# ------
# 1. This script should possibly be pulled via curl from github (or github cloned) each time it is run. 

# oc get collections formatting:

# NAME                AGE
# java-microprofile   4d
# java-spring-boot2   4d
# nodejs              4d
# nodejs-express      4d
# nodejs-loopback     4d


# Wait until a pod is Running,Complete or Terminating
# wait_for_ready [pod] [timeout] <sleepTime>
# <sleepTime> is optional
function wait_for_ready_pod() {
  if [ -z "$1" ] || [ -z "$2" ]; then
      echo "Usage ERROR for function: wait_for_ready_pods [namespace] [timeout] <sleepTime>"
      [ -z "$1" ] && echo "Missing [namespace]"
      [ -z "$2" ] && echo "Missing [timeout]"
      exit 1
  fi
  POD=$1
  timeout_period=$2
  echo "pod: "$POD
  retry 10 "oc get pod $POD && [[ \$(oc get pod -n $POD --no-headers 2>&1 | grep -c -v -E -q '(Running|Completed|Terminating)') -eq 0 ]]"
  return $?
}

function wait_for_log_message() {
  if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
      echo "Usage ERROR for function: wait_for_log_message [pod] [message] [timeout] <sleepTime>"
      [ -z "$1" ] && echo "Missing [pod]"
      [ -z "$2" ] && echo "Missing [message]"
      [ -z "$3" ] && echo "Missing [timeout]"
      exit 1
  fi
  MESSAGE=$2
  POD=$1
  echo "MESSAGE: "$MESSAGE
  retry 1000 "oc logs $POD --all-containers | grep -q '$MESSAGE'"
  return $?
 }




# Retries a command on failure.
# $1 - the max number of attempts
# $2... - the command to run
function retry() {
    local -r -i max_attempts="$1"; shift
    local -r cmd="$@"
    local -i attempt_num=1
    
    echo "command: "$cmd

    until eval $cmd
    do
        rc=$?
        if (( attempt_num == max_attempts ))
        then
            echo "Attempt $attempt_num failed and there are no more attempts left!"
            return $rc
        else
            echo "Attempt $attempt_num failed! Trying again in $attempt_num seconds..."
            sleep $(( attempt_num++ ))
        fi
    done
}





# process oc get collections  output to get an array of active collections
declare -a ACTIVE_COLLECTIONS
eval $( printf "ACTIVE_COLLECTIONS=("; oc get collections | awk '{if ($1 !~ "NAME"){printf " "$1" "}'}; printf ")"  )

rm -rf kabanero-pipelines/
git clone https://github.com/kabanero-io/kabanero-pipelines.git


#./kabanero-pipelines/pipelines/incubator/manual-pipeline-runs/manual-pipeline-run-script.sh
#./manual.sh -r https://github.com/kvijai82/kabanero-nodejs -i index.docker.io/smcclem/manual -c nodejs
for COLLECTION in "${ACTIVE_COLLECTIONS[@]}"
do
   echo "Starting pipeline run for collectin: "$COLLECTION
   command="./kabanero-pipelines/pipelines/incubator/manual-pipeline-runs/manual-pipeline-run-script.sh -r https://github.com/smcclem/$COLLECTION  -i index.docker.io/smcclem/$COLLECTION -c $COLLECTION"
   echo $command
   eval $command 
   sleep 30
   # Get the pipeline pod id   
   POD_ID=$( oc get pods | grep $COLLECTION.*build-task)
   declare $( echo $POD_ID| awk '{printf "POD="$1}')
   # Wait for the pod to start
   wait_for_ready_pod $POD 100 10
   # Wait for the build to complete successfully
   wait_for_log_message $POD "\[INFO\] BUILD SUCCESS" 0
   # If the build didn't finish in time, collect the logs
   if [ $? -ne 0]; then
      LOG_DIR=$COLLECTION/$(date +%Y-%m-%d-%H-%M-%S)
      mkdir -p $LOG_DIR
      echo "Build for collection: "$COLLECTION" failed."
      echo "Storing logs: " $LOG_DIR
      oc logs $POD --all-containers > $LOG_DIR/$POD.log          
   fi 
   # Remove the pipeline runs and application
   oc delete pipelineruns --all
   oc delete appsodyapplications  --all   
done