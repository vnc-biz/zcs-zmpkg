
include $(TOPDIR)/common.mk

JAR_LIBRARY_FILES=$(addprefix lib/,$(JAR_FILES))

all:	install

_check:
	@true
ifeq ($(JAR_FILES),)
	@echo "JAR_LIBRARY_FILES is not set. please check common.mk"
	@false
endif
ifeq ($(IMAGE_ROOT),)
	@echo "IMAGE_ROOT is not set. please check common.mk"
	@false
endif
ifeq ($(ZIMLET_USER_JARDIR),)
	@echo "ZIMLET_USER_JARDIR is not set. please check common.mk"
	@false
endif
ifeq ($(CONTAINER_ZIMLET_JARDIR),)
	@echo "CONTAINER_ZIMLET_JARDIR is not set. please check common.mk"
	@false
endif
ifeq ($(ZIMLET_ADMIN_JARDIR),)
	@echo "ZIMLET_ADMIN_JARDIR is not set. please check common.mk"
	@false
endif
ifeq ($(ZIMLET_SERVICE_JARDIR),)
	@echo "ZIMLET_SERVICE_JARDIR is not set. please check common.mk"
	@false
endif

install:	_check	$(JAR_LIBRARY_FILES)
	@true
ifeq ($(INSTALL_USER),y)
	@mkdir -p $(IMAGE_ROOT)/$(ZIMLET_USER_JARDIR)
	@cp $(JAR_LIBRARY_FILES) $(IMAGE_ROOT)/$(ZIMLET_USER_JARDIR)
endif
ifeq ($(INSTALL_ZIMLET),y)
	@mkdir -p $(IMAGE_ROOT)/$(CONTAINER_ZIMLET_JARDIR)
	@cp $(JAR_LIBRARY_FILES) $(IMAGE_ROOT)/$(CONTAINER_ZIMLET_JARDIR)
endif
ifeq ($(INSTALL_ADMIN),y)
	@mkdir -p $(IMAGE_ROOT)/$(ZIMLET_ADMIN_JARDIR)
	@cp $(JAR_LIBRARY_FILES) $(IMAGE_ROOT)/$(ZIMLET_ADMIN_JARDIR)
endif
ifeq ($(INSTALL_SERVICE),y)
	@mkdir -p $(IMAGE_ROOT)/$(ZIMLET_SERVICE_JARDIR)
	@cp $(JAR_LIBRARY_FILES) $(IMAGE_ROOT)/$(ZIMLET_SERVICE_JARDIR)
endif
ifeq ($(INSTALL_LIB),y)
	@mkdir -p $(IMAGE_ROOT)/$(ZIMLET_LIB_JARDIR)
	@cp $(JAR_LIBRARY_FILES) $(IMAGE_ROOT)/$(ZIMLET_LIB_JARDIR)
endif

clean:		_check
	@rm -Rf \
		$(addprefix $(IMAGE_ROOT)/$(ZIMLET_SERVICE_JARDIR)/,$(JAR_FILES))	\
		$(addprefix $(IMAGE_ROOT)/$(CONTAINER_ZIMLET_JARDIR)/,$(JAR_FILES))	\
		$(addprefix $(IMAGE_ROOT)/$(ZIMLET_ADMIN_JARDIR)/,$(JAR_FILES))		\
		$(addprefix $(IMAGE_ROOT)/$(ZIMLET_USER_JARDIR)/,$(JAR_FILES))		\
		$(addprefix $(IMAGE_ROOT)/$(ZIMLET_LIB_JARDIR)/,$(JAR_FILES))
