################################################################################
#
# perl-data-dumper
#
################################################################################

PERL_DATA_DUMPER_VERSION = 2.154
PERL_DATA_DUMPER_SOURCE = Data-Dumper-$(PERL_DATA_DUMPER_VERSION).tar.gz
PERL_DATA_DUMPER_SITE = $(BR2_CPAN_MIRROR)/authors/id/S/SM/SMUELLER

$(eval $(perl-package))
