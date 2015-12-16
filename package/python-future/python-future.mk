################################################################################
#
# python-future
#
################################################################################

PYTHON_FUTURE_VERSION = 0.15.2
PYTHON_FUTURE_SOURCE = future-$(PYTHON_FUTURE_VERSION).tar.gz
PYTHON_FUTURE_SITE = http://pypi.python.org/packages/source/f/future
PYTHON_FUTURE_SETUP_TYPE = setuptools
PYTHON_FUTURE_LICENSE =MIT
PYTHON_FUTURE_LICENSE_FILES = LICENSE.txt

$(eval $(python-package))
