use strict;
use warnings;
package Device::ADV7611;

use Moo;
extends 'Device::SMBus';

# We will define these two modules in the next steps 
use Device::ADV7611::IO;
use Device::ADV7611::HDMI;
 
has 'I2CBusDevicePath' => (
    is       => 'ro',
    required => 1,
);

# This attribute contains an object of Device::ADV7611::HDMI
has HDMI => (
    is => 'rw',
#    isa => 'Device::ADV7611::HDMI',
    lazy_build => 1,
    builder => '_build_HDMI';
);

# Lazy build function for building the HDMI attribute when used
sub _build_HDMI {
    my ($self) = @_;
    my $obj = Device::ADV7611::HDMI->new(
        I2CBusDevicePath => $self->I2CBusDevicePath
    );
    return $obj;
}
 
# This attribute contains an object of Device::ADV7611::IO
has IO => (
    is => 'rw',
#    isa => 'Device::ADV7611::IO',
    lazy_build => 1,
    builder => '_build_IO',
);

# Lazy build function for building the IO attribute when used
sub _build_IO {
    my ($self) = @_;
    my $obj = Device::ADV7611::IO->new(
        I2CBusDevicePath => $self->I2CBusDevicePath
    );
    return $obj;
}

1;
