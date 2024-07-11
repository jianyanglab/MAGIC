####################################################################################################
# MAGIC functions
####################################################################################################
ACAT <- function(p){
    library(mgcv)
    if (all(is.na(p))) return(NA)
    p <- p[!is.na(p)]
    #### check if there are very small non-zero p values
    is.small <- (p < 1e-15)
    if (sum(is.small) == 0) {
        cct.stat <- sum(tan((0.5 - p) * pi))/length(p)
    } else {
        cct.stat <- sum((1 / p[is.small]) / pi)
        cct.stat <- cct.stat + sum(tan((0.5 - p[!is.small]) * pi))
        cct.stat <- cct.stat/length(p)
    }
    #### check if the test statistic is very large.
    if (cct.stat > 1e+15){
        pval <- (1 / cct.stat) / pi
    } else {
        pval <- 1 - pcauchy(cct.stat)
    }
    pval
}


####################################################################################################
# Load SMR results functions
####################################################################################################
rm_mhc_hg38=function(smr,mhcStart=28510120,mhcEnd=33480577){
    idx=which(smr$ProbeChr==6 & ((smr$Probe_bp<=mhcEnd & smr$Probe_bp>=mhcStart) | (smr$topSNP_bp<=mhcEnd & smr$topSNP_bp>=mhcStart)))
    if(length(idx)>0){
        smr=smr[-idx,]
    }
    return(smr)
}

# read SMR results from eQTL, sQTL, and pQTL
read_smr_data1 <- function(SMR_DIRT, result, trait_name, qtl_type) {
	file_list1 <- list.files(SMR_DIRT)
	index <- grep(paste0("^", trait_name, "_", qtl_type, ".*\\.msmr$"), file_list1)
	file_list <- file_list1[index]

	print(paste0("Combining SMR results for ", trait_name,": ", length(file_list), " ", qtl_type))
	SMR_p_ACAT=matrix(NA,nrow=nrow(result),ncol=length(file_list))
	SMR_probeID=matrix(NA,nrow=nrow(result),ncol=length(file_list))
	qtl_name_list=c()

	for(i in 1:length(file_list)) {
		infile = file_list[i]
		# print(infile)
		qtl_name = gsub(paste0("^", trait_name, "_(.*)_chrALL\\.msmr$"), "\\1", infile)
		qtl_name_list=c(qtl_name_list, qtl_name)
		
		smr <- fread(paste0(SMR_DIRT,infile),head=T,stringsAsFactors=F,data.table=F)
		smr <- rm_mhc_hg38(smr)
		if(nrow(smr)>0){
			smr$QTL_name = qtl_name
        	smr$p_ACAT = apply(smr[,c("p_SMR","p_SMR_multi")],1,ACAT)
        	smr$probeID=str_split_fixed(smr$probeID,"\\.",Inf)[,1]
		
			index=match(smr$probeID,result$gene_id,nomatch=0)
        	smr$Gene[which(index!=0)]=result$gene_name[index]

			smr=smr %>% group_by(Gene) %>% filter(p_ACAT==min(p_ACAT)) %>% ungroup() %>% data.frame()
			index=match(result$gene_name,smr$Gene,nomatch=0)

			SMR_p_ACAT[which(index!=0), i] = smr$p_ACAT[index]
			SMR_probeID[which(index!=0), i] = smr$probeID[index]
		}
	}
	
	colnames(SMR_p_ACAT)=paste0("p_ACAT_",qtl_name_list)
	colnames(SMR_probeID)=paste0("probeID_", qtl_name_list)
	rownames(SMR_p_ACAT)=rownames(SMR_probeID)=result$gene_name

	return(list(SMR_p_ACAT=SMR_p_ACAT, SMR_probeID=SMR_probeID))
}



# read SMR results from caQTL, mQTL, and hQTL
read_smr_data2 <- function(SMR_DIRT, result, trait_name, qtl_type, QTL_link) {
	file_list1 <- list.files(SMR_DIRT)
	index <- grep(paste0("^", trait_name, "_", qtl_type, ".*\\.msmr$"), file_list1)
	file_list <- file_list1[index]

	print(paste0("Combining SMR results for ", trait_name,": ", length(file_list), " ", qtl_type))
	SMR_p_ACAT=matrix(NA,nrow=nrow(result),ncol=length(file_list))
	SMR_probeID=matrix(NA,nrow=nrow(result),ncol=length(file_list))
	qtl_name_list=c()

	for(i in 1:length(file_list)) {
		infile = file_list[i]
		# print(infile)
		qtl_name = gsub(paste0("^", trait_name, "_(.*)_chrALL\\.msmr$"), "\\1", infile)
		qtl_name_list=c(qtl_name_list, qtl_name)

		smr <- fread(paste0(SMR_DIRT,infile),head=T,stringsAsFactors=F,data.table=F)
		smr <- rm_mhc_hg38(smr)
		if(nrow(smr) > 0){
			smr$QTL_name = qtl_name
			smr$p_ACAT = apply(smr[,c("p_SMR","p_SMR_multi")],1,ACAT)

			# qvlaue=qvalue(smr_data$p_ACAT)$qval
			# index=which(qvlaue<0.05 & smr_data$p_HEIDI>=0.01)
			# index=which(smr_data$p_ACAT<0.05 & smr_data$p_HEIDI>=0.01)

			index=match(smr$probeID,QTL_link$V4,nomatch=0)
			smr$Gene[which(index!=0)]=QTL_link$V8[index]

			smr=smr %>% group_by(Gene) %>% filter(p_ACAT==min(p_ACAT)) %>% ungroup() %>% data.frame()
			index=match(result$gene_name, smr$Gene, nomatch=0)

			SMR_p_ACAT[which(index!=0), i] = smr$p_ACAT[index]
			SMR_probeID[which(index!=0), i] = smr$probeID[index]
		}
	}

	colnames(SMR_p_ACAT)=paste0("p_ACAT_",qtl_name_list)
	colnames(SMR_probeID)=paste0("probeID_", qtl_name_list)
	rownames(SMR_p_ACAT)=rownames(SMR_probeID)=result$gene_name

	return(list(SMR_p_ACAT=SMR_p_ACAT, SMR_probeID=SMR_probeID))
}


