#!/usr/bin/perl -w
use v5.10;
use Data::Dumper;

use Device::I2C::ADV7611;

my $dev = Device::I2C::ADV7611->new('/dev/i2c-1');

$dev->resetDevice();

$dev->checkDevice(Device::I2C::ADV7611->CTRL_IO);

$dev->writeIO(0x40, 0x81);
$dev->writeIO(0x01, 0x05); # TV Frameformat
$dev->writeIO(0x00, 0x19); # 720p with 2x1 decimation
$dev->writeIO(0x02, 0xf5); # YUV out
$dev->writeIO(0x03, 0x00);
$dev->writeIO(0x05, 0x2c);
$dev->writeIO(0x06, 0xa6); # Invert HS, VS pins

# Bring chip out of powerdown and disable tristate */
$dev->writeIO(0x0b, 0x44);
$dev->writeIO(0x0c, 0x42);
$dev->writeIO(0x14, 0x3f);
$dev->writeIO(0x15, 0xBE);

# LLC DLL enable */
$dev->writeIO(0x19, 0xC0);
$dev->writeIO(0x33, 0x40);

$dev->writeIO(0xfd, Device::I2C::ADV7611->CTRL_CP << 1);
$dev->writeIO(0xf9, Device::I2C::ADV7611->CTRL_KSV << 1);
$dev->writeIO(0xfb, Device::I2C::ADV7611->CTRL_HDMI << 1);
$dev->writeIO(0xfa, Device::I2C::ADV7611->CTRL_EDID << 1);

print "init OK\n";
