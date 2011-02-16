#!/bin/bash
#

cd ~/Desktop/iperms

FILES=~/Desktop/iperms/*
for f in $FILES
do
	echo "processing $f file..."
	# action
	tiff2pdf -o `basename $f .tif`.pdf $f
done
