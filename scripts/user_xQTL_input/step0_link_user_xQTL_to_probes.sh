
#!/bin/bash
set -e
# ------------------------------------------------------------------------
#  Input
# ------------------------------------------------------------------------
CONFIG=$1
SCRIPT_DIR=`yq .script.path "${CONFIG}"`
GWAS_DATA=`yq .input.gwas "${CONFIG}"`
trait_name=`yq .input.trait "${CONFIG}"`
OUTPUT=`yq .input.output "${CONFIG}"`
user_xQTL_list=`yq .input.user_xQTL_list "${CONFIG}"`

epi_to_bed=`yq .software.epi_to_bed "${CONFIG}"`
bedtools=`yq .software.bedtools "${CONFIG}"`
get_concensus_link=`yq .software.get_concensus_link "${CONFIG}"`

genome_hg38=`yq .link_annotation.genome_hg38 "${CONFIG}"`
ABC=`yq .link_annotation.ABC "${CONFIG}"`
EpiMap=`yq .link_annotation.EpiMap "${CONFIG}"`
RoadMap=`yq .link_annotation.RoadMap "${CONFIG}"`
PCHiC=`yq .link_annotation.PCHiC "${CONFIG}"`
Promoter=`yq .link_annotation.Promoter "${CONFIG}"`
closestTSS=`yq .link_annotation.closestTSS "${CONFIG}"`

mkdir -p ${OUTPUT}/MAGIC/user_xQTL

QTL_list=${user_xQTL_list}
QTL_list_num=`cat ${QTL_list} | wc -l`

# qtl_i=${SLURM_ARRAY_TASK_ID}

rm ${OUTPUT}/MAGIC/user_xQTL/user_xQTL_consensus.link 
for qtl_i in $(seq 1 ${QTL_list_num}); do
	echo "Processing QTL ${qtl_i} of ${QTL_list_num}"

	qtl_name=`head -n ${qtl_i} ${QTL_list} | tail -n1 | awk -F "\t" '{print $1}'`
	qtl_data=`head -n ${qtl_i} ${QTL_list} | tail -n1 | awk -F "\t" '{print $2}'`
	qtl_chr=`head -n ${qtl_i} ${QTL_list} | tail -n1 | awk -F "\t" '{print $3}'`


# ------------------------------------------------------------------------
# step1 ----- Convert epigenetic QTL to bed format

qtl_type=`head -n ${qtl_i} ${QTL_list} | tail -n1 | awk -F "\t" '{print $4}'`

if [ "$qtl_type" = "epigenetic" ]; then

	rm ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}.bed 
	if [ "$qtl_chr" = "TRUE" ]; then
		for i in $(seq 1 22); do
    		QTL_data="${qtl_data}${i}"
			Rscript ${epi_to_bed} \
				--INFILE ${QTL_data}.epi \
				--out ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_chr${i}.bed

			cat ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_chr${i}.bed >> ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}.bed 
		done
    else
        QTL_data="${qtl_data}"
		Rscript ${epi_to_bed} \
			--INFILE ${QTL_data}.epi \
			--out ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}.bed
    fi



${bedtools} \
	intersect -wa -wb \
	-a ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}.bed \
	-b ${ABC} > ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_ABC.link

${bedtools} \
	intersect -wa -wb \
	-a ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}.bed \
	-b ${EpiMap} > ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_EpiMap.link

${bedtools} \
	intersect -wa -wb \
	-a ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}.bed \
	-b ${RoadMap} > ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_RoadMap.link

${bedtools} \
	intersect -wa -wb \
	-a ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}.bed \
	-b ${PCHiC} > ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_PCHiC.link

${bedtools} \
	intersect -wa -wb \
	-a ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}.bed \
	-b ${Promoter} > ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_Promoter.link

${bedtools} \
	closest -wa -wb \
	-g ${genome_hg38} \
	-a ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}.bed \
	-b ${closestTSS} > ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_closestTSS.link


# ------------------------------------------------------------------------
# step3 ----- get consensus links for epigenetic marks to genes (supported >=3)


Rscript ${get_concensus_link} \
	${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_ABC.link \
	${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_EpiMap.link \
	${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_RoadMap.link \
	${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_PCHiC.link \
	${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_Promoter.link \
	${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_closestTSS.link \
	${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_consensus.link 



rm ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}*bed
rm ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_ABC.link
rm ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_EpiMap.link
rm ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_RoadMap.link
rm ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_PCHiC.link
rm ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_Promoter.link
rm ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_closestTSS.link


cat ${OUTPUT}/MAGIC/user_xQTL/${qtl_name}_consensus.link >> ${OUTPUT}/MAGIC/user_xQTL/user_xQTL_consensus.link 


else
	echo "Skipping non-epigenetic xQTL type: ${qtl_type}"
fi

done

user_xQTL_link_consensus="${OUTPUT}/MAGIC/user_xQTL/user_xQTL_consensus.link"
yq -i ".input.user_xQTL_link_consensus = \"$CONFIG\"" "$CONFIG"
