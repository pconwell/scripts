#!/bin/bash
#

#****************************************************************
## Set your device here:
device=passion

## Remove app list
rm_apk_list="Development.apk"

## Setup directories
mkdir -p ~/Desktop/custom_build/temp
out=~/android/system/out/target/product/passion
work=~/Desktop/custom_build
#****************************************************************
## Check for updates and make the build
cd ~/android/system
repo sync -j16
. build/envsetup.sh && brunch $device
#****************************************************************
## copy finished (non-squished) .zip to work directory
zip1=`ls $out | grep ota | grep -v md5`
cp $out/$zip1 $work/temp/$zip1

## unzip and clean up
cd $work/temp
unzip $zip1 && rm $zip1
}

## Add any apps & libs from $work/add_[apk/lib]/ to the custom build
cp $work/add_apk/* $work/temp/system/app/
cp $work/add_lib/* $work/temp/system/lib/ 

## Replace default audio with $work/replace_media/audio/ (if it exists) to the custom build
if [ -d "$work/replace_media/audio"]
	rm -rf $work/temp/system/media/audio
	cp -R $work/replace_media/audio $work/temp/system/media/
fi

## Remove unwanted apps (from Remove app list ^^ up there)
for apk in $rm_apk_list; do
	echo "     Removing $apk"
	rm  $work/temp/system/app/$apk
done

## Zip
cd $work/temp/
zip -r $zip1 *
#****************************************************************
## move to /out and (re)squish (basically, we just need to resign the package - and this is a lazy way to do it)
cp $work/temp/$zip1 $out/$zip1
~/android/system/vendor/cyanogen/tools/squisher
}

## move and rename finished file to ~/Desktop
cp $out/`ls $out | grep update | grep -v md5` ~/Desktop/$device-custom_`date +%s`.zip
