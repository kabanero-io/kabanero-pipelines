#!/bin/bash

if [ ! -z "$assets_dir" ]
then
    # we've been here before
    return 0
fi

export script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export base_dir=$(cd "${script_dir}/.." && pwd)
export assets_dir="${script_dir}/assets"
export build_dir="${script_dir}/build"

mkdir -p $assets_dir
mkdir -p $build_dir

# ENVIRONMENT VARIABLES for controlling behavior of build, package, and release

# Publish images to image registry
# export IMAGE_REGISTRY_PUBLISH=false

# Credentials for publishing images:
# export IMAGE_REGISTRY
# export IMAGE_REGISTRY_USERNAME
# export IMAGE_REGISTRY_PASSWORD

# Organization for images
# export IMAGE_REGISTRY_ORG=kabanero

# Name of pipelines-index image (ci/package.sh)
# export INDEX_IMAGE=pipelines-index

# Version or snapshot identifier for pipelines-index (ci/package.sh)
# export INDEX_VERSION=SNAPSHOT

# Use buildah instead of docker to build and push docker images when the value is true
# export USE_BUILDAH=false

# Specify a wrapper where required for long-running commands
CI_WAIT_FOR=

# Show output of commands
if [ -z $VERBOSE ]; then
    VERBOSE=false
fi

exec_hooks() {
    local dir=$1
    if [ -d $dir ]
    then
        echo " == Running $(basename $dir) scripts"
        for x in $dir/*
        do
            if [ -x $x ]
            then
                . $x
            else
                echo skipping $(basename $x)
            fi
        done
        echo " == Done $(basename $dir) scripts"
    fi
}

stderr() {
    if [ -f "$1" ]
    then
        if [ "${VERBOSE}" = "true" ]
        then
            >&2 cat "$1"
        else
            # Work around CI log limits
            >&2 echo -e "\n--- Output (at most 4000 lines) ---"
            >&2 tail -n 4000 "$1"
            >&2 echo "--- ---"
        fi
    else
        >&2 echo "$1"
    fi
}

trace() {
    if [ -f "$1" ]
    then
        if [ "${VERBOSE}" = "true" ]
        then
            cat "$1"
        else
            # Work around CI log limits
            echo -e "\n--- Output (at most 4000 lines) ---"
            tail -n 4000 "$1"
            echo "--- ---"
        fi
    else
        echo "$1"
    fi
}

logged() {
    local log=$1
    shift

    if [ "${CI_WAIT_FOR}" = "true" ]
    then
        # check every 30 seconds for a max of 40 minutes
        $script_dir/ci_wait.sh --interval 30 --limit 2400 --append 1 --output "$log" $@
    elif [ -n "${CI_WAIT_FOR}" ]
    then
        # custom interval/limit for environment
        ${CI_WAIT_FOR} --append 1 --output "$log" $@
    else
        $@ >> ${log} 2>&1
    fi
}

#expose an extension point for running before main 'env' processing
exec_hooks $script_dir/ext/pre_env.d

# image registry org for publishing stack
if [ -z "$IMAGE_REGISTRY_ORG" ]
then
    export IMAGE_REGISTRY_ORG=kabanero
fi

# image registry for publishing stack
if [ -z "$IMAGE_REGISTRY" ]
then
    export IMAGE_REGISTRY=docker.io
fi

if [ -z "$INDEX_IMAGE" ]
then
    export INDEX_IMAGE=pipelines-index
fi

if [ -z "$INDEX_VERSION" ]
then
    export INDEX_VERSION=SNAPSHOT
fi

if [ -z "$USE_BUILDAH" ]
then
    export USE_BUILDAH=false
fi

if [ -z "$IMAGE_REGISTRY_PUBLISH" ]
then
    export IMAGE_REGISTRY_PUBLISH=false
fi

image_build() {
    local log=$1
    shift 

    local cmd="docker build"
    if [ "$USE_BUILDAH" == "true" ]; then
        cmd="buildah bud"
    fi

    if ! logged "${log}" ${cmd} $@
    then
      echo "Failed building image"
      exit 1
    fi
}

image_tag() {
    if [ "$USE_BUILDAH" == "true" ]; then
        echo "> buildah tag $@"
        buildah tag $1 $2
    else
        echo "> docker tag $@"
        docker tag $1 $2
    fi
}

image_push() {
    if [ "$IMAGE_REGISTRY_PUBLISH" == "true" ]
    then
        local name=$@

        echo "Pushing $name"
        if [ "$USE_BUILDAH" == "true" ]; then
            buildah push --tls-verify=false $name
        else
            docker push $name
        fi

        if [ $? -ne 0 ]
        then
            stderr "ERROR: Push failed."
            exit 1
        fi
    else
        echo "IMAGE_REGISTRY_PUBLISH=${IMAGE_REGISTRY_PUBLISH}; Skipping push of $@"
    fi
}

image_registry_login() {
    if [ "$IMAGE_REGISTRY_PUBLISH" == "true" ] && [ -n "$IMAGE_REGISTRY_PASSWORD" ]
    then
        if [ "$USE_BUILDAH" == "true" ]
        then
            echo "$IMAGE_REGISTRY_PASSWORD" | buildah login -u "$IMAGE_REGISTRY_USERNAME" --password-stdin "$IMAGE_REGISTRY"
        else
            echo "$IMAGE_REGISTRY_PASSWORD" |  docker login -u "$IMAGE_REGISTRY_USERNAME" --password-stdin "$IMAGE_REGISTRY"
        fi

        if [ $? -ne 0 ]
        then
            stderr "ERROR: Registry login failed. Will not push images to registry."
            export IMAGE_REGISTRY_PUBLISH=false
        fi
    fi
}

#expose an extension point for running after main 'env' processing
exec_hooks $script_dir/ext/post_env.d
