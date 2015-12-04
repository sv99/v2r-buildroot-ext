#############################################################
#
# LIBGPHOTO2
#
#############################################################

LIBGPHOTO2_VERSION = 2.5.7
LIBGPHOTO2_SOURCE = libgphoto2-$(LIBGPHOTO2_VERSION).tar.gz
LIBGPHOTO2_SITE = http://optimate.dl.sourceforge.net/project/gphoto/libgphoto/$(LIBGPHOTO2_VERSION)
LIBGPHOTO2_INSTALL_STAGING = YES
LIBGPHOTO2_INSTALL_TARGET = YES
LIBGPHOTO2_CONF_OPTS = --enable-static
LIBGPHOTO2_DEPENDENCIES = libusb-compat libtool libxml2


$(eval $(autotools-package))
