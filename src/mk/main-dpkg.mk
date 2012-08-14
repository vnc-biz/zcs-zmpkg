
$(DEBIAN_PACKAGE)::	$(DEBIAN_DIR)/control build-scripts build-zimlets
	@dpkg --build $(IMAGE_ROOT) .

$(DEBIAN_DIR)/control:	control.in
	@mkdir -p $(IMAGE_ROOT)/DEBIAN
ifeq ($(DEPENDS),)
	@cat $< | \
	    sed -e 's/@PACKAGE@/$(PACKAGE)/' | \
	    sed -e 's/@VERSION@/$(PACKAGING_VERSION)/' | \
	    sed -e 's/@MAINTAINER@/$(MAINTAINER)/' | \
	    sed -e 's/@SECTION@/$(SECTION)/' | \
	    sed -e 's/@ARCHITECTURE@/$(ARCHITECTURE)/' | \
	    sed -e 's/@PRIORITY@/$(PRIORITY)/' | \
	    sed -e 's/@DEPENDS@/$(DEPENDS)/' | \
	    sed -e 's/@DESCRIPTION@/$(DESCRIPTION)/' | \
	    grep -ve "^Depends: " > $@
else
	@cat $< | \
	    sed -e 's/@PACKAGE@/$(PACKAGE)/' | \
	    sed -e 's/@VERSION@/$(PACKAGING_VERSION)/' | \
	    sed -e 's/@MAINTAINER@/$(MAINTAINER)/' | \
	    sed -e 's/@SECTION@/$(SECTION)/' | \
	    sed -e 's/@ARCHITECTURE@/$(ARCHITECTURE)/' | \
	    sed -e 's/@PRIORITY@/$(PRIORITY)/' | \
	    sed -e 's/@DEPENDS@/$(DEPENDS)/' | \
	    sed -e 's/@DESCRIPTION@/$(DESCRIPTION)/' > $@
endif

.PHONY:	$(DEBIAN_DIR)/control
