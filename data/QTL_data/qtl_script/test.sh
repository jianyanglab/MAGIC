#!/bin/bash

SMR="/storage/yangjianLab/yangwen/alpha-software/smr/smr-1.3.2-alpha4-linux"
REFERENCE="/storage/yangjianLab/sharedata/LD_reference/UKB/genotype_10K/BED_ukbEUR_imp_v3_INFO0.8_maf0.01_mind0.05_geno0.05_hwe1e6_10K_hg38"
REFERENCE_bld="/storage/yangjianLab/guoyazhou/project_SMR_visualizaiton/script/test_script/run_time_test/bld_format/BED_ukbEUR_imp_v3_INFO0.8_maf0.01_mind0.05_geno0.05_hwe1e6_10K_hg38_4Mb"
OUTPUT="/storage/yangjianLab/qiting/SMR_Cauchy/SMR/molecular_2_trait/detail"

QTL_DIRT="/storage/yangjianLab/sharedata/molecular_QTL"


qtl_index=${SLURM_ARRAY_TASK_ID}
# for((chr=1; chr<=22; chr++))
# do
chr=2222
qtl_name=()
qtl_data=()
# Dynamic assignments for public eQTL data
eQTL_Microglia_Regulome="${QTL_DIRT}/eQTL/Microglia_Regulome_Kosoy_2022_NG/besd/Microglia_meta_eQTL_chr${chr}"
eQTL_Adipose="${QTL_DIRT}/eQTL/Adipose_eQTL/BESD/GRCh38/geneQTL_METSIM_n426_adipose_summaryStats_1Mb_chr${chr}"
eQTL_DIRECT="${QTL_DIRT}/eQTL/DIRECT/besd/GRCh38/DIRECT_CHRALL"
eQTLGen="${QTL_DIRT}/eQTL/eQTLGen/cis-eQTL/GRCh38/eQTLGen_CHRALL"
eQTL_fetal_brain="${QTL_DIRT}/eQTL/fetal_brain/Brien_2018_Fetal_Brain_eQTL_GRCh38"
sQTL_microglia="${QTL_DIRT}/eQTL/microglia_QTL/microglia_meta_eQTL_and_sQTL/GRCh38_version/SMR_besd_format/out_mfg_stg_svz_tha_sClusters.metasoft_besd_format"
eQTL_microglia="${QTL_DIRT}/eQTL/microglia_QTL/microglia_meta_eQTL_and_sQTL/GRCh38_version/SMR_besd_format/out_miga_young_mynd_fairfax.metasoft_besd_format"
eQTL_BrainMeta="${QTL_DIRT}/eQTL/BrainMeta_cis_eqtl_summary/GRCh38/BrainMeta_cis_eQTL_chr${chr}"
sQTL_BrainMeta="${QTL_DIRT}/eQTL/BrainMeta_cis_sqtl_summary/GRCh38/BrainMeta_cis_sQTL_chr${chr}"
qtl_name+=("eQTL_Microglia_Regulome" "eQTL_Adipose" "eQTL_DIRECT" "eQTL_eQTLGen" "eQTL_fetal_brain" "eQTL_microglia" "sQTL_microglia" "eQTL_BrainMeta" "sQTL_BrainMeta")
qtl_data+=("$eQTL_Microglia_Regulome" "$eQTL_Adipose" "$eQTL_DIRECT" "$eQTLGen" "$eQTL_fetal_brain" "$eQTL_microglia" "$sQTL_microglia" "$eQTL_BrainMeta" "$sQTL_BrainMeta")

# Dynamic assignments for brain cell types
brain_CellType=("Microglia" "Pericytes" "Oligodendrocytes" "Endothelial.cells" "Inhibitory.neurons" "Excitatory.neurons" "OPCs...COPs" "Astrocytes")
for CT in "${brain_CellType[@]}"
do
    eQTL_brain_CT="${QTL_DIRT}/eQTL/eight_brain_cell_type_eQTL/brain_cell_type_cis_QTL/SMR_besd_format/GRCh38/${CT}_besd_format"
    qtl_name+=("eQTL_brain_${CT}")
    qtl_data+=("${eQTL_brain_CT}")
done

