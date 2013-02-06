
INSTALLER_VERSION=1.4.0.3
INSTALLER_PACKAGE=zmpkg-installer-$(INSTALLER_VERSION)
INSTALLER_DIR=dist/$(INSTALLER_PACKAGE)
ZMPKG_HELIX_REF=refs/tags/zcs-zmpkg-1.2.9.2
ZMPKG_IRONMAIDEN_REF=refs/tags/zcs-zmpkg-1.3.0.9

ZMPKG_HELIX_DIST=$(INSTALLER_DIR)/zmpkg/helix
ZMPKG_IRONMAIDEN_DIST=$(INSTALLER_DIR)/zmpkg/ironmaiden

RPM_RHEL_64=$(INSTALLER_DIR)/binpkg/RHEL/x86_64
RPM_RHEL_32=$(INSTALLER_DIR)/binpkg/RHEL/i686

ZMPKG_REPO=.git

all:	tarball

tarball:	build-dist
	@( cd dist && tar -czf $(INSTALLER_PACKAGE).tar.gz $(INSTALLER_PACKAGE) )

build-dist:
# HELIX
	@rm -Rf build/helix $(ZMPKG_HELIX_DIST)
	@mkdir -p build/helix $(ZMPKG_HELIX_DIST)
	@git archive $(ZMPKG_HELIX_REF) --format=tar | ( cd build/helix && tar x)
	@( cd build/helix && make ZIMBRA_BASE=helix )
	@cp -R `find build/helix/dist/ -mindepth 1 -maxdepth 1 -type d` $(ZMPKG_HELIX_DIST)

# IRONMAIDEN
	@rm -Rf build/ironmaiden $(ZMPKG_IRONMAIDEN_DIST)
	@mkdir -p build/ironmaiden  $(ZMPKG_IRONMAIDEN_DIST)
	@git archive $(ZMPKG_IRONMAIDEN_REF) --format=tar | ( cd build/ironmaiden && tar x)
	@( cd build/ironmaiden && make ZIMBRA_BASE=ironmaiden )
	@cp -R `find build/ironmaiden/dist/ -mindepth 1 -maxdepth 1 -type d` $(ZMPKG_IRONMAIDEN_DIST)

# SuSE rpm's
	@mkdir -p $(INSTALLER_DIR)/binpkg/SLES/x86_64
	@cp binpkg/SLES/x86_64/*.rpm $(INSTALLER_DIR)/binpkg/SLES/x86_64

# RHEL rpm's
	@mkdir -p $(RPM_RHEL_64) $(RPM_RHEL_32)
	@cd $(RPM_RHEL_64) && wget "http://packages.vnc.biz/zmpkg/bootstrap/os-dist/rhel6/x86_64/dpkg-1.15.5.6-6.el6.x86_64.rpm"
	@cd $(RPM_RHEL_64) && wget "http://packages.vnc.biz/zmpkg/bootstrap/os-dist/rhel6/x86_64/apt-0.8.16.1-0.8.16.1.x86_64.rpm"
	@cd $(RPM_RHEL_32) && wget "http://dl.fedoraproject.org/pub/epel/6/i386/dpkg-1.15.5.6-6.el6.i686.rpm"

# installer script
	@cp scripts/install.sh $(INSTALLER_DIR)
	@chmod +x scripts/install.sh

clean:
	@rm -Rf dist build

.PHONY: all build-helix build-ironmaiden bundle clean
