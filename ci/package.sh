#!/bin/bash
set -e

base_dir="/home/travis/build/kabanero/kabanero-pipelines"
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
asset_manifest=$assets_dir/manifest.yaml
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
tar -czf $assets_dir/default-kabanero-pipelines.tar.gz $pipelines_dir/*.yaml $asset_manifest
echo -e "--- Created kabanero-pipelines.tar.gz"
rm $asset_manifest
