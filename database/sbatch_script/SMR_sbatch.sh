#!/usr/bin/env bash

CONFIG=$1

trait_name=`yq .input.trait "${CONFIG}"`
GWAS_DATA=`yq .input.gwas "${CONFIG}"`
SCRIPT_DIR=`yq .script.path "${CONFIG}"`
WORK_DIR=`yq .script.work_path "${CONFIG}"`


cd ${WORK_DIR}
mkdir -p ./out_log/clumping
mkdir -p ./error_log/clumping
mkdir -p ./out_log/smr
mkdir -p ./error_log/smr
mkdir -p ./out_log/magic
mkdir -p ./error_log/magic



# ------------------------------------------------------------------------
# SMR analysis
# ------------------------------------------------------------------------

SMR_jid=$(/opt/slurm/bin/sbatch --parsable \
  -J SMR_analysis \
  -c 5 \
  -p intel-sc3,amd-ep2,amd-ep2-short \
  -q huge \
  -a 392-405 \
  --ntasks-per-node 1 \
  --mem 36G \
  -o ./out_log/smr/${trait_name}_SMR_%A_%a_out.txt \
  -e ./error_log/smr/${trait_name}_SMR_%A_%a_error.txt \
  ${SCRIPT_DIR}/SMR.sh ${CONFIG})

echo "SMR analysis: $SMR_jid"
