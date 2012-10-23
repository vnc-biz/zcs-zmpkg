
include $(TOPDIR)/common.mk

JSP_CLASSPATH=`echo "$(JSP_BUILD_JARS)" | tr ' ' ':'`

all:	build

check:
	@cd $(TOPDIR) && ZMPKG_BUILD_POLICY="$(ZMPKG_BUILD_POLICY)" $(ZIMBRA_BUILD_ROOT)/extensions-extra/zmpkg/tools/zm_check_source_tree

build:  check jsp
	@cp -R src/mailboxd $(IMAGE_ROOT)
	for i in `find $(IMAGE_ROOT)/mailboxd/webapps -name "*.js"` ; do \
	    cat "$$i" | gzip -9 > "$$i.zgz" ; \
	done

clean:
	@( cd src && find -not -type d ) | ( while read f ; do rm -f $(IMAGE_ROOT)/$$f ; done )
	@( cd src && find -type d ) | sort -r | ( while read f ; do rmdir $(IMAGE_ROOT)/$$f 2>/dev/null || true ; done )

jsp:
ifneq ($(SKIP_JSP_COMPILE),y)
	@for i in `find -name "*.jsp"` ; do JSP_CLASSPATH="$(JSP_CLASSPATH)" ZIMBRA_BUILD_ROOT="$(ZIMBRA_BUILD_ROOT)" $(COMPILE_JSP) $$i ; done
endif

.PHONY:	all build jsp clean
