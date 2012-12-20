##
## user-frontend skin with direct filesystem deployment (w/o zip)
##

include $(TOPDIR)/common.mk

SKIN_VERSION=$(CURRENT_VERSION).$(MICRO_REVISION)$(VERSION_SUFFIX)
SKIN_DIR=$(IMAGE_ROOT)/mailboxd/webapps/zimbra/skins/$(SKIN_NAME)

all:	build

build:	tree

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
	@mkdir -p $(SKIN_DIR)
	@cp --preserve -R src/* $(SKIN_DIR)

clean:
	@rm -Rf $(SKIN_DIR) tmp
	@true

.PHONY:	all build _check tree clean
