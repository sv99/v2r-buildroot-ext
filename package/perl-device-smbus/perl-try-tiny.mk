################################################################################
#
# perl-device-smbus
#
################################################################################

PERL_DEVICE_SMBUS_VERSION = 1.15
PERL_DEVICE_SMBUS_SOURCE = Device-SMBus-$(PERL_DEVICE_SMBUS_VERSION).tar.gz
PERL_DEVICE_SMBUS_SITE = $(BR2_CPAN_MIRROR)/authors/id//S/SH/SHANTANU
PERL_DEVICE_SMBUS_LICENSE = GPLv1
PERL_DEVICE_SMBUS_LICENSE_FILES = LICENSE

$(eval $(perl-package))
