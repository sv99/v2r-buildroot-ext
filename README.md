# Buildroot Boards
Внешиний конфиг buildroot для virt2real
v1_defconfig - стандартный v2r config
v2_defconfig - v2r as remote control config

## Install

```
cd /opt/virt2realsdk/fs
make BR2_EXTERNAL=../v2r-buildroot-ext v2_defconfig
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
git apply < ../v2r-buildroot-ext/add_br2_package_overlay_dir.patch
...
git checkout .
git pull origin master
git apply < ../v2r-buildroot-ext/add_br2_package_overlay_dir.patch
```

## make image

```
time make build
make img_install
make img_umount
```

