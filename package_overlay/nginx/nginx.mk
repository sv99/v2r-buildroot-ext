#############################################################
#
# nginx overlay add rtmp server
#
#############################################################

# NGINX_VERSION = 1.6.0

#echo "nginx overlay patch"

#ifeq ($(BR2_PACKAGE_NGINX_HTTP_RTMP),y)

define NGINX_POST_PATCH_FIXUP
	git clone https://github.com/arut/nginx-rtmp-module.git $(@D)/rtmp
endef

NGINX_POST_PATCH_HOOKS += NGINX_POST_PATCH_FIXUP
NGINX_CONF_OPTS += --add-module=$(@D)/rtmp
#endif

$(warning $(NGINX_POST_PATCH_HOOKS))
