
UPLOAD_DEPEND_RULES?=upload-dpkg

upload:		$(UPLOAD_DEPEND_RULES)

upload-check:
	@if [ ! "$(ZMPKG_UPLOAD_COMMAND)" ]; then echo "ZMPKG_UPLOAD_COMMAND environment variable must be set" ; exit 1 ; fi

upload-dpkg:	all upload-check
	$(ZMPKG_UPLOAD_COMMAND) $(DEBIAN_PACKAGE)

.PHONY:	upload upload-dpkg upload-check
