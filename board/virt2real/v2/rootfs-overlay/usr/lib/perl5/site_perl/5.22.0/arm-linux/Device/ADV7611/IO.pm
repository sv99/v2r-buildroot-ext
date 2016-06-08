use strict;
use warnings;
package Device::ADV7611::IO;

use POSIX;

use Moo;
extends 'Device::SMBus';

has '+I2CDeviceAddress' => (
    is      => 'rw',
    default => 0x4c,
);

# Registers to read for the IO
use constant {
    CTRL_VID_STD => 0x0,
    CTRL_REG4_A => 0x23,
};

has 'videoStd' => (
    is         => 'ro',
    lazy_build => 1,
);

sub _build_videoStd {
    my ($self) = @_;
    $self->readByteData(CTRL_VID_STD);
}

sub readByte {
    my ($self) = @_;
    $self->readByteData($_[1]);
}

1;
