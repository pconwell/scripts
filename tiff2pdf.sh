#!/bin/bash
#

## Converts all .tiff files in folder to .pdf files. Must have tiff2pdf installed.

FILES=~/Desktop/iperms/*
for f in $FILES
do
	echo "processing $f file..."
	tiff2pdf -o `basename $f .tif`.pdf $f
done
