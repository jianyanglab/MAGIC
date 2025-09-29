suppressMessages(library("optparse"))
option_list = list(
        make_option("--INFILE", action="store", default=NA, type='character',
              help="Path to epi file [required]"),
        make_option("--out", action="store", default=NA, type='character',
              help="Path to bed file [required]"))
opt = parse_args(OptionParser(option_list=option_list))
options(scipen = 100)
epi=read.table(opt$INFILE,head=F,stringsAsFactors=F)
bed=epi[,c(1,4,4,2)]
bed[,3]=bed[,2]+1
bed[,1]=paste0("chr",bed[,1])
write.table(bed,opt$out,row=F,col=F,quo=F,sep="\t")

