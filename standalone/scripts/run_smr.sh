#!/usr/bin/env sh

set -e

CONFIG=$1

mkdir -p ${OUTPUT}/MAGIC/SMR/detail
mkdir -p ${OUTPUT}/MAGIC/SMR/summary

# TODO loop over qtl_i
qtl_i=$2
qtl_name=$(head -n ${qtl_i} ${QTL_list} | tail -n1 | awk -F "\t" '{print $1}')
qtl_data=$(realpath --relative-to=${MAGIC_ROOT} $(head -n ${qtl_i} ${QTL_list} | tail -n1 | awk -F "\t" '{print $2}'))
qtl_chr=$(head -n ${qtl_i} ${QTL_list} | tail -n1 | awk -F "\t" '{print $3}')

echo "SMR: ${SMR}"
echo "qtl_list: ${QTL_list}"
echo "qtl_data=${qtl_data}"

for i in $(seq 1 1); do

    if [ "$qtl_chr" = "TRUE" ]; then
        QTL_data="${qtl_data}${i}"
    else
        QTL_data="${qtl_data}"
    fi

    "${SMR}" --bfile "${REFERENCE}_chr${i}" \
        --gwas-summary "${GWAS_DATA}" \
        --beqtl-summary "${QTL_data}" \
        --maf 0.01 \
        --smr-multi \
        --thread-num 4 \
        --out "${OUTPUT}/MAGIC/SMR/detail/${trait_name}_${qtl_name}_chr${i}"

done

awk 'NR==1 || FNR>1' ${OUTPUT}/MAGIC/SMR/detail/${trait_name}_${qtl_name}_chr*.msmr > ${OUTPUT}/MAGIC/SMR/summary/${trait_name}_${qtl_name}_chrALL.msmr

rm ${OUTPUT}/MAGIC/SMR/detail/${trait_name}_${qtl_name}_chr*



