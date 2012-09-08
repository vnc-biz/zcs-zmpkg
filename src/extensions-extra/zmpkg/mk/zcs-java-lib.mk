
include $(TOPDIR)/common.mk

ifeq ($(ZCS_LIB_JARS),)
IMPORT_CP=`[ -d lib ] && find lib -name "*.jar" -exec "echo" "-n" "{}:" ";"`
else
IMPORT_ZCS=$(addprefix $(ZIMBRA_BUILD_ROOT)/lib/jars/,$(ZCS_LIB_JARS))
IMPORT_CP=`[ -d lib ] && find lib -name "*.jar" -exec "echo" "-n" "{}:" ";" ; find $(IMPORT_ZCS) -exec "echo" "-n" "{}:" ";"`
endif

SRCS=`find -L src -name "*.java"`

all:	check-1	build

build:	install

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

install:	$(JAR_FILE_NAME)
	@true
ifeq ($(INSTALL_USER),y)
	@mkdir -p $(IMAGE_ROOT)/$(ZIMLET_USER_JARDIR)
	@cp $(JAR_FILE_NAME) $(IMAGE_ROOT)/$(ZIMLET_USER_JARDIR)
endif
ifeq ($(INSTALL_ZIMLET),y)
	@mkdir -p $(IMAGE_ROOT)/$(CONTAINER_ZIMLET_JARDIR)
	@cp $(JAR_FILE_NAME) $(IMAGE_ROOT)/$(CONTAINER_ZIMLET_JARDIR)
endif
ifeq ($(INSTALL_ADMIN),y)
	@mkdir -p $(IMAGE_ROOT)/$(ZIMLET_ADMIN_JARDIR)
	@cp $(JAR_FILE_NAME) $(IMAGE_ROOT)/$(ZIMLET_ADMIN_JARDIR)
endif
ifeq ($(INSTALL_SERVICE),y)
	@mkdir -p $(IMAGE_ROOT)/$(ZIMLET_SERVICE_JARDIR)
	@cp $(JAR_FILE_NAME) $(IMAGE_ROOT)/$(ZIMLET_SERVICE_JARDIR)
endif
ifeq ($(INSTALL_LIB),y)
	@mkdir -p $(IMAGE_ROOT)/$(ZIMLET_LIB_JARDIR)
	@cp $(JAR_FILE_NAME) $(IMAGE_ROOT)/$(ZIMLET_LIB_JARDIR)
endif

clean:
	@rm -Rf \
		classes								\
		$(JAR_FILE_NAME)						\
		$(IMAGE_ROOT)/$(ZIMLET_SERVICE_JARDIR)/$(JAR_FILE_NAME)		\
		$(IMAGE_ROOT)/$(ZIMLET_ADMIN_JARDIR)/$(JAR_FILE_NAME)		\
		$(IMAGE_ROOT)/$(ZIMLET_USER_JARDIR)/$(JAR_FILE_NAME)		\
		$(IMAGE_ROOT)/$(ZIMLET_LIB_JARDIR)/$(JAR_FILE_NAME)		\
		$(IMAGE_ROOT)/$(CONTAINER_ZIMLET_JARDIR)/$(JAR_FILE_NAME)

build_classes:
	@mkdir -p classes
	@$(JAVAC) $(JAVAC_FLAGS) -d classes -cp "$(IMPORT_CP)" $(SRCS)

$(JAR_FILE_NAME):	build_classes $(JAR_FILE_PREPARE_RULE)
	@mkdir -p `dirname "$@"`
	@$(JAR) cvf $(JAR_FILE_NAME) -C classes .

.PHONY:	build_classes
