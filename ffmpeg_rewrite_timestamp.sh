#!/bin/bash

FILES="*.avi"
for f in $FILES
do
  echo "Processing $f"
  ffmpeg -y -i $f -map 0:v -c:v libx264 -bsf:v h264_mp4toannexb raw.h264
  f_name=`basename $f .avi`
  ffmpeg -y -fflags +genpts -r 200 -i raw.h264 -c:v copy $f_name.mp4
done