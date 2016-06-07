################################################################################
#
# perl-sub-exporter-progressive
#
################################################################################

PERL_SUB_EXPORTER_PROGRESSIVE_VERSION = 0.001011
PERL_SUB_EXPORTER_PROGRESSIVE_SOURCE = Sub-Exporter-Progressive-$(PERL_SUB_EXPORTER_PROGRESSIVE_VERSION).tar.gz
PERL_SUB_EXPORTER_PROGRESSIVE_SITE = $(BR2_CPAN_MIRROR)/authors/id/F/FR/FREW
PERL_SUB_EXPORTER_PROGRESSIVE_LICENSE = Artistic or GPLv1+
PERL_SUB_EXPORTER_PROGRESSIVE_LICENSE_FILES = README

$(eval $(perl-package))
