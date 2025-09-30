#!/usr/bin/env sh

set -e

############
# Clumping #
############

CONFIG=$1
chr1=$2
chr2=$3

mkdir -p ${OUTPUT}/Clumping/detail
mkdir -p ${OUTPUT}/Clumping/summary

# ----
for i in $(seq $chr1 $chr2)
do

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

done

awk 'NR==1 || FNR>1' ${OUTPUT}/Clumping/detail/${trait_name}_chr*.clumped > ${OUTPUT}/Clumping/summary/${trait_name}.clumped 

# ------------------------------------------------------------------------
#  Clumping results
# ------------------------------------------------------------------------

${R_BIN} ${SCRIPT_DIR}/R_functions/Clumping_step2_results.R ${trait_name} ${OUTPUT}
