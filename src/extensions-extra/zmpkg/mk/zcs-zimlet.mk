
include $(TOPDIR)/common.mk

ifeq ($(ZCS_LIB_JARS),)
IMPORT_CP=`[ -d lib ] && find lib -name "*.jar" -exec "echo" "-n" "{}:" ";"`
else
IMPORT_ZCS=$(addprefix $(ZIMBRA_BUILD_ROOT)/lib/jars/,$(ZCS_LIB_JARS))
IMPORT_CP=`[ -d lib ] && find lib -name "*.jar" -exec "echo" "-n" "{}:" ";" ; find $(IMPORT_ZCS) -exec "echo" "-n" "{}:" ";"`
endif

ZIMBRA_BUILD_ROOT?=$(HOME)
ZIMLET_VERSION=$(CURRENT_VERSION).$(MICRO_REVISION)$(VERSION_SUFFIX)
ZIMLET_ZIP=$(INSTALL_DIR)/$(ZIMLET_NAME).zip

ZIMLET_PROCESS_FILES:=\
	$(ZIMLET_NAME).xml		\
	`cd src && find . -name "*.properties"`

ZIMLET_PROCESS_FILES_SRC=$(addprefix src/,$(ZIMLET_PROCESS_FILES))
ZIMLET_PROCESS_FILES_TMP=$(addprefix tmp/,$(ZIMLET_PROCESS_FILES))

ifneq ($(IMPORT_CP),)
JSP_CLASSPATH=`echo "$(JSP_BUILD_JARS)" | tr ' ' ':'`:$(IMPORT_CP) 
else
JSP_CLASSPATH=`echo "$(JSP_BUILD_JARS)" | tr ' ' ':'`
endif

all:	build

build:  check jsp $(ZIMLET_ZIP)

check:
	@if [ -d lib ]; then 							\
		RESULT=`find lib -name "*.jar" -type f` ;			\
		if [ "$$RESULT" ]; then						\
			echo ""	;						\
			echo "Forbidden binary jar files in zimlet:" ;		\
			echo "$$RESULT" ;					\
			echo ""	;						\
			exit 99 ;						\
		fi ;								\
	fi
	@( cd $(TOPDIR) ; $(ZIMBRA_BUILD_ROOT)/extensions-extra/zmpkg/tools/zm_check_source_tree )

clean:
	@rm -Rf $(ZIMLET_ZIP) tmp _jspc_tmp
	@rmdir `dirname "$(ZIMLET_ZIP)"` 2>/dev/null || true

$(ZIMLET_ZIP):	src/*
	@mkdir -p `dirname "$@"`
	@rm -Rf tmp
	@cp -R src tmp
	@for i in $(ZIMLET_PROCESS_FILES) ; do \
	    echo "processing: $$i"; \
	    cat src/$$i \
		| sed -e "s~@ZIMLET_NAME@~$(ZIMLET_NAME)~g" \
		| sed -e "s~@ZIMLET_VERSION@~$(ZIMLET_VERSION)~g" \
		> tmp/$$i ; \
	done
	@cd tmp; zip -r ../$(ZIMLET_ZIP) *; cd -
	@rm -Rf tmp
	@echo "$(ZIMLET_NAME).zip" >> $(TOPDIR)/zimlets.list

jsp:
	@for i in `find -name "*.jsp"` ; do JSP_CLASSPATH="$(JSP_CLASSPATH)" ZIMBRA_BUILD_ROOT="$(ZIMBRA_BUILD_ROOT)" $(COMPILE_JSP) $$i ; done

.PHONY:	all build jsp clean jsp
