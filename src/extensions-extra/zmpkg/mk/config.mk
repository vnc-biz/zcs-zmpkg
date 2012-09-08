
## common configuration variables ##
## NOTE: do NOT add any rules here, or builds will fail ##

CURRENT_VERSION?=$(VERSION)
CURRENT_VERSION_TAG?=$(PACKAGE)-$(CURRENT_VERSION)
LAST_VERSION?=$(VERSION)
LAST_VERSION_TAG?=$(PACKAGE)-$(LAST_VERSION)

ZIMBRA_USER?=zimbra
ZIMBRA_GROUP?=zimbra

## external commands
GIT?=git
JAVA?=java
JAVAC?=javac
JAVAC_FLAGS?=-Xlint:unchecked -target 1.6 -source 1.6
JAR?=jar
ANT?=ant
COMPILE_JSP?=zm_check_jsp

## for automatic versioning by commit since last tag
MICRO_REVISION:=$(shell $(GIT) log --pretty=short $(LAST_VERSION_TAG)..HEAD | grep commit | wc -l)

PACKAGING_VERSION?=$(CURRENT_VERSION)-$(MICRO_REVISION)

## where the installation image goes to (before running dpkg)
IMAGE_ROOT?=$(TOPDIR)/image

## where the zcs deployment files (zimlet zips, etc) are put, so zmpkg postinst finds them
INSTALL_DIR?=$(IMAGE_ROOT)/zimlets-install/$(PACKAGE)

## prefix for the distribution tarball building
DISTPREFIX?=$(TOPDIR)/dist

## directory that will be compressed into the dist tarball
DISTDIR?=$(DISTPREFIX)/$(PACKAGE)-$(VERSION)

## standard locations within ZCS installation tree
CONTAINER_ZIMLET_JARDIR?=mailboxd/webapps/zimlet/WEB-INF/lib
ZIMLET_USER_JARDIR?=mailboxd/webapps/zimbra/WEB-INF/lib
ZIMLET_ADMIN_JARDIR?=mailboxd/webapps/zimbraAdmin/WEB-INF/lib
ZIMLET_SERVICE_JARDIR?=mailboxd/webapps/service/WEB-INF/lib
ZIMLET_LIB_JARDIR?=lib/jars

## subdirectory for debian control files
DEBIAN_DIR?=$(IMAGE_ROOT)/DEBIAN

## debian package file name
DEBIAN_PACKAGE?=$(PACKAGE)_$(PACKAGING_VERSION)_$(ARCHITECTURE).deb
