args=commandArgs(TRUE)
trait_name=args[1]
OUTPUT=args[2]
magic_functions_file=args[3]
gencode_file=args[4]
CpG_link_file=args[5]
hQTL_link_file=args[6]
caQTL_link_file=args[7]
# ---- gwas locus data ----
GWAS_DATA=args[8]
reference_bim_file=args[9]

suppressMessages({
library(data.table);
library(stringr);
library(dplyr);
library(qvalue);
library(tidyverse);
library(GenomicRanges);
library(regioneR);
library(Repitools);
library(mgcv)
})

source(magic_functions_file)

####################################################################################################
# GWAS and bim file
####################################################################################################
gwas=fread(GWAS_DATA,head=TRUE,stringsAsFactors=FALSE,data.table=FALSE)
colnames(gwas)=toupper(colnames(gwas))
gwas$P = as.numeric(gwas$P)

bim=fread(reference_bim_file,head=F,stringsAsFactors=F,data.table=F)

index=match(gwas$SNP, bim$V2, nomatch=0)
gwas$CHR=gwas$POS=NA
gwas$CHR[which(index!=0)]=bim$V1[index]
gwas$POS[which(index!=0)]=bim$V4[index]

####################################################################################################
# Gencode annotations
####################################################################################################
anot=fread(gencode_file, head=T,stringsAsFactors=F,data.table=F)
anot$gene_id=str_split_fixed(anot$gene_id,"\\.",Inf)[,1]
anot <- anot[anot$gene_type == "protein_coding", ]
anot <- anot[!anot[, 1] %in% c("chrX", "chrY", "chrM"), ]
anot <- anot[!duplicated(anot$gene_name), ]
anot$V1 <- as.numeric(sub("^chr", "", anot$V1))

result <- data.frame(chr=anot$V1,start=anot$V4,end=anot$V5,strand=anot$V7,gene_id=anot$gene_id,gene_name=anot$gene_name)
result$GWAS_LOCUS=NA;result$Lead_SNP=NA;result$Lead_SNP_BP=NA;
Locus_data=fread(paste0(OUTPUT, "/MAGIC/Clumping/summary/",trait_name,".locus"), header=T)
for(j in 1:nrow(Locus_data)){
  chr=sub("^chr", "", Locus_data$chr[j])
  start=Locus_data$start[j]
  end=Locus_data$end[j]
  locus=Locus_data$GWAS_LOCUS[j]
  lead_snp=Locus_data$Lead_SNP[j]
  lead_snp_bp=Locus_data$Lead_SNP_BP[j]

  index=which(result$chr==chr & result$start<=end & result$start>=start & result$end<=end & result$end>=start)
  result$GWAS_LOCUS[index]=locus
  result$Lead_SNP[index]=lead_snp
  result$Lead_SNP_BP[index]=lead_snp_bp

  gwas_index=which(gwas$CHR==chr & gwas$POS<=end & gwas$POS>=start)
  gwas_locus_data=gwas[gwas_index,c("CHR","POS","P","SNP")]
  write.table(gwas_locus_data,paste0(OUTPUT,"/MAGIC/gwas/",trait_name,"_", locus,".txt"),row=F,col=T,quo=F,sep="\t")
}


####################################################################################################
# read SMR assocaition between molecular trait and complex trait
####################################################################################################
SMR_DIRT=paste0(OUTPUT,"/MAGIC/SMR/summary/")

# eQTL/sQTL/pQTL-trait SMR results
print("||===================================================================================")
eSMR <- read_smr_data1(SMR_DIRT,result,trait_name,qtl_type="eQTL")
sSMR <- read_smr_data1(SMR_DIRT,result,trait_name,qtl_type="sQTL")
pSMR <- read_smr_data1(SMR_DIRT,result,trait_name,qtl_type="pQTL")

# mQTL/hQTL/caQTL-trait SMR results (probeID is not the same;)
# link mQTL/hQTL/caQTL probeIDs to genes
CpG_link=fread(CpG_link_file,head=F,stringsAsFactors=F,data.table=F)
hQTL_link=fread(hQTL_link_file,head=F,stringsAsFactors=F,data.table=F)
caQTL_link=fread(caQTL_link_file,head=F,stringsAsFactors=F,data.table=F)

mSMR <- read_smr_data2(SMR_DIRT,result,trait_name,qtl_type="mQTL",QTL_link=CpG_link)
hSMR <- read_smr_data2(SMR_DIRT,result,trait_name,qtl_type="hQTL",QTL_link=hQTL_link)
caSMR <- read_smr_data2(SMR_DIRT,result,trait_name,qtl_type="caQTL",QTL_link=caQTL_link)


