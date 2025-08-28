#!/bin/bash
# set -e

# ------------------------------------------------------------------------
#  Input
# ------------------------------------------------------------------------
CONFIG=$1
SCRIPT_DIR=`yq .script.path "${CONFIG}"`
GWAS_DATA=`yq .input.gwas "${CONFIG}"`
trait_name=`yq .input.trait "${CONFIG}"`
OUTPUT=`yq .input.output "${CONFIG}"`

mkdir -p ${OUTPUT}/MAGIC/SMR/detail
mkdir -p ${OUTPUT}/MAGIC/SMR/summary

# ------------------------------------------------------------------------
#  SMR analysis
# ------------------------------------------------------------------------

SMR=`yq .software.smr "${CONFIG}"`
REFERENCE_bld=`yq .reference.reference_bld "${CONFIG}"`
# QTL_list=`yq .magic.QTL_list "${CONFIG}"`
QTL_list=`yq .magic.QTL_list_lite_new "${CONFIG}"`

# ----
qtl_i=${SLURM_ARRAY_TASK_ID}
# **** Here we take qtl as a unit. In total 230 xQTL datasets.
# 1-149: eQTL
# 150-200: sQTL
# 201-206: pQTL
# 207-217: mQTL
# 218-224: hQTL
# 225-229: caQTL

qtl_name=`head -n ${qtl_i} ${QTL_list} | tail -n1 | awk -F "\t" '{print $1}'`
qtl_data=`head -n ${qtl_i} ${QTL_list} | tail -n1 | awk -F "\t" '{print $2}'`
qtl_chr=`head -n ${qtl_i} ${QTL_list} | tail -n1 | awk -F "\t" '{print $3}'`

echo "smr=${SMR}"
echo "qtl_name=${qtl_name}"
echo "qtl_data=${qtl_data}"
echo "qtl_chr=${qtl_chr}"

module load gcc intelmkl

# export OMP_DISPLAY_ENV=TRUE
if grep -q "AuthenticAMD" /proc/cpuinfo; then
    echo "export MKL_DEBUG_CPU_TYPE=5"
    export MKL_DEBUG_CPU_TYPE=5
fi

"${SMR}" --bld "${REFERENCE_bld}_chr" \
    --gwas-summary "${GWAS_DATA}" \
    --beqtl-list "${QTL_list}" \
    --beqtl-list-index ${qtl_i} \
    --maf 0.01 \
    --smr-multi \
    --thread-num 4 \
    --out "${OUTPUT}/MAGIC/SMR/detail/${trait_name}"

awk 'NR==1 || FNR>1' ${OUTPUT}/MAGIC/SMR/detail/${trait_name}_${qtl_name}_chr*.msmr > ${OUTPUT}/MAGIC/SMR/summary/${trait_name}_${qtl_name}_chrALL.msmr

rm ${OUTPUT}/MAGIC/SMR/detail/${trait_name}_${qtl_name}_chr*
