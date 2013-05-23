
TOPDIR=.
include $(TOPDIR)/common.mk

DEBDIR=$(IMAGE_ROOT)/DEBIAN
INSTALL_SCRIPT=$(DISTDIR)/install.sh

all:	build

build:	$(DEBIAN_PACKAGE) $(INSTALL_SCRIPT)
	@mkdir -p $(DISTDIR)
	@cp $(DEBIAN_PACKAGE) $(DISTDIR)
	@cp README.quick README.textile $(DISTDIR)
	@(cd $(DISTPREFIX) && tar -cz $(PACKAGE)-$(PACKAGING_VERSION)) > $(DISTFILE)

ifeq ($(ZIMBRA_ROOT),)
install:
	@echo "Please call me with 'make install ZIMBRA_ROOT=<zimbra installation prefix>'"
	@exit 1
else
install:	build
	@mkdir -p $(HOME)/bin
	@cp ./src/bin/* $(HOME)/bin
	@./src/bin/zmpkg install $(DEBIAN_PACKAGE)
	@./src/bin/zmpkg devel-init $(ZIMBRA_ROOT)
	@echo '== dont forget to add $(HOME)/bin into your $$PATH'
endif

build-scripts:
	@mkdir -p $(IMAGE_ROOT)
	@cp -R --preserve --no-dereference src/* $(IMAGE_ROOT)

clean:
	@rm -Rf $(DISTPREFIX) $(IMAGE_ROOT) $(DEBFILE) *.deb

$(INSTALL_SCRIPT):	scripts/install.sh
	@mkdir -p $(DISTDIR)
	@cat $< | sed -e 's~@DEBFILE@~$(DEBFILE)~' > $@
	@chmod +x $@

include $(TOPDIR)/src/extensions-extra/zmpkg/mk/main-dpkg.mk

upload:	all
	@if [ ! "$(ZMPKG_UPLOAD_COMMAND)" ]; then echo "ZMPKG_UPLOAD_COMMAND environment variable must be set" ; exit 1 ; fi
	@$(ZMPKG_UPLOAD_COMMAND) $(DEBIAN_PACKAGE)
	@$(ZMPKG_UPLOAD_COMMAND) $(DISTFILE)

build-scripts:

build-zimlets:

.PHONY:	build-scripts build-zimlets upload clean build all install
