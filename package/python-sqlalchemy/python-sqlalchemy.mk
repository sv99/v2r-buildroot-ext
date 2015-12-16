################################################################################
#
# python-sqlalchemy
#
################################################################################

PYTHON_SQLALCHEMY_VERSION = 1.0.10
PYTHON_SQLALCHEMY_SOURCE = sqlalchemy-$(PYTHON_FUTURES_VERSION).tar.gz
PYTHON_SQLALCHEMY_SITE = http://pypi.python.org/packages/source/s/sqlalchemy
PYTHON_SQLALCHEMY_SETUP_TYPE = setuptools
PYTHON_SQLALCHEMY_LICENSE = MIT
PYTHON_SQLALCHEMY_LICENSE_FILES = LICENSE.txt

$(eval $(python-package))
