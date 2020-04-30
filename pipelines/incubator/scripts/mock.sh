#!/bin/bash 

skopeo () {
  cat skopeo.txt
}

kubectl () {
   if [[ "$2" == "stack" ]]; then
      cat kubectl_stack.txt
      return
   fi
   if [[ "$2" == "kabanero" ]]; then
      cat kubectl_kabanero.txt
      return
   fi
   echo "ERROR: Unknown option"
   exit 1
}

eval . $@

