#!/bin/bash

# setup environment
. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../env.sh

openshift_deployment() {
    YAML_FILE=$build_dir/openshift.yaml
    cp $base_dir/ci/tekton/openshift.yaml $YAML_FILE

    sed -i -e '/host:/d' $YAML_FILE
    sed -i -e "s/REGISTRY/$IMAGE_REGISTRY/" $YAML_FILE
    sed -i -e "s/NAMESPACE/$IMAGE_REGISTRY_ORG/" $YAML_FILE
    sed -i -e "s/IMAGE/$INDEX_IMAGE/" $YAML_FILE
    sed -i -e "s/TAG/$INDEX_VERSION/" $YAML_FILE
    sed -i -e "s/DATE/$(date -u '+%FT%TZ')/" $YAML_FILE
}

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

    # generate openshift deployment yaml file
    openshift_deployment
else
    stderr "${build_dir}/image.$INDEX_IMAGE.${INDEX_VERSION}.log"
    stderr "failed building $IMAGE_REGISTRY/$IMAGE_REGISTRY_ORG/$INDEX_IMAGE:${INDEX_VERSION}"
    exit 1
fi