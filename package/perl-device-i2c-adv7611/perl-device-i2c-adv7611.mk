################################################################################
#
# perl-device-i2c-adv7611
#
################################################################################

PERL_DEVICE_I2C_ADV7611_VERSION = 0.11
PERL_DEVICE_I2C_ADV7611_SOURCE = Device-I2C-ADV7611-$(PERL_DEVICE_I2C_ADV7611_VERSION).tar.gz
PERL_DEVICE_I2C_ADV7611_SITE = $(BR2_CPAN_MIRROR)/authors/id/S/SV/SVOLKOV
PERL_DEVICE_I2C_ADV7611_DEPENDENCIES = perl-device-i2c
PERL_DEVICE_I2C_ADV7611_LICENSE = Artistic or GPLv1+
PERL_DEVICE_I2C_ADV7611_LICENSE_FILES = LICENSE

$(eval $(perl-package))
