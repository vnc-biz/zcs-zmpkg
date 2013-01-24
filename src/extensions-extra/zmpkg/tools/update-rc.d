#!/bin/bash

#
# Just a little dummy to make dpkg happy on non-Debian systems
#
# The point is: dpkg always wants to call the update-rc.d tool
# to trigger service activation after all packages are installed
#

echo "$0: I'm just a dummy, dont panic"
