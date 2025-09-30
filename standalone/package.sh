#!/usr/bin/env bash

set -euo pipefail

function usage {
    echo "usage: package.sh [--conda-pack]"
}

function parse_args {
    # positional args
    args=()

    do_conda_pack=0

    # named args
    while (( $# )); do
        case "$1" in
            --conda-pack )      do_conda_pack=1;;
            * )                 usage;           exit;;
        esac
        shift # move to next kv pair
    done
}

parse_args "$@"

if [[ $do_conda_pack -eq 1 ]]; then
    renv_name=magic_renv

    echo "Packaging R virtual env..."
    conda-pack -n ${renv_name} -o ${renv_name}.tar

    echo "Assembling distribution directory..."
    mkdir -p dist/usr/bin dist/usr/share dist/lib

    mv ${renv_name}.tar dist/usr/bin/
fi

# echo "Copying scripts and dependencies..."
# cp -a scripts/* dist/scripts/
# cp -a softwares/* dist/softwares/
# cp -a config.yaml dist/

# echo "Clearing..."
# rm -f ${renv_name}.tar.gz

# echo "Distribution ready in dist/"

export NO_STRIP=1
linuxdeploy-x86_64.AppImage --appdir=dist \
    --executable=dist/usr/bin/softwares/smr \
    --executable=dist/usr/bin/softwares/plink_1.90_beta \
    --desktop-file=dist/usr/share/applications/xmagic.desktop \
    --icon-file=dist/usr/share/icons/hicolor/256x256/apps/xmagic.png \
    --output=appimage \

mv xmagic-x86_64.AppImage xmagic
