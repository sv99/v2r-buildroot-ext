#############################################################
#
# Gstreamer Pipeapp
#
#############################################################
GST_PIPEAPP_VERSION = HEAD
GST_PIPEAPP_SITE = $(call github,sv99,gst-pipeapp,$(GST_PIPEAPP_VERSION))
GST_PIPEAPP_INSTALL_TARGET = YES
GST_PIPEAPP_DEPENDENCIES = gstreamer gst-plugins-base gst-plugins-good

$(eval $(cmake-package))
