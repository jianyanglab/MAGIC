# MAGIC pipeline

## Input
CONFIG_template=$1
trait_name=$2
GWAS_DATA=$3
WORK_DIR=${4:-"/storage/yangjianLab/guoyazhou/GAMMA_git/L2G/MAGIC"}
OUTPUT=${5:-"/storage/yangjianLab/guoyazhou/GAMMA_git_data"}
SCRIPT_DIR=${6:-"/storage/yangjianLab/guoyazhou/GAMMA_github/MAGIC/scripts"}

## Config first
./scripts/config.sh \
    ./deploy/HPC/demo.yaml \
    ${trait_name} \
    ${GWAS_DATA} \
    ${WORK_DIR} \
    ${OUTPUT} \
    ${SCRIPT_DIR}

## Check GWAS data
./scripts/gwas_format.sh ${CONFIG}

## MAGIC pipeline
CONFIG=${WORK_DIR}/yaml_file/${trait_name}.yaml
./deploy/HPC/MAGIC_sbatch.sh ${CONFIG}