####################################################################################################
# MAGIC calculation for each category
####################################################################################################
p_ACAT_eSMR=apply(eSMR$SMR_p_ACAT,1,ACAT)
p_ACAT_sSMR=apply(sSMR$SMR_p_ACAT,1,ACAT)
p_ACAT_pSMR=apply(pSMR$SMR_p_ACAT,1,ACAT)
p_ACAT_mSMR=apply(mSMR$SMR_p_ACAT,1,ACAT)
p_ACAT_hSMR=apply(hSMR$SMR_p_ACAT,1,ACAT)
p_ACAT_caSMR=apply(caSMR$SMR_p_ACAT,1,ACAT)
p_ACAT=apply(cbind(eSMR$SMR_p_ACAT, sSMR$SMR_p_ACAT, pSMR$SMR_p_ACAT, mSMR$SMR_p_ACAT, hSMR$SMR_p_ACAT, caSMR$SMR_p_ACAT),1,ACAT)

ACAT_results=data.frame(p_ACAT,p_ACAT_eSMR,p_ACAT_sSMR,p_ACAT_pSMR,p_ACAT_mSMR,p_ACAT_hSMR,p_ACAT_caSMR)
ACAT_results$gene_name=rownames(ACAT_results)
MAGIC_results=merge(result, ACAT_results, by = "gene_name")
write.table(MAGIC_results,paste0(OUTPUT,"/MAGIC/summary/",trait_name,"_MAGIC.txt"),row=F,col=T,quo=F,sep="\t")



####################################################################################################
# MAGIC plots
####################################################################################################
index <- which(!is.na(MAGIC_results$GWAS_LOCUS) & MAGIC_results$p_ACAT < 0.05 / length(MAGIC_results$p_ACAT))
MAGIC_plot <- MAGIC_results[index, ]
eSMR_plot <- cbind(result[index,], eSMR$SMR_p_ACAT[index,], eSMR$SMR_probeID[index,])
sSMR_plot <- cbind(result[index,], sSMR$SMR_p_ACAT[index,], sSMR$SMR_probeID[index,])
pSMR_plot <- cbind(result[index,], pSMR$SMR_p_ACAT[index,], pSMR$SMR_probeID[index,])
mSMR_plot <- cbind(result[index,], mSMR$SMR_p_ACAT[index,], mSMR$SMR_probeID[index,])
hSMR_plot <- cbind(result[index,], hSMR$SMR_p_ACAT[index,], hSMR$SMR_probeID[index,])
caSMR_plot <- cbind(result[index,], caSMR$SMR_p_ACAT[index,], caSMR$SMR_probeID[index,])

write.table(MAGIC_results,paste0(OUTPUT,"/MAGIC/plot/",trait_name,"_eSMR.summary"),row=F,col=T,quo=F,sep="\t")
write.table(MAGIC_results,paste0(OUTPUT,"/MAGIC/plot/",trait_name,"_sSMR.summary"),row=F,col=T,quo=F,sep="\t")
write.table(MAGIC_results,paste0(OUTPUT,"/MAGIC/plot/",trait_name,"_pSMR.summary"),row=F,col=T,quo=F,sep="\t")
write.table(MAGIC_results,paste0(OUTPUT,"/MAGIC/plot/",trait_name,"_mQTL.summary"),row=F,col=T,quo=F,sep="\t")
write.table(MAGIC_results,paste0(OUTPUT,"/MAGIC/plot/",trait_name,"_hQTL.summary"),row=F,col=T,quo=F,sep="\t")
write.table(MAGIC_results,paste0(OUTPUT,"/MAGIC/plot/",trait_name,"_caQTL.summary"),row=F,col=T,quo=F,sep="\t")


QTL_types <- c("eSMR", "sSMR", "pSMR", "mSMR", "hSMR", "caSMR")
MAGIC_plot[paste0(QTL_types, "_name")] <- NA
MAGIC_plot[paste0(QTL_types, "_probeID")] <- NA

get_min_index_and_name <- function(gene_name, SMR_p_ACAT, SMR_probeID) {
    index <- which.min(SMR_p_ACAT[gene_name, ])
    name <- ifelse(length(index) > 0, colnames(SMR_p_ACAT)[index], NA)
    probeID <- ifelse(length(index) > 0, SMR_probeID[gene_name, index], NA)
    return(list(name = name, probeID = probeID))
}

for (qtl in QTL_types) {
    MAGIC_plot_list <- apply(MAGIC_plot[, "gene_name", drop = FALSE], 1, function(gene_name) {
		get_min_index_and_name(gene_name, get(qtl)$SMR_p_ACAT, get(qtl)$SMR_probeID)
    })
	MAGIC_plot[[paste0(qtl, "_name")]] <- sapply(MAGIC_plot_list, function(x) x$name)
    MAGIC_plot[[paste0(qtl, "_probeID")]] <- sapply(MAGIC_plot_list, function(x) x$probeID)
}

write.table(MAGIC_results,paste0(OUTPUT,"/MAGIC/plot/",trait_name,"_MAGIC_plot.summary"),row=F,col=T,quo=F,sep="\t")
