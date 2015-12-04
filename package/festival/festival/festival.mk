#############################################################
#
# festival
#
#############################################################
FESTIVAL_VERSION = 1.96-beta
FESTIVAL_SOURCE = festival-$(FESTIVAL_VERSION).tar.gz
FESTIVAL_SITE = http://festvox.org/packed/festival/1.96
FESTIVAL_AUTORECONF = NO
FESTIVAL_INSTALL_STAGING = NO
FESTIVAL_INSTALL_TARGET = YES
FESTIVAL_INSTALL_TARGET_OPTS = DESTDIR=$(TARGET_DIR) STRIP=$(TARGET_STRIP) install

FESTIVAL_CONF_OPTS = --prefix=/usr --libdir=/usr/share/festival/lib

FESTIVAL_MAKE_OPTS = CC="$(TARGET_CC)" CXX="$(TARGET_CXX)"

FESTIVAL_DEPENDENCIES = alsa-lib speech-tools

$(eval $(autotools-package))
#$(eval $(call AUTOTARGETS,package/multimedia/festival,festival))

