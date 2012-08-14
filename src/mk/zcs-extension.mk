
include $(TOPDIR)/common.mk

ifeq ($(ZCS_LIB_JARS),)
IMPORT_CP=`[ -d lib ] && find lib -name "*.jar" -exec "echo" "-n" "{}:" ";"`
else
IMPORT_ZCS=$(addprefix $(ZIMBRA_BUILD_ROOT)/lib/jars/,$(ZCS_LIB_JARS))
IMPORT_CP=`[ -d lib ] && find lib -name "*.jar" -exec "echo" "-n" "{}:" ";" ; find $(IMPORT_ZCS) -exec "echo" "-n" "{}:" ";"`
endif

EXTENSION_JAR?=$(IMAGE_ROOT)/lib/ext/$(EXTENSION_NAME)/$(EXTENSION_NAME).jar

SRCS=`find -L src -name "*.java"`

all:	check-1	check-2	build

build:	$(EXTENSION_JAR)
	echo "build done: $(EXTENSION_JAR)"

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

ifeq ($(EXTENSION_NAME),)
check-2:
	@echo
	@echo "EXTENSION_NAME is not set"
	@echo
	@false
else
check-2:
	@true
endif

clean:
	@rm -Rf classes $(EXTENSION_JAR)

build_classes:
	@mkdir -p classes
	@$(JAVAC) $(JAVAC_FLAGS) -d classes -cp "$(IMPORT_CP)" $(SRCS)

$(EXTENSION_JAR):	build_classes $(JAR_FILE_PREPARE_RULE)
	@mkdir -p `dirname "$@"`
	@cp src/MANIFEST.MF classes
	@$(JAR) cvf $(EXTENSION_JAR) -C classes .

.PHONY:	build_classes
