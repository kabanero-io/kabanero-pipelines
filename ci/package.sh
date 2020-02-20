#!/bin/bash
set -e

# setup environment
. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/env.sh

# expose an extension point for running before main 'package' processing
exec_hooks $script_dir/ext/pre_package.d

pipelines_dir=$base_dir/pipelines/incubator

# directory to store assets for test or release
assets_dir=$base_dir/ci/assets
mkdir -p $assets_dir

if [[ "$OSTYPE" == "darwin"* ]]; then
    sha256cmd="shasum --algorithm 256"    # Mac OSX
else
    sha256cmd="sha256sum "  # other OSs
fi

# Generate a manifest.yaml file for each file in the tar.gz file
asset_manifest=$pipelines_dir/manifest.yaml
echo "contents:" > $asset_manifest

# for each of the assets generate a sha256 and add it to the manifest.yaml
for asset_path in $(find $pipelines_dir -type f -name '*')
do
    asset_name=${asset_path#$pipelines_dir/}
    echo "Asset name: $asset_name"
    if [ -f $asset_path ] && [ "$(basename -- $asset_path)" != "manifest.yaml" ]
    then
        sha256=$(cat $asset_path | $sha256cmd | awk '{print $1}')
        echo "- file: $asset_name" >> $asset_manifest
        echo "  sha256: $sha256" >> $asset_manifest
    fi
done

# build archive of pipelines
tar -czf $assets_dir/default-kabanero-pipelines.tar.gz -C $pipelines_dir .
echo -e "--- Created kabanero-pipelines.tar.gz"

# expose an extension point for running after main 'package' processing
exec_hooks $script_dir/ext/post_package.d

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
