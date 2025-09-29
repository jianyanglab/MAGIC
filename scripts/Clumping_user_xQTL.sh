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

mkdir -p ${OUTPUT}/Clumping/detail
mkdir -p ${OUTPUT}/Clumping/summary

# ------------------------------------------------------------------------
#  Clumping analysis
# ------------------------------------------------------------------------
plink1_9=`yq .software.plink1_9 "${CONFIG}"`
REFERENCE=`yq .reference.reference_bfile "${CONFIG}"`

# ----
# for i in $(seq 1 22)
# do
i=11
${plink1_9} \
    --bfile ${REFERENCE}${i} \
	--chr ${i} \
	--maf 0.01 \
    --clump ${GWAS_DATA} \
    --clump-p1 5e-8 \
    --clump-p2 5e-8 \
    --clump-r2 0.05 \
    --clump-kb 1000 \
    --clump-snp-field SNP \
    --clump-field P \
    --out ${OUTPUT}/Clumping/detail/${trait_name}_chr${i}

# done

awk 'NR==1 || FNR>1' ${OUTPUT}/Clumping/detail/${trait_name}_chr*.clumped > ${OUTPUT}/Clumping/summary/${trait_name}.clumped 


# ------------------------------------------------------------------------
#  Clumping results
# # ------------------------------------------------------------------------
# gencode=`yq .gene.gencode "${CONFIG}"`
# env=`yq .environment.R_421 "${CONFIG}"`
# source activate $env

Rscript ${SCRIPT_DIR}/R_functions/Clumping_step2_results.R ${trait_name} ${OUTPUT}

# For any user defined locus range, you can just change the number in the following script.
# Rscript ${SCRIPT_DIR}/R_functions/Clumping_step2_results_locus_window.R ${trait_name} ${OUTPUT} 1000000 ${gencode}