#!/usr/bin/env sh

set -e

renv_name=magic_renv

echo "Packaging R virtual env..."
rm -f ${renv_name}.tar.gz
conda-pack -n ${renv_name} -o ${renv_name}.tar.gz

echo "Assembling distribution directory..."
rm -rf dist
mkdir -p dist/env dist/scripts dist/softwares

echo "Unpacking env into dist..."
tar -xzf ${renv_name}.tar.gz -C dist/env
if [[ -x "dist/env/bin/conda-unpack" ]]; then
    dist/env/bin/conda-unpack
fi

echo "Copying scripts and dependencies..."
cp -a scripts/* dist/scripts/
cp -a softwares/* dist/softwares/
cp -a config.yaml dist/

echo "Clearing..."
rm -f ${renv_name}.tar.gz

echo "Distribution ready in dist/"

