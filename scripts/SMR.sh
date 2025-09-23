#!/bin/bash
# set -e

# ------------------------------------------------------------------------
#  Input
# ------------------------------------------------------------------------
CONFIG=$1
# OUTPUT should be in directory `/data`

SMR=`yq .software.smr "${CONFIG}"`
trait_name=`yq .input.trait "${CONFIG}"`
RESULT_OUTPUT=`yq .input.output "${CONFIG}"`

GWAS_DATA=`yq .input.gwas "${CONFIG}"`
QTL_list=`yq .magic.QTL_list "${CONFIG}"`
REFERENCE_bld=`yq .reference.reference_bld "${CONFIG}"`

# copy data to the `/data/<job_id>/`
cache_dir="/data/${SLURM_JOB_ID}"
mkdir -p ${cache_dir}

time {
  cp "${GWAS_DATA}"      ${cache_dir}/
  cp "${QTL_list}"       ${cache_dir}/
  cp "${REFERENCE_bld}"* ${cache_dir}/

  ls -lih ${cache_dir}/
}

GWAS_DATA=${cache_dir}/$(basename ${GWAS_DATA})
REFERENCE_bld=${cache_dir}/$(basename ${REFERENCE_bld})
QTL_list=${cache_dir}/$(basename ${QTL_list})

OUTPUT=${cache_dir}
mkdir -p ${OUTPUT}/MAGIC/SMR/detail
mkdir -p ${OUTPUT}/MAGIC/SMR/summary
mkdir -p ${RESULT_OUTPUT}

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

# OpenMP runtime tuning
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export OMP_PROC_BIND=close        # keeps neighboring cores (good for shared caches)
export OMP_PLACES=cores
export OMP_WAIT_POLICY=active     # can help tight parallel loops (higher power)
export OMP_DISPLAY_ENV=VERBOSE

"${SMR}" --bld "${REFERENCE_bld}_chr" \
    --gwas-summary "${GWAS_DATA}" \
    --beqtl-list "${QTL_list}" \
    --beqtl-list-index ${qtl_i} \
    --maf 0.01 \
    --smr-multi \
    --thread-num 4 \
    --out "${OUTPUT}/MAGIC/SMR/detail/${trait_name}"

awk 'NR==1 || FNR>1' ${OUTPUT}/MAGIC/SMR/detail/${trait_name}_${qtl_name}_chr*.msmr > ${OUTPUT}/MAGIC/SMR/summary/${trait_name}_${qtl_name}_chrALL.msmr

cp -r "${OUTPUT}/"* ${RESULT_OUTPUT}/

rm ${OUTPUT}/MAGIC/SMR/detail/${trait_name}_${qtl_name}_chr*
