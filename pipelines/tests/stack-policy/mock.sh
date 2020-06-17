#!/bin/bash 

skopeo () {
  cat /workspace/$gitsource/pipelines/tests/stack-policy/skopeo.txt
}

kubectl () {
   if [[ "$2" == "stack" ]]; then
      cat /workspace/$gitsource/pipelines/tests/stack-policy/kubectl_stack.txt
      return
   fi
   if [[ "$2" == "kabanero" ]]; then
      cat /workspace/$gitsource/pipelines/tests/stack-policy/kubectl_kabanero.txt
      return
   fi
   echo "ERROR: Unknown option"
   exit 1
}

eval . $@

