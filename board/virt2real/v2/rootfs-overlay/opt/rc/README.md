# virt2real remote control

hdmi input and IR transmitter for controlling Dune and NTV+ reciever.

## read frames from stream

In the gst-pipeapp - access to the each frame in the flow.
This frames sending throu websocket to the clients.

Working pipe used by default:

```bash
gst-launch -v -e v4l2src always-copy=false chain-ipipe=true ! \
    capsfilter caps=video/x-raw-yuv,format=\(fourcc\)NV12,width=640,height=480,framerate=10/1  ! \
    dmaiaccel ! \
    dmaienc_jpeg ! \
    appsink name=sink drop=true
```

## lib

Библиотека позволяет моделировать работу gstreamer pipeline на OSX. Собрана из одних и тех же исходников,
что и рабочая версия для v2r - gst-pipeapp.

Сначала пытаемся загрузить libgstpipeapp.so, если неудачно, то переходим в dev режим и грузим библиотеку из lib.

## python 2.7.10 requierements

tornado - dev version from github, not package

future
futures
six
singledispatch
backports_abc>=0.4

## node and npm development tools


## send-ir.sh

External script for sending ir command.
In the script sudo /bin/echo need correct /etc/init/sudoers

```bash
svolkov ALL= NOPASSWD: /bin/echo
```