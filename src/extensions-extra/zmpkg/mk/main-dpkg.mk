
ifeq ($(BUILD_TARGETS),)
BUILD_TARGETS=build-scripts build-zimlets
endif

CLEAN_TARGETS+=clean_dpkg

BUILDINFO=$(IMAGE_ROOT)/extensions-extra/packages/$(PACKAGE)/buildinfo
CURRENT_COMMIT:=`git show-ref HEAD | sed -e 's~ .*~~'`

$(DEBIAN_PACKAGE)::	$(DEBIAN_DIR)/control $(BUILD_TARGETS) $(BUILDINFO)
	@dpkg --build $(IMAGE_ROOT) .

$(DEBIAN_DIR)/control:	control.in $(BUILDINFO)
	@mkdir -p $(IMAGE_ROOT)/DEBIAN
ifeq ($(ZIMBRA_BASE),)
	@echo "Missing environment variable ZIMBRA_BASE"
	@exit 1
endif
ifneq ($(FORCE_ZIMBRA_BASE),)
ifneq ($(FORCE_ZIMBRA_BASE),$(ZIMBRA_BASE))
	@echo "Wrong build environment $(ZIMBRA_BASE) (needs $(FORCE_ZIMBRA_BASE))"
	@exit 1
endif
endif
ifeq ($(DEPENDS),)
	@cat $< | \
	    sed -e 's~@PACKAGE@~$(PACKAGE)~'		| \
	    sed -e 's~@VERSION@~$(PACKAGING_VERSION)~'	| \
	    sed -e 's~@MAINTAINER@~$(MAINTAINER)~'	| \
	    sed -e 's~@SECTION@~$(SECTION)~'		| \
	    sed -e 's~@ARCHITECTURE@~$(DPKG_ARCHITECTURE)~'	| \
	    sed -e 's~@PRIORITY@~$(PRIORITY)~'		| \
	    sed -e 's~@DEPENDS@~$(DEPENDS)~'		| \
	    sed -e 's~@DESCRIPTION@~$(DESCRIPTION)~'	| \
	    grep -ve "^Depends: " > $@
else
	@cat $< | \
	    sed -e 's~@PACKAGE@~$(PACKAGE)~'		| \
	    sed -e 's~@VERSION@~$(PACKAGING_VERSION)~'	| \
	    sed -e 's~@MAINTAINER@~$(MAINTAINER)~'	| \
	    sed -e 's~@SECTION@~$(SECTION)~'		| \
	    sed -e 's~@ARCHITECTURE@~$(DPKG_ARCHITECTURE)~'	| \
	    sed -e 's~@PRIORITY@~$(PRIORITY)~'		| \
	    sed -e 's~@DEPENDS@~$(DEPENDS)~'		| \
	    sed -e 's~@DESCRIPTION@~$(DESCRIPTION)~' > $@
endif

clean_dpkg:
	@rm -Rf $(DEBIAN_FILE) $(DEBIAN_DIR) *.deb $(BUILDINFO)

$(BUILDINFO):
	@mkdir -p `dirname "$(BUILDINFO)"`
	@( \
		echo -n "Revision: "			; \
		echo "$(CURRENT_COMMIT)"		; \
		echo -n "Build-Date: "			; \
		date					; \
		echo "Build-User: "`whoami`@`hostname`	; \
		echo					; \
		zmpkg list | tail -n +6			; \
		git diff				; \
	) > $(BUILDINFO)

dpkg:	$(DEBIAN_PACKAGE)

.PHONY:	$(DEBIAN_DIR)/control dpkg buildinfo
