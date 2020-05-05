#!/bin/sh
# This script will be used in later tasks to fetch the trusted cs certificates configured 
# in a configmap which is set in the 'image.config.openshift.io/cluster' resource by the user, and we will copy the certificate values and generate 'ca.crt' as '/etc/docker/certs.d/<hostname>/ca.crt' for each certificate on the container.
# Reference Redhat documentation link : https://docs.openshift.com/container-platform/4.2/openshift_images/image-configuration.html

#We find if cluster resource 'image.config.openshift.io/cluster' has any additional_trusted_ca setup by user
#If yes we pull the certificate values from the configmap setup there and create ca.crt files for each hostname with 
#the certificate value given by the user in location '/etc/docker/certs.d/[hostname]/ca.crt'
additonal_trusted_CA=$(kubectl get image.config.openshift.io/cluster -o yaml --output="jsonpath={.spec.additionalTrustedCA.name}")

if [[ ! -z "$additonal_trusted_CA" ]]; then
   echo "additonal_trusted_CA=$additonal_trusted_CA found in the image.config.openshift.io/cluster resource, setting up the certificates in /etc/docker/certs.d/ location"        
   config_map_key_count=$(kubectl get configmap $additonal_trusted_CA -n openshift-config -o json | jq '.data' | jq 'keys | length')

   for ((i=0;i<config_map_key_count;i++));do
       key=$(kubectl get configmap $additonal_trusted_CA -n openshift-config -o json | jq '.data' | jq 'keys['"$i"']')

       #sed command to remove double quotes from beginning and the end of the above key(example key="abc.pqr.com") variable value
       key=$(sed -e 's/^"//' -e 's/"$//' <<<$key)

       #sed command to replace '.' with '\.' to escape it while using ahead to fetch that key's value from the map
       key_hostname_with_escaped_dot=$(sed -e 's/\./\\./g' <<< "$key")
       cert_value=$(kubectl get configmap $additonal_trusted_CA -n openshift-config --output="jsonpath={.data.$key_hostname_with_escaped_dot}")

       #sed command to update the configmap key to replace '..' with ':' example 'image-registry.openshift-image-registry.svc..5000' to image-registry.openshift-image-registry.svc:5000
       key=$(sed -e 's/\.\./:/g' <<< "$key")
       mkdir -p /etc/docker/certs.d/$key
       echo "$cert_value" | sudo tee -a /etc/docker/certs.d/$key/ca.crt
   done
fi
