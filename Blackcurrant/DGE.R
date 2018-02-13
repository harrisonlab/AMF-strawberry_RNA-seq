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
invisible(sapply(seq(1,3), function(i) {
	colnames(txi.genes[[i]])<<-mysamples)
})

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
annotations <- fread("ip_annotations.txt", sep="\t",header=T)	  

#===============================================================================
#       DESeq2 analysis
#================================================================================

# create dds object from Salmon counts and sample metadata (library size normalisation is takne from the length estimates)		 
dds <- DESeqDataSetFromTximport(txi.genes,colData,~1)	    

# set the significance level for BH adjustment	    
alpha <- 0.05
		 
# Chill hours		 
dds$Chill.hours[is.na(dds$Chill.hours)] <- 0
dds$Chill.hours <- as.factor(dds$Chill.hours)
design=~Chill.hours
design(dds) <- design
dds <- DESeq(dds,parallel=T)
disp <- dispersions(dds)
res_chill <-  results(dds,alpha=alpha,parallel=T,contrast=c("Chill.hours","1597","398"))
res.merged <- left_join(rownames_to_column(as.data.frame(res_chill)),annotations,by=c("rowname"="GENE"))
colnames(res.merged)[1] <- "GENE"
write.table(res.merged,"res_chill.tlb",sep="\t",quote=F,na="",row.names=F)
	  
# Treatment effect
dds$T_treat <- as.factor(paste(dds$Treatment,dds$Time_point,sep="_"))
design=~T_treat
design(dds) <- design
dds <-  DESeq(dds,parallel=T)
res_treat <- results(dds,parallel=T,contrast=c("T_treat","E3_24th.March.","None_24th.March."))
res.merged <- left_join(rownames_to_column(as.data.frame(res_treat)),annotations,by=c("rowname"="GENE"))
colnames(res.merged)[1] <- "GENE"
write.table(res.merged,"res_treat.tlb",sep="\t",quote=F,na="",row.names=F)

res_treat_tp1 <- results(dds,parallel=T,contrast=c("T_treat","E3_20th March","None_20th March"))
res.merged <- left_join(rownames_to_column(as.data.frame(res_treat_tp1)),annotations,by=c("rowname"="GENE"))
colnames(res.merged)[1] <- "GENE"
write.table(res.merged,"res_treat_tp1.tlb",sep="\t",quote=F,na="",row.names=F)
	  
	  
# time effect
full_design <- ~Time_point
design(dds) <- full_design
dds <- DESeq(dds,reduced=~1,parallel=T,test="LRT")
res_time <- results(dds,parallel=T)
res.merged <- left_join(rownames_to_column(as.data.frame(res_time)),annotations,by=c("rowname"="GENE"))
colnames(res.merged)[1] <- "GENE"
write.table(res.merged,"res_time.tlb",sep="\t",quote=F,na="",row.names=F)


# treatment over time effect
# no time 0 for treated - therefore can't estimate treatment effect (https://support.bioconductor.org/p/95929/)
# the below will work though (effectively it's looking at the interaction effect at t1 and t2, compared to the time effect)
dds2 <- dds[,dds$Time_point!="22nd Feb "]
dds2$Time_point <- droplevels(dds2$Time_point)	  
mm <- model.matrix(~Time_point + Treatment:Time_point,colData(dds2))
#mm <- model.matrix(~dds$Time_point + dds$Treatment*dds$Time_point)
mm.full <- mm[,c(-4)]
mm.reduced <- mm.full[,1:3]
dds2 <- DESeq(dds2, full=mm.full, reduced=mm.reduced, test="LRT",parallel=T)
res_treatment_time <- results(dds2,parallel=T)
res.merged <- left_join(rownames_to_column(as.data.frame(res_treatment_time)),annotations,by=c("rowname"="GENE"))
colnames(res.merged)[1] <- "GENE"
write.table(res.merged,"res_treatment_time.tlb",sep="\t",quote=F,na="",row.names=F)
	  
#full_design <- ~Time_point + Treatment + Time_point*Treatment
#reduced <- ~Time_point + Treatment

#dds <- nbinomLRT(dds,reduced=reduced)

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
 ggsave("pca.pdf",plotOrd(df,dds@colData,design="Time_point",shapes=c("Treatment","Description"),alpha=0.75,))

# MA plots	
pdf("MA_plots.pdf")

# plot_ma is an MA plotting function 				    
lapply(res.merged,function(obj) {
	plot_ma(obj[,c(1:5,7]),xlim=c(-8,8))
})
dev.off()
