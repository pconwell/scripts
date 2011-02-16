#!/bin/bash
#

FILES=~/Desktop/iperms/*
for f in $FILES
do
	echo "processing $f file..."
	tiff2pdf -o `basename $f .tif`.pdf $f
done
