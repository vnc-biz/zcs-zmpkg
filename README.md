ZMPKG - Package Management for Zimbra
=====================================

# The Problem

Zimbra provides several levels of possible add-ons to the core product. Unfortunately these are not defined very well (at least so far). For our developments we came up with these definitions:

* a **Zimlet** is a javascript add-on to the actual Zimbra Webclient
* to provide extended webservices to zimlets we can add additional **JSP**
* an **extension** to further extend functionality for JSPs additional libraries (".jar") can be added

The traditional deployment methods as provided by zimbra come with several problems:

* when you develop multiple zimlets it is very likely that you create code you want to re-use. The obvious solution is to move that code to a dedicated package. Unfortunately the standard zimlet interface does not provide dependenies.
* zimlets can be deployed using admin web UI or *zmzimletctl* - and they expect a zip file. Unfortunately version info can only be set in a file inside the zip file. So it is very likely you mix up files ...

# The situation

Up to zimbra 8.6 there are plenty different zimlets available, and (with different vendors) different deployment methods are available. While most vendors of simple zimlets stick to the traditional zip file, other vendors provide (more or less elaborate) shell scripts to deploy their zimlets.

And while most vendors bascially provide components that run in ZWC directly (i.e. plain javascript zimlets) others do provide the complete chain as described above.

Some obvious libraries to use would be the apache-commons-libraries, e.g. httpclient. Now what happens if 2 "zimlets" simply include the same lib? And what if there are several versions?

# The solution

The right solution is rather obvious. We need a reliable system that provides easy deployments, dependency management and which ensures reproducible deployments.

Our solution is to provide a OS-independent package management system without re-inventing the wheel. So we basically created a wrapper to run dpkg / apt without (or with minimal) interference with OS distribution package management.

As long as Zimbra provides a rather distribution-agnostic environment in `/opt/zimbra/` the package management can be distribution-agnostic as well.


# Releases

zmpkg currently comes in three release lines:

	1.2.*	Zimbra7 / Helix (deprecated, support will be dropped sometime in 2016)
	1.3.*	Zimbra8 / IronMaiden
	1.4.*	Zimbra8.x / JudasPriest

The split was necessary due different packaging metadata (architecture ident has changed).

DON'T MIX THEM UP.


# For Operators / Users

Installer tarballs can be found at:

    * http://packages.vnc.biz/zmpkg/bootstrap/

See

    https://collaboration.vnc.biz/product-area/vnc-business-cloud-apps/vnc-zimlets/zmpkg-and-vnc-zimlets-installation-info

for more information.


# Developer notes

Important branches:

	* release-1.2	maintenance branch for 1.2 line
			(no new features anymore)

	* release-1.3	maintenance branch for 1.3.0 line
			possibly will also receive some rpm-related fixes
			to publish them earlier than official 1.3.1 release

	* release-1.4	active development, notably direct support for
			rpm-based distros (RHEL/CENTOS/SLES)

All releases will be tagged properly. Futher information will be provided in developer manual.

# License

Copyright (C) 2013 - 2016 VNC AG

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.
