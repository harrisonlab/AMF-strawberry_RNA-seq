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

write.table(

