#===============================================================================
#       Load libraries
#===============================================================================

library(DESeq2)
library("BiocParallel")
register(MulticoreParam(12))
library(ggplot2)
library(Biostrings)
library(devtools)
load_all("~/pipelines/RNA-seq/scripts/myfunctions")
library(data.table)
library(dplyr)
library(tximport)
library(rjson)
library(readr)
library(tibble)

#===============================================================================
#       Load data from SALMON quasi mapping
#===============================================================================

# import transcript to gene mapping info
tx2gene <- read.table("trans2gene.txt",header=T,sep="\t")

# import quantification files	
txi.reps <- tximport(paste(list.dirs("../../data/RNA_seq_analysis/counts/salmon/",full.names=T,recursive=F),"/quant.sf",sep=""),type="salmon",tx2gene=tx2gene,txOut=T)

# summarise transcripts to gene level 
txi.genes <- summarizeToGene(txi.reps,tx2gene)

# get the sample names from the folders	   
mysamples <- list.dirs("../../data/RNA_seq_analysis/counts/salmon/",full.names=F,recursive=F)

# set the sample names for txi.genes
invisible(sapply(seq(1,3), function(i) colnames(txi.genes[[i]])<<-mysamples))

#==========================================================================================
#       Read pre-prepared sample metadata and annotations
#=========================================================================================

# Read sample metadata	    
colData <- read.table("colData",header=T,sep="\t",row.names=1)

# reorder colData 	 
colData <- colData[mysamples,]

# load gene annotations
go_annot <- fread("gene_go_annot.txt")

# We're using transcripts and genes
colnames(go_annot)[1] <- "TRANSCRIPT_ID"

# This may cause problems later...
go_annot$GENE_ID <- sub("\\..*","",go_annot$TRANSCRIPT_ID)

#===============================================================================
#       DESeq2 analysis
#=========================================================================================

#  create DESeq object from Salmon counts and sample metadata		 
dds <- DESeqDataSetFromTximport(txi.genes,colData,~1)	

# dds$groupby <- paste(dds$condition,dds$sample,sep="_")
# dds <- collapseReplicates(dds,groupby=dds$groupby)

# define the DESeq  model	    
design=~block+condition

# add design to DESeq object	    
design(dds) <- design

# Run the DESeq statistical model	    
dds <- DESeq(dds,parallel=T)

# set the significance level for BH adjustment	    
alpha <- 0.05

res <- results(dds,alpha=alpha)

#### Week 4 or 6  #####

# remove (or keep) block4 (week 6) data
dds2 <- dds[,dds$block!="B4"]   # week 4
#dds2 <- dds[,dds$block=="B4"]  # week 6
                 
# remove unused levels from block and time columns
dds2$block <- droplevels(dds2$block)

# model design - remove block effect
design=~block+condition #+block:condition
# design=~condition # week 6 (no block info)
 
# add model to dds
design(dds2) <- design 

# calculate model
dds2 <- DESeq(dds2,parallel=T)

# set significance level for BH cut-off
alpha=0.05

# Contrast is what we want to compare (AMF vs Control samples here)
contrast=c("condition","AMF","control")

# calculate the contrast from the dds object
res <- results(dds2,alpha=alpha,contrast=contrast,parallel=T)

# summary of results
summary(res)

# merge results with annotation file
res.merge <- left_join(rownames_to_column(as.data.frame(res)),go_annot,by=c("rowname"="GENE_ID"))

# write output
write.table(res.merge,"w6_amf_vs_ctrl.txt",sep="\t",quote=F,row.names=F,na="")

# AMF vs Sterile
contrast=c("condition","AMF","Sterile")
res <- results(dds2,alpha=alpha,contrast=contrast,parallel=T)
summary(res)
res.merge <- left_join(rownames_to_column(as.data.frame(res)),go_annot,by=c("rowname"="GENE_ID"))
write.table(res.merge,"w6_AMF_vs_sterile.txt",sep="\t",quote=F,row.names=F,na="")

# AMF vs Sterile_filtrate
contrast=c("condition","AMF","Sterile_Filtrate")
res <- results(dds2,alpha=alpha,contrast=contrast,parallel=T)
summary(res)
res.merge <- left_join(rownames_to_column(as.data.frame(res)),go_annot,by=c("rowname"="GENE_ID"))
write.table(res.merge,"w6_AMF_vs_sterile_filtrate.txt",sep="\t",quote=F,row.names=F,na="")                 
                 
# Sterile vs control
contrast=c("condition","Sterile","control")
res <- results(dds2,alpha=alpha,contrast=contrast,parallel=T)
summary(res)
res.merge <- left_join(rownames_to_column(as.data.frame(res)),go_annot,by=c("rowname"="GENE_ID"))
write.table(res.merge,"w6_sterile_vs_ctrl.txt",sep="\t",quote=F,row.names=F,na="")

# Sterile_Filtrate vs control
contrast=c("condition","Sterile_Filtrate","control")
res <- results(dds2,alpha=alpha,contrast=contrast,parallel=T)
summary(res)
res.merge <- left_join(rownames_to_column(as.data.frame(res)),go_annot,by=c("rowname"="GENE_ID"))
write.table(res.merge,"w6_Sterile_Filtrate_vs_ctrl.txt",sep="\t",quote=F,row.names=F,na="")
                 
# Sterile vs Sterile_Filtrate
contrast=c("condition","Sterile","Sterile_Filtrate")
res <- results(dds2,alpha=alpha,contrast=contrast,parallel=T)
summary(res)
res.merge <- left_join(rownames_to_column(as.data.frame(res)),go_annot,by=c("rowname"="GENE_ID"))
write.table(res.merge,"w6_sterile_vs_Sterile_Filtrate.txt",sep="\t",quote=F,row.names=F,na="")
            
#===============================================================================
#       PCA analysis
#===============================================================================

mypca <- des_to_pca(dds)
df <- t(data.frame(t(mypca$x)*mypca$percentVar))
pdf("AMF.pca.pdf",height=8,width=8)
plotOrd(df,dds@colData,design="condition",shape="time",xlabel="PC1",ylabel="PC2", pointSize=3,textsize=12)
dev.off()

# residual plot after removing block
pc.res <- resid(aov(mypca$x~dds$block))
df <- data.frame(pc.res[,1]*mypca$percentVar[1],pc.res[,2]*mypca$percentVar[2])
plotOrd(df,dds@colData,design="condition",xlabel="PC1",ylabel="PC2", pointSize=3,textsize=12)
    
