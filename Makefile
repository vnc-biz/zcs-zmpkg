
TOPDIR=.
include $(TOPDIR)/common.mk

DEBDIR=$(IMAGE_ROOT)/DEBIAN
INSTALL_SCRIPT=$(DISTDIR)/install.sh

SCRIPT_FILES=\
	zmpkg			\
	zm_check_jsp		\
	zm_redmine_upload

all:	build

build:	$(DEBIAN_PACKAGE) $(INSTALL_SCRIPT)
	@mkdir -p $(DISTDIR)
	@cp $(DEBIAN_PACKAGE) $(DISTDIR)
	@mkdir -p $(IMAGE_ROOT)/zimlets-install
	@touch $(IMAGE_ROOT)/zimlets-install/.keep
	@cp README.quick README.textile $(DISTDIR)
	@(cd $(DISTPREFIX) && tar -cz $(PACKAGE)-$(VERSION)) > $(DISTFILE)

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
	@rm -Rf $(DISTPREFIX) $(IMAGE_ROOT) $(DEBFILE) *.deb

$(INSTALL_SCRIPT):	scripts/install.sh
	@mkdir -p $(DISTDIR)
	@cat $< | sed -e 's~@DEBFILE@~$(DEBFILE)~' > $@
	@chmod +x $@

$(DEBIAN_PACKAGE):	_image $(DEBDIR)/control
	@dpkg --build $(IMAGE_ROOT) .

$(DEBDIR)/control:	control.in
	@mkdir -p $(IMAGE_ROOT)/DEBIAN
	@cat $< | \
	    sed -e 's/@PACKAGE@/$(PACKAGE)/' | \
	    sed -e 's/@VERSION@/$(PACKAGING_VERSION)/' | \
	    sed -e 's/@MAINTAINER@/$(MAINTAINER)/' | \
	    sed -e 's/@SECTION@/$(SECTION)/' | \
	    sed -e 's/@ARCHITECTURE@/$(ARCHITECTURE)/' | \
	    sed -e 's/@PRIORITY@/$(PRIORITY)/' | \
	    sed -e 's/@DESCRIPTION@/$(DESCRIPTION)/' > $@

upload:	all
	@if [ ! "$(REDMINE_UPLOAD_USER)" ];     then echo "REDMINE_UPLOAD_USER environment variable must be set"     ; exit 1 ; fi
	@if [ ! "$(REDMINE_UPLOAD_PASSWORD)" ]; then echo "REDMINE_UPLOAD_PASSWORD environment variable must be set" ; exit 1 ; fi
	@if [ ! "$(REDMINE_UPLOAD_URL)" ];      then echo "REDMINE_UPLOAD_URL variable must be set"                  ; exit 1 ; fi
	@if [ ! "$(REDMINE_UPLOAD_PROJECT)" ];  then echo "REDMINE_UPLOAD_PROJECT variable must be set"              ; exit 1 ; fi
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
