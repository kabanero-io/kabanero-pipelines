#!/bin/bash
set -e

# setup environment
. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/env.sh

# expose an extension point for running before main 'package' processing
exec_hooks $script_dir/ext/pre_package.d

pipelines_dir=$base_dir/pipelines/incubator
eventing_pipelines_dir=$base_dir/pipelines/incubator/events
gitops_pipelines_dir=$base_dir/pipelines/experimental/gitops

# directory to store assets for test or release
assets_dir=$base_dir/ci/assets
mkdir -p $assets_dir

package() {
    local pipelines_dir=$1
    local prefix=$2
    echo -e "--- Creating pipeline artifacts for $prefix"
    # Generate a manifest.yaml file for each file in the tar.gz file
    asset_manifest=$pipelines_dir/manifest.yaml
    echo "contents:" > $asset_manifest

    # for each of the assets generate a sha256 and add it to the manifest.yaml
    assets_paths=$(find $pipelines_dir -mindepth 1 -maxdepth 1 -type f -name '*')
    local assets_names
    for asset_path in ${assets_paths}
    do
        asset_name=${asset_path#$pipelines_dir/}
        echo "Asset name: $asset_name"
        assets_names="${assets_names} ${asset_name}"
        if [ -f $asset_path ] && [ "$(basename -- $asset_path)" != "manifest.yaml" ]
        then
            sha256=$(cat $asset_path | $sha256cmd | awk '{print $1}')
            echo "- file: $asset_name" >> $asset_manifest
            echo "  sha256: $sha256" >> $asset_manifest
        fi
    done

    # build archive of tekton pipelines
    tar -czf $assets_dir/${prefix}-pipelines.tar.gz -C $pipelines_dir ${assets_names}
    tarballSHA=$(($sha256cmd $assets_dir/${prefix}-pipelines.tar.gz) | awk '{print $1}')
    echo ${tarballSHA}>> $assets_dir/${prefix}-pipelines-tar-gz-sha256
}

package $pipelines_dir "default-kabanero"

package $eventing_pipelines_dir "kabanero-events"

package $gitops_pipelines_dir "kabanero-gitops"

echo -e "--- Created pipeline artifacts"

# expose an extension point for running after main 'package' processing
exec_hooks $script_dir/ext/post_package.d

echo -e "--- Building nginx container"
nginx_arg=
echo "BUILDING: $IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}" > ${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log
if image_build ${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log \
    $nginx_arg \
    -t $IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$INDEX_IMAGE \
    -t $IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION} \
    -f $script_dir/nginx/Dockerfile $script_dir
then
    echo "$IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$INDEX_IMAGE" >> $build_dir/image_list
    echo "$IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}" >> $build_dir/image_list
    echo "created $IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}"
    trace "${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log"
else
    stderr "${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log"
    stderr "failed building $IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}"
    exit 1
fi
