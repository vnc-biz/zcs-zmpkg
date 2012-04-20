VERSION=1.0.2
PACKAGE=zcs-zmpkg
MAINTAINER=Enrico Weigelt <enrico.weigelt@vnc.biz>
SECTION=base
ARCHITECTURE=All
PRIORITY=optional
DESCRIPTION=Zimbra package management system
DISTPREFIX=$(TOPDIR)/dist
DISTDIR=$(DISTPREFIX)/$(PACKAGE)-$(VERSION)
DISTFILE=$(DISTPREFIX)/$(PACKAGE)-$(VERSION).tar.gz
JAVA?=java
JAR?=jar
JAVAC?=javac
IMAGE_ROOT=$(TOPDIR)/image

ifeq ($(REDMINE_UPLOAD_URL),)
REDMINE_UPLOAD_URL=https://redmine.vnc.biz/redmine/
endif
ifeq ($(REDMINE_UPLOAD_PROJECT),)
REDMINE_UPLOAD_PROJECT=zcs-zmpkg
endif
