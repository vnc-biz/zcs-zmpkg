
ifeq ($(BUILD_TARGETS),)
BUILD_TARGETS=build-scripts build-zimlets
endif

CLEAN_TARGETS+=clean_dpkg

$(DEBIAN_PACKAGE)::	$(DEBIAN_DIR)/control $(BUILD_TARGETS)
	@dpkg --build $(IMAGE_ROOT) .

$(DEBIAN_DIR)/control:	control.in
	@mkdir -p $(IMAGE_ROOT)/DEBIAN
ifeq ($(ZIMBRA_BASE),)
	@echo "Missing environment variable ZIMBRA_BASE"
	exit 1
endif
ifeq ($(DEPENDS),)
	@cat $< | \
	    sed -e 's~@PACKAGE@~$(PACKAGE)~'		| \
	    sed -e 's~@VERSION@~$(PACKAGING_VERSION)~'	| \
	    sed -e 's~@MAINTAINER@~$(MAINTAINER)~'	| \
	    sed -e 's~@SECTION@~$(SECTION)~'		| \
	    sed -e 's~@ARCHITECTURE@~$(ARCHITECTURE)~'	| \
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
	    sed -e 's~@ARCHITECTURE@~$(ARCHITECTURE)~'	| \
	    sed -e 's~@PRIORITY@~$(PRIORITY)~'		| \
	    sed -e 's~@DEPENDS@~$(DEPENDS)~'		| \
	    sed -e 's~@DESCRIPTION@~$(DESCRIPTION)~' > $@
endif

clean_dpkg:
	@rm -Rf $(DEBIAN_FILE) $(DEBIAN_DIR) *.deb

dpkg:	$(DEBIAN_PACKAGE)

.PHONY:	$(DEBIAN_DIR)/control dpkg
