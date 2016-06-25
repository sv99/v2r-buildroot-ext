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
printf("tmds: 0x%02x\n", $dev->isTMDS());
printf("lock tmds: 0x%02x\n", $dev->isLockTMDS());
printf("signal: 0x%02x\n", $dev->isSignal());
printf("free run: 0x%02x\n", $dev->isFreeRun());
my $interlaced = $dev->isInterlaced();
printf("interlaced: 0x%02x\n", $interlaced);;
printf("de regen filter locked: 0x%02x\n", $dev->isDERegenFilterLocked());
printf("vert filter locked: 0x%02x\n", $dev->isVertFilterLocked());
print("\n");

if ($dev->isFiltersLocked()) {
    print_param "width", $dev->getWidth();
    print_param "height0", $dev->getHeight0();
    print_param "hfrontporch", $dev->getHFrontPorch();
    print_param "hsync", $dev->getHSync();
    print_param "hbackporch", $dev->getHBackPorch();
    print_param "vfrontporch0", $dev->getVFrontPorch0();
    print_param "vsync0", $dev->getVSync0();
    print_param "vbackporch0", $dev->getVBackPorch0();
    if ($interlaced) {
        print_param "height1", $dev->getHeight1();
        print_param "vfrontporch1", $dev->getVFrontPorch1();
        print_param "vsync1", $dev->getVSync1();
        print_param "vbackporch1", $dev->getVBackPorch1();
    }
    print("\n");

    printf("fps1000: %d\n", $dev->getFPS1000());
    printf("tmds freq: %f\n", $dev->getTMDSFreq());
}

$dev->close();
