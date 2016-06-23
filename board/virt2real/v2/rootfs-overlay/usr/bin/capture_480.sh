#!/bin/sh

WIDTH=640
HEIGHT=480
DEST=~/t${WIDTH}.jpeg

if [ ! -z "$1" ]
then
DEST=$1
fi
echo "Dest: $DEST"

gst-launch -v -e v4l2src always-copy=FALSE chain-ipipe=true num-buffers=1  ! \
video/x-raw-yuv,format=\(fourcc\)NV12, width=$WIDTH, height=$HEIGHT ! \
dmaiaccel ! dmaienc_jpeg ! filesink location=$DEST
