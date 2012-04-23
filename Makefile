
TOPDIR=.
include $(TOPDIR)/conf.mk

DEBDIR=$(IMAGE_ROOT)/DEBIAN
DEBFILE=$(PACKAGE)_$(VERSION)_$(ARCHITECTURE).deb
INSTALL_SCRIPT=$(DISTDIR)/install.sh

SCRIPT_FILES=\
	zmpkg			\
	zm_check_jsp		\
	zm_redmine_upload

all:	build

build:	$(DEBFILE) $(INSTALL_SCRIPT)
	@mkdir -p $(DISTDIR)
	@cp $(DEBFILE) $(DISTDIR)
	@cp README.quick README.textile $(DISTDIR)
	@(cd $(DISTPREFIX) && tar -czf $(DISTFILENAME) $(PACKAGE)-$(VERSION))

ifeq ($(ZIMBRA_ROOT),)
install:
	@echo "Please call me with 'make install ZIMBRA_ROOT=<zimbra installation prefix>'"
	@exit 1
else
install:	build
	@./src/zmpkg install $(DEBFILE)
	@./src/zmpkg devel-init $(ZIMBRA_ROOT)
	@echo '== dont forget to add $(HOME)/bin into your $$PATH'
endif

_image:	$(DEBDIR)/control
	@mkdir -p image/bin
	@for i in $(SCRIPT_FILES) ; do cp src/$$i image/bin ; chmod +x image/bin/$$i ; done

clean:
	@rm -Rf $(DISTPREFIX) $(IMAGE_ROOT) $(DEBFILE)

$(INSTALL_SCRIPT):	scripts/install.sh
	@mkdir -p $(DISTDIR)
	@cat $< | sed -e 's~@DEBFILE@~$(DEBFILE)~' > $@
	@chmod +x $@

$(DEBFILE):	_image
	@dpkg --build $(IMAGE_ROOT) .

$(DEBDIR)/control:	control.in
	@mkdir -p $(IMAGE_ROOT)/DEBIAN
	@cat $< | \
	    sed -E 's/@PACKAGE@/$(PACKAGE)/' | \
	    sed -E 's/@VERSION@/$(VERSION)/' | \
	    sed -E 's/@MAINTAINER@/$(MAINTAINER)/' | \
	    sed -E 's/@SECTION@/$(SECTION)/' | \
	    sed -E 's/@ARCHITECTURE@/$(ARCHITECTURE)/' | \
	    sed -E 's/@PRIORITY@/$(PRIORITY)/' | \
	    sed -E 's/@DESCRIPTION@/$(DESCRIPTION)/' > $@

upload:	all
	@if [ ! "$(REDMINE_UPLOAD_USER)" ]; then echo "REDMINE_UPLOAD_USER environment variable must be set" ; exit 1 ; fi
	@if [ ! "$(REDMINE_UPLOAD_PASSWORD)" ]; then echo "REDMINE_UPLOAD_PASSWORD environment variable must be set" ; exit 1 ; fi
	@if [ ! "$(REDMINE_UPLOAD_URL)" ]; then echo "REDMINE_UPLOAD_URL variable must be set" ; exit 1 ; fi
	@if [ ! "$(REDMINE_UPLOAD_PROJECT)" ]; then echo "REDMINE_UPLOAD_PROJECT variable must be set" ; exit 1 ; fi
	@./src/zm_redmine_upload		\
		-f $(DEBFILE)			\
		-l $(REDMINE_UPLOAD_URL)	\
		-u $(REDMINE_UPLOAD_USER)	\
		-w $(REDMINE_UPLOAD_PASSWORD)	\
		-p $(REDMINE_UPLOAD_PROJECT)	\
		-d "$(DEBFILE)"
	@./src/zm_redmine_upload		\
		-f $(DISTFILE)			\
		-l $(REDMINE_UPLOAD_URL)	\
		-u $(REDMINE_UPLOAD_USER)	\
		-w $(REDMINE_UPLOAD_PASSWORD)	\
		-p $(REDMINE_UPLOAD_PROJECT)	\
		-d "$(DISTFILENAME)"
