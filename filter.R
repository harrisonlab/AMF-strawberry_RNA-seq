library(data.table)
library(dplyr)

res <- fread("res.uo") # read 21852707 rows and 8 (of 8) columns from 1.999 GB file in 00:00:33
dump_set <- subset(res,V6>V5&V7>=50) # get rid of shorter sequence with 97% sequence identity over 50% of length
dump_set <- unique(dump_set,by="V1")
res <-anti_join(res,dump_set[,1,with=F])
res <- subset(res,V1==V2)
odd <- res[duplicated(res)]
res <- anti_join(res,odd)

write.table(res[,1,with=F],"transcripts.txt",row.names=F,col.names=F,quote=F)
