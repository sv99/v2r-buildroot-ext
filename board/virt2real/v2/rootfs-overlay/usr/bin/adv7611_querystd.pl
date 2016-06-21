#!/usr/bin/perl -w
use v5.10;
use Device::I2C::ADV7611;
use Carp;

my $dev = Device::I2C::ADV7611->new('/dev/i2c-1');

sub print_param {
    my ($name, $value) = @_;
    printf("%s: %d(0x%02x)\n", $name, $value, $value);
}

printf("no power: 0x%02x\n", $dev->noPower());
printf("hdmi: 0x%02x\n", $dev->isHDMI());
printf("lock STDI: 0x%02x\n", $dev->isLockSTDI());
printf("tdms: 0x%02x\n", $dev->isTMDS());
printf("lock tmds: 0x%02x\n", $dev->isLockTMDS());
printf("signal: 0x%02x\n", $dev->isSignal());
printf("no lock cp: 0x%02x\n", $dev->noLockCP());
printf("free run: 0x%02x\n", $dev->isFreeRun());

print_param "width", $dev->getWidth();
print_param "height", $dev->getHeight();
print_param "hfrontporch", $dev->getHFrontPorch();
print_param "hbackporch", $dev->getHBackPorch();
print_param "hsync", $dev->getHSync();
print_param "vfrontporch", $dev->getVFrontPorch();
print_param "vbackporch", $dev->getVBackPorch();
print_param "vsync", $dev->getVSync();

printf("fps1000: %d\n", $dev->getFPS1000());

$dev->close();
