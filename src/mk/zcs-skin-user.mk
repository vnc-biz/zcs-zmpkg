
include $(TOPDIR)/common.mk

SKIN_VERSION=$(CURRENT_VERSION).$(MICRO_REVISION)$(VERSION_SUFFIX)
SKIN_ZIP=$(INSTALL_DIR)/skins/$(SKIN_NAME).zip

all:	build

build:	$(SKIN_ZIP)

_check:
	@true
ifeq ($(SKIN_NAME),)
	@echo "SKIN_NAME undefined." >&2
	@false
endif
ifeq ($(CURRENT_VERSION),)
	@echo "CURRENT_VERSION undefined." >&2
	@false
endif

tree:	_check
	@rm -Rf tmp
	@mkdir -p tmp/$(SKIN_NAME)
	@cp --preserve -R src/* tmp/$(SKIN_NAME)/

$(SKIN_ZIP):	tree
	@mkdir -p $(dir $(SKIN_ZIP)) 
	@cd tmp/ && zip -r $(abspath $(SKIN_ZIP)) *

clean:
	@rm -Rf $(SKIN_ZIP) $(SKIN_DIR) tmp
	@true

.PHONY:	all build _check tree $(SKIN_ZIP) clean
