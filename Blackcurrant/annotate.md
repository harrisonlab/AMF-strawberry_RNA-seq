
# Annotation


## Annotating with InterProscan 5

 -appl CDD,COILS,Gene3D,HAMAP,MobiDBLite,PANTHER,Pfam,PIRSF,PRINTS,ProDom,PROSITEPATTERNS,PROSITEPROFILES,SFLD,SMART,SUPERFAMILY,TIGRFAM

### Running interproscan
```shell
# annotation with interproscan

~/pipelines/common/scripts/interproscan.sh \
  /data/scratch/deakig/blackcurrant/genome \
  ribes.protein.fasta \
  /data/scratch/deakig/blackcurrant/genome/temp/
```
### restarting interproscan
```shell
# restarting interproscan
~/pipelines/common/scripts/restart_interproscan.sh \
 /data/scratch/deakig/blackcurrant/genome \
 ribes.protein.fasta \
 /data/scratch/deakig/blackcurrant/genome/temp/ \
 -appl CDD,COILS,HAMAP,MobiDBLite,Pfam,PIRSF,PRINTS,ProDom,PROSITEPATTERNS,PROSITEPROFILES,SFLD,SMART,SUPERFAMILY,TIGRFAM \
 -iprlookup \
 -goterms \
 -pa \
 -dra
```

### merge interproscan results
```shell
cat *.tsv > all.txt
```

### Reshape interproscan results
```R
library(data.table)
library(dplyr)

# load allannotations file
annotations <- fread("all.txt",header=F,fill=T)
# add colnames
colnames(annotations) <- c("PROT_ID","MD5","LENGTH","ANALYSIS","MATCH_ID","MATCH_DESC","START","STOP","E_VAL","STATUS","DATE","IPR_ID","IPR_DESC","GO_ID","PATHWAY")
# add gene data (from exon data)
annotations$GENE <- sub("\\..*","",annotations$PROT_ID)
annotations$EXON <- gsub("(.*\\.)([0-9]+)(_.*)","\\2",annotations$PROT_ID)
annotations$FRAME <- gsub("(.*\\.[0-9]+_)([0-9]+)(_.*)","\\2",annotations$PROT_ID)
annotations$ORF <- gsub(".*_","",annotations$PROT_ID)
annotations$DIRECTION <- gsub("(.*\\.[0-9]+_[0-9]+_)([A-Z]+)(_.*)","\\2",annotations$PROT_ID)
annotations$DIRECTION <- sub("F","\\+",annotations$DIRECTION)
annotations$DIRECTION <- sub("RC","\\-",annotations$DIRECTION)
write.table(annotations,"full_annotations.txt",sep="\t",row.names=F,quote=F,na="")

# subset annotations with GeneID an anaylses results
slim_annot <- annotations[,c(16,4,5,6,12,13,14,15)]
# remove MobiDBLite and Coils results (or keep if they're useful to you)
slim_annot <- slim_annot[ANALYSIS!="MobiDBLite"|ANALYSIS!="Coils",]
slim_annot$ANALYSIS <- as.factor(slim_annot$ANALYSIS)
write.table(slim_annot,"slim_annotations_v1.txt",sep="\t",row.names=F,quote=F,na="")

# subset just IPR and GO data
slim_annot2 <- slim_annot[IPR_ID!=""|GO_ID!="",]
slim_annot2 <- slim_annot[,c(1,5,6,7,8)]
slim_annot2
write.table(slim_annot2,"slim_annotations_v2.txt",sep="\t",row.names=F,quote=F,na="")

### reshape data ###

slim_annotations <- slim_annot
slim_annotations$ANALYSIS <- as.factor(slim_annotations$ANALYSIS)

# convert to list of datatables for each analysis
df_annotations <- lapply(levels(slim_annotations$ANALYSIS),function(l) slim_annotations[ANALYSIS==l])

# add names
names(df_annotations) <- levels(slim_annotations$ANALYSIS)

# drop duplicates from all tables
df_annotations <- lapply(df_annotations,function(l) l[!duplicated(l)])

# split "|" seperated strings 
long_annotations <- lapply(df_annotations,function(l) l[, strsplit(as.character(GO_ID), "|", fixed=TRUE), by = .(GENE,MATCH_ID,MATCH_DESC,IPR_ID,IPR_DESC,PATHWAY,GO_ID)][,.(GENE,MATCH_ID,MATCH_DESC,IPR_ID,IPR_DESC,PATHWAY,GO_ID = V1)])


# extract IPR info
IPR <- do.call(rbind, lapply(long_annotations, subset, select=c("GENE", "IPR_ID","IPR_DESC")))
IPR <- IPR[!duplicated(IPR)]

# extract GO info
GO <- do.call(rbind, lapply(long_annotations, subset, select=c("GENE", "GO_ID")))
GO <- GO[!duplicated(GO)]

# extract PATHWAY info
PATHWAY <- do.call(rbind, lapply(long_annotations, subset, select=c("GENE", "PATHWAY")))
PATHWAY <- PATHWAY[!duplicated(PATHWAY)]

# drop none specific analysis stuff from each table
dt_annotations <-   lapply(df_annotations, subset, select=c("GENE", "MATCH_ID","MATCH_DESC"))
# and rename MATCH to name of analysis
lapply(seq_along(dt_annotations),function(i) {
	new_name <- toupper(names(dt_annotations[i]))
	colnames(dt_annotations[[i]])[2] <<- sub("MATCH",new_name,colnames(dt_annotations[[i]])[2])
	colnames(dt_annotations[[i]])[3] <<- sub("MATCH",new_name,colnames(dt_annotations[[i]])[3])
})	

# add go and ipr details to list of datatables
dt_annotations$IPR <- IPR
dt_annotations$GO <- GO
dt_annotations$PATHWAY <- PATHWAY

# collapse genes with more than one annotation for an anlysis
dt_annotations <- lapply(dt_annotations,function(dt) dt[,lapply(.SD, paste,collapse="|"),by = GENE])
# remove "||" errors produced by collapse (not certain why it does this)
dt_annotations <- lapply(dt_annotations,function(dt) 
	as.data.table(lapply(dt, function(x) gsub("^\\||\\|$","",gsub("\\|\\|+", "\\|", x))))
)

# merge list of datatable back together
merged_annotations <- Reduce(function(...) merge(..., all = TRUE), dt_annotations)
# and set NA to ""
merged_annotations[is.na(merged_annotations)] <- ""

annotations <- merged_annotations
write.table(annotations,"ip_annotations.txt",sep="\t",na="",quote=F,row.names=F)
```
```
