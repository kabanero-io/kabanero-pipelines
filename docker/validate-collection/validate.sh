#!/bin/bash

# This script looks in the .appsody-config.xml file, which is part of an Appsody application,
# for the stack: values, which is the base docker image that will be used to build the 
# Appsody application upon. This docker image must belong to a Kabanero collection that is 
# active on the current system that we are running on. 

# gitsource variable is supplied by the caller.
cd /workspace/$gitsource

appsody_config=".appsody-config.yaml"

if [ ! -f "$appsody_config" ]; then
   echo $appsody_config" is not found in the root of the source directory. Unable to validate if the collection is active."
   exit 1
fi

# Find the value for "stack:" from the appsody config file and assign it to the variable 'stack'
declare $( awk '{if ($1 ~ "stack:"){printf "stack="$2}}'  $appsody_config )

if [ -z "$stack" ]; then
   echo "$appsody_config does not contain a stack: definition. Unable to validate if the collection is active."
   exit 1
else
   
   # declare $( kubectl describe collections | awk '{if ($1 ~ "stack:"){printf "image="$2}}')
   # Simple grep of the entire metadata stack for all the active collection image,
   # might want to refine or extend 
   kubectl describe collections | grep -q $stack 
   if [ $? -eq 0 ]; then
      # The Kabanero collection was found as active
      exit 0 
   else
      echo "The Kabanero collection contained in "$stack" is not active on this system and cannot be built."
      exit 1
   fi
fi
