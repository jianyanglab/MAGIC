#!/usr/bin/env sh

set -e

############
# Clumping #
############

mkdir -p ${OUTPUT}/MAGIC/Clumping/detail
mkdir -p ${OUTPUT}/MAGIC/Clumping/summary

# ----
for i in $(seq 1 22)
do

${plink1_9} \
    --bfile ${REFERENCE}_chr${i} \
    --chr ${i} \
    --maf 0.01 \
    --clump ${GWAS_DATA} \
    --clump-p1 5e-8 \
    --clump-p2 5e-8 \
    --clump-r2 0.05 \
    --clump-kb 1000 \
    --clump-snp-field SNP \
    --clump-field P \
    --out ${OUTPUT}/MAGIC/Clumping/detail/${trait_name}_chr${i}

done

awk 'NR==1 || FNR>1' ${OUTPUT}/MAGIC/Clumping/detail/${trait_name}_chr*.clumped > ${OUTPUT}/MAGIC/Clumping/summary/${trait_name}.clumped

# ------------------------------------------------------------------------
#  Clumping results
# ------------------------------------------------------------------------

${R_BIN} ${SCRIPT_DIR}/R_functions/Clumping_step2_results.R ${trait_name} ${OUTPUT}

