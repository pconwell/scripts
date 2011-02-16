#!/bin/bash
#

season='15' #<-Change this
post=' [rl].avi'
ext='.avi'

LIST="*.avi"
for i in $LIST; do

t=`echo $i | awk '{ sub(/Simpsons 15x/, ""); print }' `; #<- And this /Simpsons 0#x/

b=`basename "$t" "$post"`;

n=$season$b$ext;

#echo $i;
#echo $n;

mv "$i" "$n";

done;
