################################################################################
#
# perl-moo
#
################################################################################

PERL_MOO_VERSION = 2.001001
PERL_MOO_SOURCE = Device-SMBus-$(PERL_MOO_VERSION).tar.gz
PERL_MOO_SITE = $(BR2_CPAN_MIRROR)/authors/id/H/HA/HAARG
PERL_MOO_LICENSE = GPLv1
PERL_MOO_LICENSE_FILES = LICENSE

$(eval $(perl-package))
