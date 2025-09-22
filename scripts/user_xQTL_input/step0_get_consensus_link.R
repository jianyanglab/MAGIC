args=commandArgs(TRUE)
suppressMessages(library(data.table))
suppressMessages(library(dplyr))

ABC_file=args[1]
EpiMap_file=args[2]
RoadMap_file=args[3]
PCHiC_file=args[4]
Promoter_file=args[5]
ClosestTSS_file=args[6]
consensus_file=args[7]


ABC=fread(ABC_file,header=F)[,1:8]
ABC$source="ABC"

EpiMap=fread(EpiMap_file,header=F)[,1:8]
EpiMap$source="EpiMap"

RoadMap=fread(RoadMap_file,header=F)[,1:8]
RoadMap$source="RoadMap"

PCHiC=fread(PCHiC_file,header=F)[,1:8]
PCHiC$source="PCHiC"

Promoter=fread(Promoter_file,header=F)[,1:8]
Promoter$source="Promoter"

ClosestTSS=fread(ClosestTSS_file,header=F)[,1:8]
ClosestTSS$source="ClosestTSS"

data=data.frame()
data=rbind(data,ABC,EpiMap,RoadMap,PCHiC,Promoter,ClosestTSS)
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

