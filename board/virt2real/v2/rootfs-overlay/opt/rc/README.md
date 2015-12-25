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

Нет драйвера lirc для v2r - пришлось читать коды пультов на RPI в raw режиме (ключ -f) записал
конфиги и перенес на v2r.

Драйвер v2r_irsend понимает raw данные, если их ему правильно заслать, для этого на базе примера
из вики сделал v2r-irsend - принимает данные из параметров и дополнительно позволяет повторить набор
- ключ -c. Повтор команд нужен для KEY_POWER для DUNE - в противном случае не просыпается.

Драйвер посылает согнал на GPIO90.

Extrnal script for sending ir command.
In the script sudo /bin/echo need correct /etc/init/sudoers

```bash
svolkov ALL= NOPASSWD: /bin/echo
```

## relay control

Дополнительно подключено два реле, для перезагрузки по питанию приемника НТВ+ и Dune.

В процессе обнаружил проблему совместимости 3,3v выхода с китайскими релюшками, пришлось 
дополнительно ставить NPN транзистор, в цепь управления добавил буферный резистор 220Ом, 
в противном случае не показывал hi level на выходе (примерно 1,5В).

```
cat /sys/kernel/debug/gpio
echo "set gpio 08 output 1" > /dev/v2r_gpio
echo "set gpio 09 output 1" > /dev/v2r_gpio
```
