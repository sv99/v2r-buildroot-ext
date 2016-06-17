################################################################################
#
# perl-device-i2c
#
################################################################################

PERL_DEVICE_I2C_VERSION = 0.06
PERL_DEVICE_I2C_SOURCE = Device-I2C-$(PERL_DEVICE_I2C_VERSION).tar.gz
PERL_DEVICE_I2C_SITE = $(BR2_CPAN_MIRROR)/authors/id/S/SV/SVOLKOV
PERL_DEVICE_I2C_LICENSE = Artistic or GPLv1+
PERL_DEVICE_I2C_LICENSE_FILES = LICENSE

$(eval $(perl-package))
