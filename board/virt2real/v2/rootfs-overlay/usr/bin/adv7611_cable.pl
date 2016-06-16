#!/usr/bin/perl -w
use v5.10;
use Device::I2C::ADV7611;

my $dev = Device::I2C::ADV7611->new('/dev/i2c-1');

printf("Cable: 0x%02x\n", $dev->checkCable());

printf("File error: 0x%04x\n", $dev->fileError());

$dev->close();
