################################################################################
#
# python-futures
#
################################################################################

PYTHON_FUTURES_VERSION = 3.0.3
PYTHON_FUTURES_SOURCE = futures-$(PYTHON_FUTURES_VERSION).tar.gz
PYTHON_FUTURES_SITE = http://pypi.python.org/packages/source/f/futures
PYTHON_FUTURES_SETUP_TYPE = setuptools
PYTHON_FUTURES_LICENSE = BSD
PYTHON_FUTURES_LICENSE_FILES = LICENSE.txt

$(eval $(python-package))
