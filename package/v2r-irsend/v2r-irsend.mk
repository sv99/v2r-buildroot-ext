#############################################################
#
# V2R send ir command with pulse data from command line
#
#############################################################
V2R_IRSEND_VERSION = HEAD
V2R_IRSEND_SITE = $(call github,sv99,v2r-irsend,$(V2R_IRSEND_VERSION))
V2R_IRSEND_INSTALL_TARGET = YES
# V2R_IRSEND_DEPENDENCIES = gstreamer gst-plugins-base gst-plugins-good

$(eval $(cmake-package))
