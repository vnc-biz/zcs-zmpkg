
include $(TOPDIR)/common.mk

all:	build

build:	check build_ant install

ifeq ($(ZIMBRA_BUILD_ROOT),)
ZIMBRA_BUILD_ROOT=$(HOME)
check-1:
	@echo
	@echo "ZIMBRA_BUILD_ROOT is not set. assuming $$HOME"
	@echo
else
check-1:
	@true
endif

check:	check-1
ifeq ($(BUILD_ANT_SUBDIR),)
	@echo "missing BUILD_ANT_SUBDIR" >&2
	@exit 1
endif

install:
	@true
ifeq ($(INSTALL_USER),y)
	@mkdir -p $(IMAGE_ROOT)/$(ZIMLET_USER_JARDIR)
	@cp $(BUILD_ANT_JARFILE) $(IMAGE_ROOT)/$(ZIMLET_USER_JARDIR)
endif
ifeq ($(INSTALL_ZIMLET),y)
	@mkdir -p $(IMAGE_ROOT)/$(CONTAINER_ZIMLET_JARDIR)
	@cp $(BUILD_ANT_JARFILE) $(IMAGE_ROOT)/$(CONTAINER_ZIMLET_JARDIR)
endif
ifeq ($(INSTALL_ADMIN),y)
	@mkdir -p $(IMAGE_ROOT)/$(ZIMLET_ADMIN_JARDIR)
	@cp $(BUILD_ANT_JARFILE) $(IMAGE_ROOT)/$(ZIMLET_ADMIN_JARDIR)
endif
ifeq ($(INSTALL_SERVICE),y)
	@mkdir -p $(IMAGE_ROOT)/$(ZIMLET_SERVICE_JARDIR)
	@cp $(BUILD_ANT_JARFILE) $(IMAGE_ROOT)/$(ZIMLET_SERVICE_JARDIR)
endif
ifeq ($(INSTALL_LIB),y)
	@mkdir -p $(IMAGE_ROOT)/$(ZIMLET_LIB_JARDIR)
	@cp $(BUILD_ANT_JARFILE) $(IMAGE_ROOT)/$(ZIMLET_LIB_JARDIR)
endif

clean:
	@cd $(BUILD_ANT_SUBDIR) && $(ANT) clean
	@rm -Rf \
		classes		\
		$(IMAGE_ROOT)/$(ZIMLET_SERVICE_JARDIR)/$(BUILD_ANT_JARFILE)	\
		$(IMAGE_ROOT)/$(ZIMLET_ADMIN_JARDIR)/$(BUILD_ANT_JARFILE)	\
		$(IMAGE_ROOT)/$(ZIMLET_USER_JARDIR)/$(BUILD_ANT_JARFILE)	\
		$(IMAGE_ROOT)/$(ZIMLET_LIB_JARDIR)/$(BUILD_ANT_JARFILE)		\
		$(IMAGE_ROOT)/$(CONTAINER_ZIMLET_JARDIR)/$(BUILD_ANT_JARFILE)

build_ant:
	@cd $(BUILD_ANT_SUBDIR) && $(ANT) $(BUILD_ANT_TARGET)
