#!/bin/bash

# setup environment
. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/env.sh

# expose an extension point for running before main 'release' processing
exec_hooks $script_dir/ext/pre_release.d

image_registry_login

if [ -f $build_dir/image_list ]
then
    while read line
    do
        if [ "$line" != "" ]
        then
            image_push $line
        fi
    done < $build_dir/image_list
fi

# expose an extension point for running after main 'release' processing
exec_hooks $script_dir/ext/post_release.d
