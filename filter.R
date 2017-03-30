library(data.table)
test <- fread("res.f.uo") # read 21852707 rows and 8 (of 8) columns from 1.999 GB file in 00:00:33

# for completes (these will be the primary list for main and alt) 
test2 <- subset(test, V7=="C")
setorder(test2,V3,-V4,-V5)
test3 <- unique(test2,by="V1")
main1 <- subset(test3,V1==V2)
test3 <- subset(test3,V1!=V2)
query1 <- subset(test3,V4==100.0&V5==V6) # these are possibly exact matches that cd-hit missed
test3 <- subset(test3,V4!=100.0|V5!=V6)
dump1 <- subset(test3,V4==100.0&V5<V6) # these should have been picked up by cd-hit as well
test3 <- subset(test3,V4!=100.0|V5>V6)
query2 <- subset(test3,V5>V6) # should (nearly) always be empty
test3 <- subset(test3,V5<=V6)
alternate1 <- subset(test2,V5==V6)
test3 <- subset(test3,V5<V6)
altsmaller <- test3
altsmallerfilt <- subset(altsmaller,(V5/V6)>0.6)

# for incompletes (if worth while) - na dump 'em.

incompletes <- subset(test, V7!="C")

