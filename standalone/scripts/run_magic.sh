#!/usr/bin/env bash

set -euo pipefail

CONFIG=$1

mkdir -p ${OUTPUT}/MAGIC/plot
mkdir -p ${OUTPUT}/MAGIC/summary
mkdir -p ${OUTPUT}/MAGIC/gwas
mkdir -p ${OUTPUT}/MAGIC/results

# ------------------------------------------------------------------------
#  MAGIC analysis
# ------------------------------------------------------------------------
magic_functions_file=${MAGIC_ROOT}/$(yq -r .magic.R_functions ${CONFIG})
gencode_file=$(yq -r .gene.gencode ${CONFIG})
CpG_link_file=$(yq -r .magic.CpG_link ${CONFIG})
hQTL_link_file=$(yq -r .magic.hQTL_link ${CONFIG})
caQTL_link_file=$(yq -r .magic.caQTL_link ${CONFIG})
reference_bim_file=$(yq -r .reference.reference_all_bim ${CONFIG})
user_xQTL_name_list=$(yq -r .input.user_xQTL_name_list ${CONFIG})
user_xQTL_link_consensus=$(yq -r .input.user_xQTL_link_consensus ${CONFIG})

echo "magic_functions_file=${magic_functions_file}"
echo "gencode_file=${gencode_file}"
echo "CpG_link_file=${CpG_link_file}"
echo "hQTL_link_file=${hQTL_link_file}"
echo "caQTL_link_file=${caQTL_link_file}"
echo "reference_bim_file=${reference_bim_file}"
echo "user_xQTL_name_list=${user_xQTL_name_list}"

${R_BIN} ${SCRIPT_DIR}/MAGIC.R \
    ${trait_name} \
    ${OUTPUT} \
    ${magic_functions_file} \
    ${gencode_file} \
    ${user_xQTL_link_consensus} \
    ${user_xQTL_link_consensus} \
    ${user_xQTL_link_consensus} \
    ${GWAS_DATA} \
    ${reference_bim_file} \
    ${user_xQTL_name_list}
