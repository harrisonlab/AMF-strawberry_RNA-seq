library(data.table)
test <- fread("res2.uo") # read 21852707 rows and 8 (of 8) columns from 1.999 GB file in 00:00:33

library(dplyr)
test2 <- test
dump_set <- subset(test2,V6>V5&V7>=50) # get rid of any subsequences (97% sequence identity over 50 length length)
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

# get (well dump) alternatives + keep one primary
a1 <- subset(test3,V5==V6&V7==V8)
test3 <- anti_join(test3,a1)
## send anything with an alternative already in primary, to alternative 
a2 <- unique(inner_join(data.table(a1[,V2]),primary[,1,with=F])) # V2 (i.e. matching column) is in primary
colnames(a2) <- "V2"
a3 <- data.table(unique(inner_join(a1,a2)[,V1]))
alternatives <- inner_join(a1,a3)
a1 <- anti_join(a1,alternatives)
setorder(a1,-V5)
e1 <- new.env()
e2 <- new.env()
sink("/dev/null")
apply(a1,1,quickfunc)  
sink(NULL)
primary2 <- data.table(ls(e1))
alternatives2 <- data.table(ls(e2))
rm(e1,e2)

test4 <- anti_join(test3,primary2)
test4 <- anti_join(test4,alternatives)
test4 <- anti_join(test4,alternatives2)

#write.table(primary[,1,with=F],"primary.txt",row.names=F,col.names=F,quote=F)
#write.table(a1[,1:2,with=F],"alternative.txt",row.names=F,col.names=F,quote=F)
write.table(output,"prim2.txt",col.names=F,row.names=F,quote=F)

quickfunc <- 
function(x) {
	y=(exists(x[1],envir=e1)*1)+(exists(x[2],envir=e1)*2)+(exists(x[1],envir=e2)*4)+(exists(x[2],envir=e2)*8);
	if(y==0) {e1[[x[1]]]="";e2[[x[2]]]="";}
	else if(y==2|y==8) {e2[[x[1]]]=""}
	else if(y==1|y==4) {e2[[x[2]]]=""}
}	
    
### OLD VERSION
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

