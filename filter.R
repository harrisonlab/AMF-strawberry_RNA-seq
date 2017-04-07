library(data.table)
test <- fread("res2.uo") # read 21852707 rows and 8 (of 8) columns from 1.999 GB file in 00:00:33

# for completes (these will be the primary list for main and alt) 
test2 <- test# subset(test, V7=="C")
setorder(test2,V3,-V4,-V5)
test3 <- unique(test2,by="V1")
primary <- subset(test3,V1==V2)
test3 <- subset(test3,V1!=V2)
#query1 <- subset(test3,V4==100.0&V5==V6) # these are possibly exact matches that cd-hit missed
query1 <- subset(test3,V9==0&V5==V6)
test3 <- subset(test3,V9!=0|V5!=V6)
# dump1 <- subset(test3,V4==100.0&V5<V6) # these should have been picked up by cd-hit as well
dump1 <- subset(test3,V9==0&V7==100)
test3 <- subset(test3,V9!=0|V5>V6)
query2 <- subset(test3,V5>V6) # should (nearly) always be empty
test3 <- subset(test3,V5<=V6)
dump2 <- subset(test3,V7==100&V8<=97) # 100% subsequence of longer sequence
test3 <- subset(test3,V7!=100|V8>97)
alt_test <- subset(test3,abs(V6-V5)<=50)
iso_test <- subset(test3,abs(V6-V5)>50)
iso_dump <- subset(iso_test,(1-V7/100)*V5<25)
iso_test <- subset(iso_test,(1-V7/100)*V5>=25)


library(dplyr)
test2 <- test
dump_set <- subset(test2,V6>V5&V7>=90) # get rid of any subsequences (97% sequence identity over 100 length)
#test2<-anti_join(test2,dump_set)
dump_set <- unique(dump_set,by="V1")
test2<-anti_join(test2,dump_set[,1,with=F])

# get primary sequence
test3 <- subset(test2,V1!=V2)
sames <- anti_join(test2,test3)
odd <- sames[duplicated(sames)] # palindromes, repetitive etc.
sames <- anti_join(sames,odd)
test3 <- subset(test3,V7>=V8) # get subsequences of longer sequence
primary <- unique(inner_join(sames, anti_join(sames[,1,with=F],test3[,1,with=F])))

# get alternatives + one primary
a1 <- subset(test3,V5==V6&V7==V8)
test3 <- anti_join(test3,a1)
## send anything with an alternative already in primary, to alternative 
a2 <- unique(inner_join(data.table(a1[,V2]),primary[,1,with=F])) # V2 (i.e. matching column) is in primary
colnames(a2) <- "V2"
a3 <- data.table(unique(inner_join(a1,a2)[,V1]))
alternatives <- inner_join(a1,a3)
a1 <- anti_join(a1,alternatives)
setorder(a1,-V5)
## abritarily select primary sequence and move rest to alternatives (which will probably be dumped!)
## this is exceptionally slow - I'll rewrite and using perl hashes
#dic1<-list()
#dic2<-list()
#for (i in 1:dim(a1)[1]){
#  if(is.null(dic1[[a1$V1[i]]])) {
#    if(is.null(dic1[[a1$V2[i]]])){
#      dic1<-append(dic1,a1$V1[i])
#      if(is.null(dic2[[a1$V2[i]]])){
#        dic2<-append(dic2,a1$V2[i])
#      }
#    } else {
#      if(is.null(dic2[[a1$V1[i]]])){
#        dic2<-append(dic2,a1$V1[i])
#      }
#    }  
#  } else {
#    if(is.null(dic2[[a1$V2[i]]])){
#      dic2<-append(dic2,a1$V2[i])
#    }
#  }
#}

write.table(primary[,1,with=F],"primary.txt",row.names=F,col.names=F,quote=F)

write.table(a1[,1:2,with=F],"alternative.txt",row.names=F,col.names=F,quote=F)
