#!/bin/bash
#

LIST='*.avi'
for z in $LIST; do

#echo $z;

HandBrakeCLI -e x264 -x bframes=2:subme=6:mixed-refs=0:weightb=0:8x8dct=0:trellis=0:ref=2 -q .51 -5 -E faac -B 96 -R 44.1 -6 stereo -D 1.0 -i ./"$z" -o ./"$z".m4v;

mv "$z.m4v" "`basename "$z.m4v" .avi.m4v`.m4v";

mv "$z" "$z.bak";

done;

tar -cvvf backup.tar ./*.avi.bak;

rm *.avi.bak;
