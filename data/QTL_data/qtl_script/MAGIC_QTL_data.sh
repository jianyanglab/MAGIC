chr=2222
qtl_name=()
qtl_data=()
QTL_DIRT="/storage/yangjianLab/sharedata/molecular_QTL"

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


# Dynamic assignments for brain cell types (qtl_index: 9-16)
brain_CellType=("Microglia" "Pericytes" "Oligodendrocytes" "Endothelial.cells" "Inhibitory.neurons" "Excitatory.neurons" "OPCs...COPs" "Astrocytes")
for CT in "${brain_CellType[@]}"
do
    eQTL_brain_CT="${QTL_DIRT}/eQTL/eight_brain_cell_type_eQTL/brain_cell_type_cis_QTL/SMR_besd_format/GRCh38/${CT}_besd_format"
    qtl_name+=("eQTL_brain_${CT}")
    qtl_data+=("${eQTL_brain_CT}")
done

# Dynamic assignments for ROSMAP snRNA-seq (celltype) (qtl_index: 17-23)
BASE_DIRT="/storage/yangjianLab/sharedata/molecular_QTL/eQTL/ROSMAP_snRNAseq_Fujita_2024NG"
CELL_TYPE=$(ls ${BASE_DIRT}/raw/celltype/*tsv.gz |awk -F 'celltype-eqtl-sumstats.' '{print $2}' |awk -F '.tsv.gz' '{print $1}')
for celltype in ${CELL_TYPE[@]}
do
    eQTL_celltype="${QTL_DIRT}/eQTL/ROSMAP_snRNAseq_Fujita_2024NG/besd/celltype/celltype-eqtl-sumstats.${celltype}"
    qtl_name+=("eQTL_ROSMAP_snRNA_celltype_${celltype}")
    qtl_data+=("${eQTL_celltype}")
done

# Dynamic assignments for ROSMAP snRNA-seq (subtype) (qtl_index: 24-87)
BASE_DIRT="/storage/yangjianLab/sharedata/molecular_QTL/eQTL/ROSMAP_snRNAseq_Fujita_2024NG"
CELL_TYPE=$(ls ${BASE_DIRT}/raw/subtype/*tsv.gz |awk -F 'subtype-eqtl-sumstats.' '{print $2}' |awk -F '.tsv.gz' '{print $1}')
for subtype in ${CELL_TYPE[@]}
do
    eQTL_subtype="${QTL_DIRT}/eQTL/ROSMAP_snRNAseq_Fujita_2024NG/besd/subtype/subtype-eqtl-sumstats.${subtype}"
    qtl_name+=("eQTL_ROSMAP_snRNA_subtype_${subtype}")
    qtl_data+=("${eQTL_subtype}")
done


# Dynamic assignments from onek1k (qtl_index: 88-101)
CELL_TYPE=$(ls ${QTL_DIRT}/eQTL/OneK1K/besd/*_onek1k_eqtl.esi | awk -F '/' '{print $9}' | awk -F '_onek1k_eqtl' '{print $1}')
for subtype in ${CELL_TYPE[@]}
do
    eQTL_OneK1K="${QTL_DIRT}/eQTL/OneK1K/besd/${subtype}_onek1k_eqtl"
    qtl_name+=("eQTL_onek1k_${subtype}")
    qtl_data+=("${eQTL_OneK1K}")
done


# Add similar loops for GTEx eQTL data (qtl_index: 102-150)
QTL_DIRT1="${QTL_DIRT}/eQTL/gtex_resources_besd/eQTL_hg38/eQTL_besd_hg38"
PATTERN="${QTL_DIRT1}/*_eQTL_all_chr22.esi"

TISUUE=$(ls $PATTERN | awk -F '/' '{print $(NF)}' | awk -F '_eQTL' '{print $1}')
for tissue in ${TISUUE[@]}
do
    eQTL_GTEx="${QTL_DIRT1}/${tissue}_eQTL_all_chr${chr}"
    qtl_name+=("eQTL_GTEx_${tissue}")
    qtl_data+=("${eQTL_GTEx}")
done


# Add loops for GTEx sQTL data (qtl_index: 151-199)
QTL_DIRT1="${QTL_DIRT}/eQTL/gtex_resources_besd/sQTL_hg38/sQTL_besd_hg38"
PATTERN="${QTL_DIRT1}/*_sQTL_all_chr22.esi"

TISSUE=$(ls $PATTERN | awk -F '/' '{print $(NF)}' | awk -F '_sQTL' '{print $1}')
for tissue in ${TISSUE[@]}
do
    sQTL_GTEx="${QTL_DIRT1}/${tissue}_sQTL_all_chr${chr}"
    qtl_name+=("sQTL_GTEx_${tissue}")
    qtl_data+=("${sQTL_GTEx}")
done



# Add loops for GTEx edQTL data (qtl_index: 200-248)
QTL_DIRT1="${QTL_DIRT}/eQTL/gtex_resources_besd/editingQTL/besd"
PATTERN="${QTL_DIRT1}/*.nominal.esi"
TISSUE=$(ls $PATTERN | awk -F '/' '{print $(NF)}' | awk -F '.nominal' '{print $1}')
for tissue in ${TISSUE[@]}
do
    edQTL_GTEx="${QTL_DIRT1}/${tissue}.nominal"
    qtl_name+=("edQTL_GTEx_${tissue}")
    qtl_data+=("${edQTL_GTEx}")
done


# sc-eQTL from eQTL catlogue (qtl_index: 249-379)
QTL_DIRT1="${QTL_DIRT}/eQTL/sceQTL/besd"
PATTERN="${QTL_DIRT1}/*.all.esi"

TISSUE=$(ls $PATTERN | awk -F '/' '{print $(NF)}' | awk -F '.all' '{print $1}')
for study in ${TISSUE[@]}
do
    sceQTL="${QTL_DIRT1}/${study}.all"
    qtl_name+=("eQTL_catalogue_${study}")
    qtl_data+=("${sceQTL}")
done




#PsyENCODE2 Developmental eQTL/sQTL/isoQTL
# eQTL
QTL_DIRT1="${QTL_DIRT}/eQTL/PsychENCODE2/eQTL/besd"
edQTL_GTEx="${QTL_DIRT1}/T1_chr${chr}"
qtl_name+=("PEC_Tri1_eqtl")
qtl_data+=("${edQTL_GTEx}")
edQTL_GTEx="${QTL_DIRT1}/T2_chr${chr}"
qtl_name+=("PEC_Tri2_eqtl")
qtl_data+=("${edQTL_GTEx}")


# isoQTL
QTL_DIRT1="${QTL_DIRT}/eQTL/PsychENCODE2/isoQTL/besd"
edQTL_GTEx="${QTL_DIRT1}/Tri1_nominal_isoqtl_35HCP_all_assoc_chr${chr}"
qtl_name+=("PEC_Tri1_isoqtl")
qtl_data+=("${edQTL_GTEx}")
edQTL_GTEx="${QTL_DIRT1}/Tri2_nominal_isoqtl_20HCP_all_assoc_chr${chr}"
qtl_name+=("PEC_Tri2_isoqtl")
qtl_data+=("${edQTL_GTEx}")

# sQTL
QTL_DIRT1="${QTL_DIRT}/eQTL/PsychENCODE2/sQTL/besd"
edQTL_GTEx="${QTL_DIRT1}/tri1_nominal_sqtl_15HCP_all_assoc_chr${chr}"
qtl_name+=("PEC_Tri1_sqtl")
qtl_data+=("${edQTL_GTEx}")
edQTL_GTEx="${QTL_DIRT1}/tri2_nominal_sqtl_10HCP_all_assoc_chr${chr}"
qtl_name+=("PEC_Tri2_sqtl")
qtl_data+=("${edQTL_GTEx}")



# 获取qtl_data的长度
## len=${#qtl_data[@]}
## echo "The length of the array is: $len"

# 遍历qtl_data数组
for qtl_index in `seq 0 $((len-1))`
do
    # 获取末尾的字符串并判断是否与 chr 变量匹配
    end_of_string="${qtl_data[qtl_index]: -${#chr}}"
    if [[ "$end_of_string" == "$chr" ]]; then
        qtl_chr="TRUE"
    else
        qtl_chr="FALSE"
    fi

    # 使用 sed 处理 qtl_data 内容
    qtl_data_updated=`echo ${qtl_data[qtl_index]} | sed 's/2222//g'`

    # 打印结果
    echo -e "${qtl_name[qtl_index]}\t${qtl_data_updated}\t${qtl_chr}"
done 


# > /storage/yangjianLab/guoyazhou/GAMMA_github/MAGIC/data/QTL_data/match_list/qtl_name_match_list_all.txt


# -------------------------------------------------
# -------------------------------------------------
# -------------------------------------------------
# The following needs to be run in R --------------
qtl_data=fread("/storage/yangjianLab/guoyazhou/GAMMA_github/MAGIC/data/QTL_data/qtl_script/MAGIC_QTL_data.txt")
qtl_name_match_list=fread("/storage/yangjianLab/guoyazhou/GAMMA_github/MAGIC/data/QTL_data/match_list/qtl_name_match_list_all.txt")
index=match(qtl_data$V1, qtl_name_match_list$`QTL_name_old (Ting)`, nomatch=0)
qtl_data$V1[which(index!=0)]=qtl_name_match_list$QTL_name_new[index]
qtl_data$V1[which(index==0)]


qtl_data_old=fread("/storage/yangjianLab/guoyazhou/GAMMA_github/MAGIC/data/QTL_data/QTL_list.txt")
qtl_data_new=rbind(qtl_data, qtl_data_old)

qtl_data_new_sorted <- qtl_data_new[order(qtl_data_new$V1), ]
qtl_data_new_sorted_unique <- unique(qtl_data_new_sorted)

QTL_name_list=fread("/storage/yangjianLab/guoyazhou/GAMMA_github/gamma-script/scripts/L2G/MAGIC_data/QTL_data/QTL_data_name_list.txt", head=F)
index=which(qtl_data_new_sorted_unique$V1 %in% QTL_name_list$V1)
qtl_data_new_sorted_unique$V1[-index]

index=which(qtl_data_new_sorted_unique$V1 == "eQTLGen")
dim(qtl_data_new_sorted_unique)
qtl_data_new_sorted_unique=qtl_data_new_sorted_unique[-index,]
dim(qtl_data_new_sorted_unique)


fwrite(qtl_data_new_sorted_unique, "/storage/yangjianLab/guoyazhou/GAMMA_github/gamma-script/scripts/L2G/MAGIC_data/QTL_data/QTL_list.txt", sep="\t", quote=F, row.names=F, col.names=F)

