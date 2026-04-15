#!/bin/bash

cur_dir="$(builtin cd "`dirname "${BASH_SOURCE[0]}"`" > /dev/null && pwd)"
sdk_dir=$(dirname "$cur_dir")

# Delete log and install files
rm -rf $sdk_dir/log
rm -rf $sdk_dir/install/lib/$1
rm -rf $sdk_dir/install/include/$1
rm -rf $sdk_dir/install/share/$1

if [[ -z "$2" ]]; then
    build_type=release
else
    build_type=$2
fi

source /opt/ros/humble/setup.bash
cd $sdk_dir && colcon build --packages-select $1 --merge-install --mixin $build_type --cmake-clean-cache --cmake-clean-first
