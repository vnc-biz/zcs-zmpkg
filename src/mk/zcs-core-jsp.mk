
include $(TOPDIR)/common.mk

JSP_CLASSPATH=`echo "$(JSP_BUILD_JARS)" | tr ' ' ':'`

all:	build

build:  jsp
	@cp -R src/mailboxd $(IMAGE_ROOT)

clean:
	@( cd src && find -not -type d ) | ( while read f ; do rm -f $(IMAGE_ROOT)/$$f ; done )
	@( cd src && find -type d ) | sort -r | ( while read f ; do rmdir $(IMAGE_ROOT)/$$f 2>/dev/null || true ; done )

jsp:
	@for i in `find -name "*.jsp"` ; do JSP_CLASSPATH="$(JSP_CLASSPATH)" ZIMBRA_BUILD_ROOT="$(ZIMBRA_BUILD_ROOT)" $(COMPILE_JSP) $$i ; done
