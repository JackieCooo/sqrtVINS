#!/bin/bash

cur_dir="$(builtin cd "`dirname "${BASH_SOURCE[0]}"`" > /dev/null && pwd)"
sdk_dir=$(dirname "$cur_dir")
output_dir=$sdk_dir/output

if [[ -z "$1" ]]; then
    package_name=$(basename "$sdk_dir")
else
    package_name=$1
fi
target_dir=$output_dir/$package_name
echo "Package will be saved at $target_dir"

mkdir -p $output_dir

echo "Deleting old package..."
rm -rf $target_dir
rm -f $output_dir/$package_name.tar.gz
echo "Done"

echo "Copying package components..."
mkdir -p $target_dir

cp -dr $sdk_dir/install $target_dir
cp $sdk_dir/launch.sh $target_dir

chmod 777 -R $target_dir
echo "Done"

echo "Packing new package..."
cd $output_dir && tar -czf $output_dir/$package_name.tar.gz $package_name
echo "Done"
