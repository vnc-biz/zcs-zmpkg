
build-scripts:
	@if [ -f scripts/mailboxd-db-schema.sql ] ; then \
		mkdir -p $(INSTALL_DIR) && \
		cp scripts/mailboxd-db-schema.sql $(INSTALL_DIR) ; fi
	@if [ -f scripts/post-install.sh        ] ; then \
		mkdir -p $(INSTALL_DIR) && \
		cp scripts/post-install.sh $(INSTALL_DIR) && \
		chmod +x $(INSTALL_DIR)/post-install.sh ; fi

.PHONY:	build-scripts
