################################################################################
#
# python-backports-abc
#
################################################################################

PYTHON_BACKPORTS_ABC_VERSION = 0.4
PYTHON_BACKPORTS_ABC_SOURCE = backports_abc-$(PYTHON_BACKPORTS_ABC_VERSION).tar.gz
PYTHON_BACKPORTS_ABC_SITE = http://pypi.python.org/packages/source/b/backports_abc
PYTHON_BACKPORTS_ABC_SETUP_TYPE = setuptools
PYTHON_BACKPORTS_ABC_LICENSE = BSD
PYTHON_BACKPORTS_ABC_LICENSE_FILES = LICENSE.txt

$(eval $(python-package))
