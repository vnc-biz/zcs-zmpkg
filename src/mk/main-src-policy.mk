
POLICY_DEPEND_RULES?=policy-dos2unix policy-java policy-xml

policy:	$(POLICY_DEPEND_RULES)

policy-dos2unix:
	@find -name "*.java"		\
	    -or -name "*.properties"	\
	    -or -name "*.xml" 		\
	    -or -name "Makefile"	\
	    -or -name "*.jsp"		\
	    -or -name "*.js"		\
	    -or -name "*.css"		\
	    -or -name "*.mk"		\
	    -or -name "README*"		\
	    -exec "dos2unix" "{}" ";"

policy-java:
	@find -name "*.java" \
	    | xargs astyle --style=java --indent=tab --suffix=none --indent-switches 2>&1 | grep -ve "^unchanged" || true

policy-xml:
	@find -name "*.xml" | ( \
	    while read fn ; do xmlindent -t -w "$$fn" ; rm -f "$$fn~" ; done )

policy-css:
	@find -name "*.css" | ( \
	    while read fn ; do 	csstidy "$$fn" "$$fn.tmp" --compress_colors=false --preserve_css=true --template=low && mv "$$fn.tmp" "$$fn" ; done )
