# Buildroot Boards
Внешиний конфиг buildroot для virt2real
v1_defconfig - стандартный v2r config
v2_defconfig - v2r as remote control config

## Install

```
cd /opt/virt2realsdk/fs
make BR2_EXTERNAL=/vagrant/buildroot-v2r-v1 v1_defconfig
cd ..
make fsconfig
make fsbuild
```

## BR2 overlay dir

add_br2_package_overlay_dir.patch

Позволяет менять параметры в стандартных пакетах buildroot без изменения исходников.
В текущей конфигурации нужно менять параметры для nginx - поддержка rtsp.

```
cd fs/
git patch ../buildroot-v2r-v1/add_br2_package_overlay_dir.patch
...
git checkout .
git pull upstream master
git patch  ../buildroot-v2r-v1/add_br2_package_overlay_dir.patch
```
## make image

```
time make build
make img_install
make img_umount
```

