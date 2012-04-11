
TOPDIR=.
include $(TOPDIR)/conf.mk

DEBDIR=$(IMAGE_ROOT)/DEBIAN
DEBFILE=$(PACKAGE)_$(VERSION)_$(ARCHITECTURE).deb
DISTPREFIX=dist
DISTDIR=$(DISTPREFIX)/$(PACKAGE)-$(VERSION)
INSTALL_SCRIPT=$(DISTDIR)/install.sh

all:	build

build:	$(DEBFILE) $(INSTALL_SCRIPT)
	@mkdir -p $(DISTDIR)
	@cp $(DEBFILE) $(DISTDIR)
	@cp README $(DISTDIR)
	(cd $(DISTPREFIX) && tar -czf $(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)-$(VERSION))

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
