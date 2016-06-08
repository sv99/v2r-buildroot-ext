#!/usr/bin/perl -w
use FindBin qw($Bin);
use lib "$Bin/../lib";
use v5.10;
use Data::Dumper;

use Device::ADV7611;

my $a = Device::ADV7611->new(I2CBusDevicePath => '/dev/i2c-1');

say Dumper $a;

print "Video_std: ". sprintf("0x%X", $a->IO->readByteData(0)) . "\n";
print "Video_std: ". sprintf("0x%X", $a->IO->readByteData(1)) . "\n";

say Dumper $a;
