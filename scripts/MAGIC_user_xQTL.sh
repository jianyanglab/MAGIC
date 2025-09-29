#!/bin/bash
set -e

# ------------------------------------------------------------------------
#  Input
# ------------------------------------------------------------------------
CONFIG=$1
SCRIPT_DIR=`yq .script.path "${CONFIG}"`
GWAS_DATA=`yq .input.gwas "${CONFIG}"`
trait_name=`yq .input.trait "${CONFIG}"`
OUTPUT=`yq .input.output "${CONFIG}"`
user_xQTL_link_consensus=`yq .input.user_xQTL_link_consensus "${CONFIG}"`
user_xQTL_name_list=`yq .input.user_xQTL_name_list "${CONFIG}"`


mkdir -p ${OUTPUT}/MAGIC/plot
mkdir -p ${OUTPUT}/MAGIC/summary
mkdir -p ${OUTPUT}/MAGIC/gwas
mkdir -p ${OUTPUT}/MAGIC/results

# ------------------------------------------------------------------------
#  MAGIC analysis
# ------------------------------------------------------------------------
magic_functions_file=`yq .magic.R_functions "${CONFIG}"`
gencode_file=`yq .gene.gencode "${CONFIG}"`
CpG_link_file=`yq .magic.CpG_link "${CONFIG}"`
hQTL_link_file=`yq .magic.hQTL_link "${CONFIG}"`
caQTL_link_file=`yq .magic.caQTL_link "${CONFIG}"`
reference_bim_file=`yq .reference.reference_all_bim "${CONFIG}"`

# env=`yq .environment.R_421 "${CONFIG}"`
# source activate ${env}

Rscript ${SCRIPT_DIR}/MAGIC.R \
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


