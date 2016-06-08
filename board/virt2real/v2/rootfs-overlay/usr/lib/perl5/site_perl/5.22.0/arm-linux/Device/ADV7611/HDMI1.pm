use strict;
use warnings;
package Device::ADV7611::HDMI;

use POSIX;

use Moo;
extends 'Device::SMBus';

has '+I2CDeviceAddress' => (
    is      => 'ro',
    default => 0x34,
);

has 'gCorrectionFactor' => (
    is      => 'ro',
    default => 256
);

has 'gravitationalAcceleration' => (
    is      => 'ro',
    default => 9.8
);

has 'mssCorrectionFactor' => (
    is         => 'ro',
    lazy_build => 1,
);

sub _build_mssCorrectionFactor {
    my ($self) = @_;
    $self->gCorrectionFactor/$self->gravitationalAcceleration;
}

# Registers to read for the HDMI
use constant {
    CTRL_REG1_A => 0x20,
    CTRL_REG4_A => 0x23,
};
 
# X, Y and Z Axis magnetic Field Data value in 2's complement
use constant {
    OUT_X_H_A => 0x29,
    OUT_X_L_A => 0x28,

    OUT_Y_H_A => 0x2b,
    OUT_Y_L_A => 0x2a,

    OUT_Z_H_A => 0x2d,
    OUT_Z_L_A => 0x2c,
};

sub enable {
    my ($self) = @_;
    $self->writeByteData(CTRL_REG1_A,0b01000111);
    $self->writeByteData(CTRL_REG4_A,0b00101000);
}

sub getRawReading {
    my ($self) = @_;
 
    use integer; # Use arithmetic right shift instead of unsigned binary right shift with >> 4
    my $retval = {
        x => ( $self->_typecast_int_to_int16( ($self->readByteData(OUT_X_H_A) << 8) | $self->readByteData(OUT_X_L_A) ) ) >> 4,
        y => ( $self->_typecast_int_to_int16( ($self->readByteData(OUT_Y_H_A) << 8) | $self->readByteData(OUT_Y_L_A) ) ) >> 4,
        z => ( $self->_typecast_int_to_int16( ($self->readByteData(OUT_Z_H_A) << 8) | $self->readByteData(OUT_Z_L_A) ) ) >> 4,
    };
    no integer;
 
    return $retval;
}
 
sub getAccelerationVectorInG {
    my ($self) = @_;
 
    my $raw = $self->getRawReading;
    return {
        x => ($raw->{x})/$self->gCorrectionFactor,
        y => ($raw->{y})/$self->gCorrectionFactor,
        z => ($raw->{z})/$self->gCorrectionFactor,
    };
}
 
sub getAccelerationVectorInMSS {
    my ($self) = @_;
 
    my $raw = $self->getRawReading;
    return {
        x => ($raw->{x})/$self->mssCorrectionFactor,
        y => ($raw->{y})/$self->mssCorrectionFactor,
        z => ($raw->{z})/$self->mssCorrectionFactor,
    };
}

sub getAccelerationVectorAngles {
    my ($self) = @_;

    my $raw = $self->getRawReading;

    my $rawR = sqrt($raw->{x}**2+$raw->{y}**2+$raw->{z}**2); #Pythagoras theorem
    return {
        Axr => _acos($raw->{x}/$rawR),
        Ayr => _acos($raw->{y}/$rawR),
        Azr => _acos($raw->{z}/$rawR),
    };
}

sub getRollPitch {
    my ($self) = @_;

    my $raw = $self->getRawReading;

    return {
        Roll  => atan2($raw->{x},$raw->{z})+PI,
        Pitch => atan2($raw->{y},$raw->{z})+PI,
    };
}

sub _acos { 
    atan2( sqrt(1 - $_[0] * $_[0]), $_[0] ) 
}
sub _typecast_int_to_int16 {
    return  unpack 's' => pack 'S' => $_[1];
}

1;
