#!/usr/bin/env sh

set -e

CONFIG=$1

mkdir -p ${OUTPUT}/MAGIC/plot
mkdir -p ${OUTPUT}/MAGIC/summary
mkdir -p ${OUTPUT}/MAGIC/gwas

# ------------------------------------------------------------------------
#  MAGIC analysis
# ------------------------------------------------------------------------
magic_functions_file=$(realpath --relative-to=${MAGIC_ROOT} -- $(yq -r .magic.R_functions ${CONFIG}))
gencode_file=$(realpath --relative-to=${MAGIC_ROOT} -- $(yq -r .gene.gencode ${CONFIG}))
CpG_link_file=$(realpath --relative-to=${MAGIC_ROOT} -- $(yq -r .magic.CpG_link ${CONFIG}))
hQTL_link_file=$(realpath --relative-to=${MAGIC_ROOT} -- $(yq -r .magic.hQTL_link ${CONFIG}))
caQTL_link_file=$(realpath --relative-to=${MAGIC_ROOT} -- $(yq -r .magic.caQTL_link ${CONFIG}))
reference_bim_file=$(realpath --relative-to=${MAGIC_ROOT} -- $(yq -r .reference.reference_all_bim ${CONFIG}))

${R_BIN} ${SCRIPT_DIR}/MAGIC.R \
    ${trait_name} \
    ${OUTPUT} \
    ${magic_functions_file} \
    ${gencode_file} \
    ${user_xQTL_link_consensus} \
    ${user_xQTL_link_consensus} \
    ${user_xQTL_link_consensus} \
    ${GWAS_DATA} \
    ${reference_bim_file}
