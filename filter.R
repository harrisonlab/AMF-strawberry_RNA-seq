### Filter UBLAST results for "good" transcripts
library(data.table)
library(dplyr)
res <- fread("res.uo") 

# remove transcripts with more than one hit to themselves
res_test <- subset(res,V1==V2)
xy <- table(res_test$V1)
xy <- data.table(xy)
xy <- data.table(xy[xy$N>1])
res <- data.table(anti_join(res,xy))

# get rid of shorter sequence with 97% sequence identity over 50% of length
dump_set <- subset(res,V6>V5&V7>=50) 
dump_set <- unique(dump_set,by="V1")
res <-data.table(anti_join(res,dump_set[,1,with=F]))
res <- data.table(subset(res,V1==V2))
#odd <- res[duplicated(res)]
#res <- anti_join(res,odd)

write.table(res[,1,with=F],"transcripts.fa",row.names=F,col.names=F,quote=F)
