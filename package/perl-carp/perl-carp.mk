################################################################################
#
# perl-carp
#
################################################################################

PERL_CARP_VERSION = 1.38
PERL_CARP_SOURCE = Carp-$(PERL_CARP_VERSION).tar.gz
PERL_CARP_SITE = $(BR2_CPAN_MIRROR)/authors/id/R/RJ/RJBS
PERL_CARP_LICENSE = Artistic or GPLv1+
PERL_CARP_LICENSE_FILES = README

$(eval $(perl-package))
