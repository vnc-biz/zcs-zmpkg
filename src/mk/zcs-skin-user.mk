
include $(TOPDIR)/common.mk

SKIN_VERSION=$(CURRENT_VERSION).$(MICRO_REVISION)$(VERSION_SUFFIX)
SKIN_ZIP=$(INSTALL_DIR)/skins/$(SKIN_NAME).zip

all:	build

build:	$(SKIN_ZIP)

## zipfile for old-style deployment
$(SKIN_ZIP):
	@mkdir -p $(dir $(SKIN_ZIP))
	@cd src/ && zip -r $(abspath $(SKIN_ZIP)) *

clean:
	@rm -Rf $(SKIN_ZIP) $(SKIN_DIR)
	@true
