
TOPDIR=.
include $(TOPDIR)/common.mk

DEBDIR=$(IMAGE_ROOT)/DEBIAN
INSTALL_SCRIPT=$(DISTDIR)/install.sh

IMAGE_BIN=$(IMAGE_ROOT)/bin
IMAGE_MK=$(IMAGE_ROOT)/extensions-extra/zmpkg/mk
IMAGE_DOC=$(IMAGE_ROOT)/docs/zmpkg

CMD_FILES=\
	zmpkg			\
	zmpkg-devel-init	\
	zmpkg-autodeploy	\
	zm_check_jsp		\
	zm_redmine_upload

all:	build

build:	$(DEBIAN_PACKAGE) $(INSTALL_SCRIPT)
	@mkdir -p $(DISTDIR)
	@cp $(DEBIAN_PACKAGE) $(DISTDIR)
	@mkdir -p $(IMAGE_ROOT)/zimlets-install
	@touch $(IMAGE_ROOT)/zimlets-install/.keep
	@cp README.quick README.textile $(DISTDIR)
	@(cd $(DISTPREFIX) && tar -cz $(PACKAGE)-$(PACKAGING_VERSION)) > $(DISTFILE)

ifeq ($(ZIMBRA_ROOT),)
install:
	@echo "Please call me with 'make install ZIMBRA_ROOT=<zimbra installation prefix>'"
	@exit 1
else
install:	build
	@./src/cmd/zmpkg install $(DEBIAN_PACKAGE)
	@./src/cmd/zmpkg devel-init $(ZIMBRA_ROOT)
	@echo '== dont forget to add $(HOME)/bin into your $$PATH'
endif

_image:	$(DEBDIR)/control
	@mkdir -p $(IMAGE_BIN) $(IMAGE_MK) $(IMAGE_DOC)
	@for i in $(CMD_FILES) ; do cp src/cmd/$$i $(IMAGE_BIN) ; chmod +x $(IMAGE_BIN)/$$i ; done
	@for i in `find src/mk -name "*.mk"` ; do cp $$i $(IMAGE_MK) ; done
	@for i in `find src/doc -type f` ; do cp $$i $(IMAGE_DOC) ; done

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
ifeq ($(DEPENDS),)
	@cat $< | \
	    sed -e 's/@PACKAGE@/$(PACKAGE)/' | \
	    sed -e 's/@VERSION@/$(PACKAGING_VERSION)/' | \
	    sed -e 's/@MAINTAINER@/$(MAINTAINER)/' | \
	    sed -e 's/@SECTION@/$(SECTION)/' | \
	    sed -e 's/@ARCHITECTURE@/$(ARCHITECTURE)/' | \
	    sed -e 's/@PRIORITY@/$(PRIORITY)/' | \
	    sed -e 's/@DEPENDS@/$(DEPENDS)/' | \
	    sed -e 's/@DESCRIPTION@/$(DESCRIPTION)/' | \
	    grep -ve "^Depends: " > $@
else
	@cat $< | \
	    sed -e 's/@PACKAGE@/$(PACKAGE)/' | \
	    sed -e 's/@VERSION@/$(PACKAGING_VERSION)/' | \
	    sed -e 's/@MAINTAINER@/$(MAINTAINER)/' | \
	    sed -e 's/@SECTION@/$(SECTION)/' | \
	    sed -e 's/@ARCHITECTURE@/$(ARCHITECTURE)/' | \
	    sed -e 's/@PRIORITY@/$(PRIORITY)/' | \
	    sed -e 's/@DEPENDS@/$(DEPENDS)/' | \
	    sed -e 's/@DESCRIPTION@/$(DESCRIPTION)/' > $@
endif

upload:	all
	@if [ ! "$(REDMINE_UPLOAD_USER)" ];     then echo "REDMINE_UPLOAD_USER environment variable must be set"     ; exit 1 ; fi
	@if [ ! "$(REDMINE_UPLOAD_PASSWORD)" ]; then echo "REDMINE_UPLOAD_PASSWORD environment variable must be set" ; exit 1 ; fi
	@if [ ! "$(REDMINE_UPLOAD_URL)" ];      then echo "REDMINE_UPLOAD_URL variable must be set"                  ; exit 1 ; fi
	@if [ ! "$(REDMINE_UPLOAD_PROJECT)" ];  then echo "REDMINE_UPLOAD_PROJECT variable must be set"              ; exit 1 ; fi
	@./src/cmd/zm_redmine_upload		\
		-f "$(DEBIAN_PACKAGE)"		\
		-l "$(REDMINE_UPLOAD_URL)"	\
		-u "$(REDMINE_UPLOAD_USER)"	\
		-w "$(REDMINE_UPLOAD_PASSWORD)"	\
		-p "$(REDMINE_UPLOAD_PROJECT)"	\
		-d `basename "$(DEBIAN_PACKAGE)"`
	@./src/cmd/zm_redmine_upload		\
		-f "$(DISTFILE)"		\
		-l "$(REDMINE_UPLOAD_URL)"	\
		-u "$(REDMINE_UPLOAD_USER)"	\
		-w "$(REDMINE_UPLOAD_PASSWORD)"	\
		-p "$(REDMINE_UPLOAD_PROJECT)"	\
		-d `basename "$(DISTFILE)"`
