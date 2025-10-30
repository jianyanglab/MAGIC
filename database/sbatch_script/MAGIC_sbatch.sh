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
# MAGIC analysis
# ------------------------------------------------------------------------

MAGIC_jid=$(/opt/slurm/bin/sbatch --parsable \
  -J MAGIC_analysis \
  -c 4 \
  -p intel-sc3,amd-ep2,amd-ep2-short \
  -q normal \
  -a 1 \
  --ntasks-per-node 1 \
  --mem 20G \
  -o ./out_log/magic/MAGIC_${trait_name}_%A_%a_out.txt \
  -e ./error_log/magic/MAGIC_${trait_name}_%A_%a_error.txt \
  ${SCRIPT_DIR}/MAGIC.sh ${CONFIG})

echo "MAGIC analysis: $MAGIC_jid"

