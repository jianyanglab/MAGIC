#!/bin/bash

# GWAS_list="/storage/yangjianLab/qiting/SMR_Cauchy/clump/GWAS_45trait.info"
# CONFIG_template="/storage/yangjianLab/guoyazhou/GAMMA_github/MAGIC/database/yaml_file/demo_MPB.yaml"
# 
# for i in `seq 1 45`
# do
#         trait_name=`head -n ${i} ${GWAS_list} | tail -n1 | awk -F "\t" '{print $2}'`
#         GWAS_file_name=`head -n ${i} ${GWAS_list} | tail -n1 | awk -F "\t" '{print $5}'`
#         GWAS_DATA="/storage/yangjianLab/sharedata/GWAS_summary/01_Public/01_cojo/${GWAS_file_name}.txt"
#         echo ${trait_name}
#         echo ${GWAS_DATA}
#         ./database_yaml_config.sh ${CONFIG_template} ${trait_name} ${GWAS_DATA}
# done


CONFIG_template=$1
trait_name=$2
GWAS_DATA=$3

CONFIG="/storage/yangjianLab/guoyazhou/GAMMA_github/MAGIC/database/yaml_file/${trait_name}.yaml"
cp ${CONFIG_template} ${CONFIG}

yq -i ".input.trait = \"$trait_name\"" "$CONFIG"
yq -i ".input.gwas_raw = \"$GWAS_DATA\"" "$CONFIG"
yq -i ".input.gwas = \"$GWAS_DATA\"" "$CONFIG"
yq -i ".yaml.config = \"$CONFIG\"" "$CONFIG"



