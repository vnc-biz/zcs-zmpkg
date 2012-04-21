
TOPDIR=.
include $(TOPDIR)/conf.mk

DEBDIR=$(IMAGE_ROOT)/DEBIAN
DEBFILE=$(PACKAGE)_$(VERSION)_$(ARCHITECTURE).deb
INSTALL_SCRIPT=$(DISTDIR)/install.sh

all:	build

build:	$(DEBFILE) $(INSTALL_SCRIPT)
	@mkdir -p $(DISTDIR)
	@cp $(DEBFILE) $(DISTDIR)
	@cp README $(DISTDIR)
	@(cd $(DISTPREFIX) && tar -czf $(DISTFILENAME) $(PACKAGE)-$(VERSION))

_image:	$(DEBDIR)/control
	@mkdir -p image/bin
	@cp src/zmpkg image/bin
	@chmod +x image/bin/zmpkg

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
	@upload_file_to_redmine.py		\
		-f $(DEBFILE)			\
		-l $(REDMINE_UPLOAD_URL)	\
		-u $(REDMINE_UPLOAD_USER)	\
		-w $(REDMINE_UPLOAD_PASSWORD)	\
		-p $(REDMINE_UPLOAD_PROJECT)	\
		-d "$(DEBFILE)"
	@upload_file_to_redmine.py		\
		-f $(DISTFILE)			\
		-l $(REDMINE_UPLOAD_URL)	\
		-u $(REDMINE_UPLOAD_USER)	\
		-w $(REDMINE_UPLOAD_PASSWORD)	\
		-p $(REDMINE_UPLOAD_PROJECT)	\
		-d "$(DISTFILENAME)"
