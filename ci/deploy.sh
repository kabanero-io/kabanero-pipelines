#!/bin/bash -e

. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/env.sh

prereqs() {
    command -v oc >/dev/null 2>&1 || { echo "Unable to deploy pipelines-index: oc is not installed."; exit 1; }
}

get_route() {
    for i in 1 2 3 4 5 6 7 8 9 10; do
        ROUTE=$(oc get route pipelines-index --no-headers -o=jsonpath='{.status.ingress[0].host}')
        if [ -z "$ROUTE" ]; then
            sleep 1
        else
            echo "https://$ROUTE"
            return
        fi
    done
    echo "Unable to get route for pipelines-index"
    exit 1
}

# check needed tools are installed
prereqs

# deploy nginx container
if [ -f "$build_dir/openshift.yaml" ]; then
    echo "= Deploying pipelines index container into your cluster."
    oc apply -f "$build_dir/openshift.yaml"

    PIPELINES_INDEX_ROUTE=$(get_route)
    echo "== Your pipelines index is available at: $PIPELINES_INDEX_ROUTE/default-kabanero-pipelines.tar.gz"
    echo "== Your pipelines index is available at: $PIPELINES_INDEX_ROUTE/kabanero-events-pipelines.tar.gz"
fi