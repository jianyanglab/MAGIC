
rm QTL_list.txt
cat qtl_name_match_list.txt | while read line
do
qtl_new=`echo $line | cut -f1`
qtl_old=`echo $line | cut -f2`
qtl_data=`grep -w ${qtl_old} *QTL_list.txt| cut -f 2`
qtl_chr=`grep -w ${qtl_old} *QTL_list.txt| cut -f 3`
echo -e "${qtl_new}\t${qtl_data}\t${qtl_chr}"
done > QTL_list.txt
