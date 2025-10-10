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

echo "Copying scripts and dependencies..."
mkdir -p dist/usr/bin
mkdir -p dist/usr/lib
mkdir -p dist/usr/share

cp -a scripts dist/usr/bin/
cp -a softwares dist/usr/bin/
cp -a config.yaml dist/usr/bin/
cp -a run.sh  dist/usr/bin/

cp -a resources/applications dist/usr/share/
cp -a resources/icons dist/usr/share/
cp -a resources/magic_renv.tar dist/usr/share/
cp -a resources/GRCh38.genome dist/usr/share/
cp -a resources/BED_ukbEUR_imp_v3_INFO0.8_maf0.01_mind0.05_geno0.05_hwe1e6_10K_hg38_chrALL.bim dist/usr/share/
cp -a resources/gencode.v40.GRCh38.gene.annotation.bed dist/usr/share/

cp -a resources/CpG_consensus_all.link dist/usr/share/
cp -a resources/hQTL_consensus_all.link dist/usr/share/
cp -a resources/caQTL_consensus_all.link dist/usr/share/

cp -a resources/AppRun dist/

export NO_STRIP=1
linuxdeploy-x86_64.AppImage --appdir=dist \
    --desktop-file=dist/usr/share/applications/xmagic.desktop \
    --icon-file=dist/usr/share/icons/hicolor/256x256/apps/xmagic.png \
    --output=appimage \

mv xmagic-x86_64.AppImage xmagic