# Dynamic assignments for ROSMAP snRNA-seq (celltype)
BASE_DIRT="/storage/yangjianLab/sharedata/molecular_QTL/eQTL/ROSMAP_snRNAseq_Fujita_2024NG"
CELL_TYPE=$(ls ${BASE_DIRT}/raw/celltype/*tsv.gz |awk -F 'celltype-eqtl-sumstats.' '{print $2}' |awk -F '.tsv.gz' '{print $1}')
for celltype in ${CELL_TYPE[@]}
do
    eQTL_celltype="${QTL_DIRT}/eQTL/ROSMAP_snRNAseq_Fujita_2024NG/besd/celltype/celltype-eqtl-sumstats.${celltype}"
    qtl_name+=("ROSMAP_snRNA_celltype_${celltype}")
    qtl_data+=("${eQTL_celltype}")
done

# Dynamic assignments for ROSMAP snRNA-seq (subtype)
BASE_DIRT="/storage/yangjianLab/sharedata/molecular_QTL/eQTL/ROSMAP_snRNAseq_Fujita_2024NG"
CELL_TYPE=$(ls ${BASE_DIRT}/raw/subtype/*tsv.gz |awk -F 'subtype-eqtl-sumstats.' '{print $2}' |awk -F '.tsv.gz' '{print $1}')
for subtype in ${CELL_TYPE[@]}
do
    eQTL_subtype="${QTL_DIRT}/eQTL/ROSMAP_snRNAseq_Fujita_2024NG/besd/subtype/subtype-eqtl-sumstats.${subtype}"
    qtl_name+=("ROSMAP_snRNA_subtype_${subtype}")
    qtl_data+=("${eQTL_subtype}")
done


# Dynamic assignments from onek1k
while read -r tissue
do
    eQTL_OneK1K="${QTL_DIRT}/eQTL/OneK1K/besd/${tissue}_onek1k_eqtl"
    qtl_name+=("eQTL_onek1k_${tissue}")
    qtl_data+=("${eQTL_OneK1K}")
done < <(ls ${QTL_DIRT}/eQTL/OneK1K/besd/*_onek1k_eqtl.esi | awk -F '/' '{print $9}' | awk -F '_onek1k_eqtl' '{print $1}')

# Add similar loops for GTEx eQTL data
QTL_DIRT1="${QTL_DIRT}/eQTL/gtex_resources_besd/eQTL_hg38/eQTL_besd_hg38"
PATTERN="${QTL_DIRT1}/*_eQTL_all_chr22.esi"
if compgen -G "$PATTERN" > /dev/null; then
    while read -r tissue; do
        eQTL_GTEx="${QTL_DIRT1}/${tissue}_eQTL_all_chr${chr}"
        qtl_name+=("eQTL_GTEx_${tissue}")
        qtl_data+=("${eQTL_GTEx}")
    done < <(ls $PATTERN | awk -F '/' '{print $(NF)}' | awk -F '_eQTL' '{print $1}')
else
    echo "No files match the pattern ${PATTERN}"
fi

# Add loops for GTEx sQTL data
QTL_DIRT1="${QTL_DIRT}/eQTL/gtex_resources_besd/sQTL_hg38/sQTL_besd_hg38"
PATTERN="${QTL_DIRT1}/*_sQTL_all_chr22.esi"
if compgen -G "$PATTERN" > /dev/null; then
    while read -r tissue; do
        sQTL_GTEx="${QTL_DIRT1}/${tissue}_sQTL_all_chr${chr}"
        qtl_name+=("sQTL_GTEx_${tissue}")
        qtl_data+=("${sQTL_GTEx}")
    done < <(ls $PATTERN | awk -F '/' '{print $(NF)}' | awk -F '_sQTL' '{print $1}')
else
    echo "No files match the pattern ${PATTERN}"
fi



for qtl_index in `seq 0 210`
do
end_of_string="${qtl_data[qtl_index]: -${#chr}}"
if [[ "$end_of_string" == "$chr" ]]; then
	qtl_chr="TRUE"
else
    qtl_chr="FALSE"
fi

qtl_data=`echo ${qtl_data[qtl_index]} | sed 's/2222//g'`

echo -e "${qtl_name[qtl_index]}\t${qtl_data}\t${qtl_chr}"

done

