args=commandArgs(TRUE)

suppressMessages({
  library(data.table)
  library(dplyr)
})


qtl_name=args[1]
user_e2g_list=args[2]
OUTPUT=args[3]
# ABC_file=args[1]
# EpiMap_file=args[2]
# RoadMap_file=args[3]
# PCHiC_file=args[4]
# Promoter_file=args[5]
# ClosestTSS_file=args[6]
consensus_file=args[4]

print(paste0("user_e2g_list: ",user_e2g_list))

data=data.frame()
e2g_list=fread(user_e2g_list,header=F)
for(e2g_i in 1:nrow(e2g_list)){
  e2g_name=e2g_list$V1[e2g_i]

  e2g_file=paste0(OUTPUT,"/MAGIC/user_xQTL/",qtl_name,"_",e2g_name,".link")
  print(paste0("Processing file: ", e2g_file))

  e2g_data_temp=fread(e2g_file,header=F)[,1:8] 
  e2g_data_temp$source=e2g_name
  
  data=rbind(data,e2g_data_temp)
}


# ABC=fread(ABC_file,header=F)[,1:8]
# ABC$source="ABC"

# EpiMap=fread(EpiMap_file,header=F)[,1:8]
# EpiMap$source="EpiMap"

# RoadMap=fread(RoadMap_file,header=F)[,1:8]
# RoadMap$source="RoadMap"

# PCHiC=fread(PCHiC_file,header=F)[,1:8]
# PCHiC$source="PCHiC"

# Promoter=fread(Promoter_file,header=F)[,1:8]
# Promoter$source="Promoter"

# ClosestTSS=fread(ClosestTSS_file,header=F)[,1:8]
# ClosestTSS$source="ClosestTSS"

# data=data.frame()
# data=rbind(data,ABC,EpiMap,RoadMap,PCHiC,Promoter,ClosestTSS)
# data$pair=paste0(data$V4,"----",data$V8)

data$pair=paste0(data$V4,"----",data$V8)


pair_counts <- data %>%
  group_by(pair) %>%
  summarise(source_count = n_distinct(source))

final_data <- data %>%
  left_join(pair_counts, by = "pair") %>%
  filter(source_count >= 3) %>%
  select(-source, -pair) %>%
  distinct()

write.table(final_data, consensus_file, row=F,col=F,quo=F,sep="\t")

