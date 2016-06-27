################################################################################
#
# node-gstreamer010-superficial
#
################################################################################

NODE_GSTREAMER010_SUPERFICIAL_VERSION = v0.0.1
NODE_GSTREAMER010_SUPERFICIAL_SITE =  $(call github,sv99,node-gstreamer010-superficial,$(NODE_GSTREAMER010_SUPERFICIAL_VERSION))
NODE_GSTREAMER010_SUPERFICIAL_LICENSE = GPLv3
NODE_GSTREAMER010_SUPERFICIAL_LICENSE_FILES = README.md
NODE_GSTREAMER010_SUPERFICIAL_DEPENDENCIES = nodejs gstreamer

define NODE_GSTREAMER010_SUPERFICIAL_INSTALL_TARGET_CMDS
	$(NPM) install -g $(@D)
endef

$(eval $(generic-package))
