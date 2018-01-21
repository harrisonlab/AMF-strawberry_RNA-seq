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
library(naturalsort)
library(tibble)


#===============================================================================
#       Load data from SALMON quasi mapping
#===============================================================================

library(tximport)
library(rjson)
library(readr)

# import transcript to gene mapping info
tx2gene <- read.table("trans2gene.txt",header=T,sep="\t")

# import quantification files	    
txi.reps <- tximport(paste(list.dirs("counts",full.names=T,recursive=F),"/quant.sf",sep=""),type="salmon",tx2gene=tx2gene,txOut=T)	    
	    
# get the sample names from the folders	    
mysamples <- list.dirs("counts",full.names=F,recursive=F)

# summarise to gene level (this can be done in the tximport step, but is easier to understand in two steps)
txi.genes <- summarizeToGene(txi.reps,tx2gene)

# set the sample names for txi.genes
invisible(sapply(seq(1,3), function(i) colnames(txi.genes[[i]])<<-mysamples))

#==========================================================================================
#       Read sample metadata and annotations
#=========================================================================================

# Read sample metadata	    
colData <- read.table("colData",header=T,sep="\t",row.names=1)
    
# reorder colData for salmon 		 
colData <- colData[mysamples,]
		 
# reorder colData for featureCounts		 
colData <- colData[colnames(countData),]
		 
# get annotations     
annotations <- read.table("annotations.txt", sep="\t",header=T)	  

#===============================================================================
#       DESeq2 analysis
#================================================================================

# create dds object from Salmon counts and sample metadata (library size normalisation is takne from the length estimates)		 
dds <- DESeqDataSetFromTximport(txi.genes,colData,~1)	    
   	    
# define the DESeq 'GLM' model	    
design=~condition

# add design to DESeq object	    
design(dds) <- design

# Run the DESeq statistical model	    
dds <- DESeq(dds,parallel=T)

# set the significance level for BH adjustment	    
alpha <- 0.05

# calculate the results
res <- results(dds,alpha=alpha)
    
# merge results with annotations
res.merged <- left_join(rownames_to_column(as.data.frame(res)),annotations,by=c("rowname"="query_id"))
	
# get significant results
sig.res <- subset(res.merge,padj<=alpha)

# write tables of results
write.table(res.merged,"results.txt",quote=F,na="",row.names=F,sep="\t")


#===============================================================================
#       Graphs
#===============================================================================
	
# calculate PCs				    
mypca <- des_to_pca(dds)
				    
# create data frame of PCs x variance (sets PCA plot axes to same scale)
df <- t(data.frame(t(mypca$x)*mypca$percentVar))

# plot
ggsave("pca.pdf",plotOrd(df,dds@colData,design="condition",xlabel="PC1",ylabel="PC2", pointSize=3,textsize=14))

# MA plots	
pdf("MA_plots.pdf")

# plot_ma is an MA plotting function 				    
lapply(res.merged,function(obj) {
	plot_ma(obj[,c(1:5,7]),xlim=c(-8,8))
})
dev.off()
