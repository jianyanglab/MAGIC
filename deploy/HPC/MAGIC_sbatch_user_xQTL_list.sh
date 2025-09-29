#!/usr/bin/env bash

CONFIG=$1

trait_name=`yq .input.trait "${CONFIG}"`
GWAS_DATA=`yq .input.gwas "${CONFIG}"`
SCRIPT_DIR=`yq .script.path "${CONFIG}"`
WORK_DIR=`yq .script.work_path "${CONFIG}"`

user_xQTL_list=`yq .input.user_xQTL_list "${CONFIG}"`
# QTL_list=`yq .magic.QTL_list "${CONFIG}"`
QTL_list=${user_xQTL_list}


cd ${WORK_DIR}
mkdir -p ./out_log/clumping
mkdir -p ./error_log/clumping
mkdir -p ./out_log/smr
mkdir -p ./error_log/smr
mkdir -p ./out_log/magic
mkdir -p ./error_log/magic
mkdir -p ./out_log/link_QTL_probe
mkdir -p ./error_log/link_QTL_probe

# ------------------------------------------------------------------------
# Clumping analysis
# ------------------------------------------------------------------------

Clumping_jid=$(/opt/slurm/bin/sbatch --parsable \
  -J Clumping_analysis \
  -c 2 \
  -p intel-sc3,amd-ep2,amd-ep2-short \
  -q normal \
  -a 1 \
  --ntasks-per-node 1 \
  --mem 16G \
  -o ./out_log/clumping/${trait_name}_Clumping_%A_%a_out.txt \
  -e ./error_log/clumping/${trait_name}_Clumping_%A_%a_error.txt \
  ${SCRIPT_DIR}/Clumping_user_xQTL.sh ${CONFIG})

echo "Clumping analysis: $Clumping_jid"

# ------------------------------------------------------------------------
# step0 link user xQTL to probes analysis
# ------------------------------------------------------------------------

link_QTL_probe_to_gene_jid=$(/opt/slurm/bin/sbatch --parsable \
  -J link_QTL_probe_to_gene \
  -c 5 \
  -p intel-sc3,amd-ep2,amd-ep2-short \
  -q normal \
  -a 1 \
  --ntasks-per-node 1 \
  --mem 24G \
  -o ./out_log/link_QTL_probe/${trait_name}_link_QTL_probe_%A_%a_out.txt \
  -e ./error_log/link_QTL_probe/${trait_name}_link_QTL_probe_%A_%a_error.txt \
  ${SCRIPT_DIR}/user_xQTL_input/step0_link_user_xQTL_to_probes.sh ${CONFIG})

echo "step0 link QTL probe to gene analysis: $link_QTL_probe_to_gene_jid"


# ------------------------------------------------------------------------
# SMR analysis
# ------------------------------------------------------------------------

QTL_num=`awk '!/^[[:space:]]*(#|$)/' "$QTL_list" | wc -l`

SMR_jid=$(/opt/slurm/bin/sbatch --parsable \
  -J SMR_analysis \
  -c 5 \
  -p intel-sc3,amd-ep2,amd-ep2-short \
  -q normal \
  -a 1-${QTL_num} \
  --ntasks-per-node 1 \
  --mem 36G \
  -o ./out_log/smr/${trait_name}_SMR_%A_%a_out.txt \
  -e ./error_log/smr/${trait_name}_SMR_%A_%a_error.txt \
  ${SCRIPT_DIR}/SMR_user_xQTL.sh ${CONFIG})

echo "SMR analysis: $SMR_jid"

# ------------------------------------------------------------------------
# MAGIC analysis
# ------------------------------------------------------------------------
  # -d afterok:${Clumping_jid}:${SMR_jid} \

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
  ${SCRIPT_DIR}/MAGIC_user_xQTL.sh ${CONFIG})

echo "MAGIC analysis: $MAGIC_jid"

