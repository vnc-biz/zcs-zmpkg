
BUILD_TARGETS+=build-src build-scripts

all:	check-depend dpkg

clean: $(CLEAN_TARGETS)
	@$(MAKE) $(CLEAN_TARGETS) clean_src
	@rm -Rf $(DISTPREFIX) $(IMAGE_ROOT) zimlets.list

clean_src:
	@$(MAKE) -C src clean

check-depend:
	@zmpkg check-installed "$(DEPENDS)"

install-depend:
	@zm-apt-get clean
	@zm-apt-get autoremove
	@zm-apt-get update
	@zm-apt-get upgrade
	@zm-apt-get install -y -f `echo "$(DEPENDS)" | sed -e 's~,~ ~'g`

build-src:
	@$(MAKE) -C src

include $(ZIMBRA_BUILD_ROOT)/extensions-extra/zmpkg/mk/main-scripts.mk
include $(ZIMBRA_BUILD_ROOT)/extensions-extra/zmpkg/mk/main-dpkg.mk
include $(ZIMBRA_BUILD_ROOT)/extensions-extra/zmpkg/mk/main-src-policy.mk
include $(ZIMBRA_BUILD_ROOT)/extensions-extra/zmpkg/mk/main-upload-dpkg.mk

dump:
	@echo "ALL_TARGETS=$(ALL_TARGETS)"
	@echo "PACKAGING_VERSION=$(PACKAGING_VERSION)"
