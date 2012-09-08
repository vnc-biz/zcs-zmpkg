
UPLOAD_DEPEND_RULES?=upload-dpkg upload-skins

upload:		$(UPLOAD_DEPEND_RULES)

upload-check:
	@if [ ! "$(REDMINE_UPLOAD_USER)" ];     then echo "REDMINE_UPLOAD_USER environment variable must be set"     ; exit 1 ; fi
	@if [ ! "$(REDMINE_UPLOAD_PASSWORD)" ]; then echo "REDMINE_UPLOAD_PASSWORD environment variable must be set" ; exit 1 ; fi
	@if [ ! "$(REDMINE_UPLOAD_URL)" ];      then echo "REDMINE_UPLOAD_URL variable must be set"                  ; exit 1 ; fi
	@if [ ! "$(REDMINE_UPLOAD_PROJECT)" ];  then echo "REDMINE_UPLOAD_PROJECT variable must be set"              ; exit 1 ; fi

upload-dpkg:	all upload-check
	@zm_redmine_upload			\
		-f "$(DEBIAN_PACKAGE)"		\
		-l "$(REDMINE_UPLOAD_URL)"	\
		-u "$(REDMINE_UPLOAD_USER)"	\
		-w "$(REDMINE_UPLOAD_PASSWORD)"	\
		-p "$(REDMINE_UPLOAD_PROJECT)"	\
		-d "$(DEBIAN_PACKAGE)"

upload-skins:
	@for i in `find image/zimlets-install -name "*.zip" -wholename "*/skins/*"` ; do \
		zm_redmine_upload				\
			-f "$$i"				\
			-l "$(REDMINE_UPLOAD_URL)"		\
			-u "$(REDMINE_UPLOAD_USER)"		\
			-w "$(REDMINE_UPLOAD_PASSWORD)"		\
			-p "$(REDMINE_UPLOAD_PROJECT)"		\
			-d `basename "$$i"`		;	\
		done

.PHONY:	upload upload-dpkg
