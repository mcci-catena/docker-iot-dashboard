#!/bin/bash
##############################################################################
#
# Module:  start-node-red.sh
#
# Function:
#	Start up node red in a docker container, doing intial setup.
#
# Version:
#	V0.1	Mon Oct 31 2016 00:53:25 tmm	Edit level 1
#
# Copyright notice:
#	This file copyright (c) 2016 by
#
#		MCCI Corporation
#		3520 Krums Corners Road
#		Ithaca, NY  14850
#
#	Released under the MIT license.
#
# Author:
#	Terry Moore, MCCI Corporation	October 2016
#
# Revision History:
#   0.1  Mon Oct 31 2016 00:53:25  tmm
#	Module created.
#
##############################################################################

PNAME="$(basename "$0")"
PDIR="$(dirname "$0")"
VERBOSE=0
true "${DEBUG:=0}"

TARGET=../.node-red

function _verbose {
	echo "$PNAME:" "$@" 1>&2
}
function _error {
	echo "$PNAME: (FATAL): ""$@" 1>&2
	exit 1
}

function _copyfile {
	# $1 is the source file
	# $2 is the source dir
	# $3 is the target-relative location
	# if the target-relative locatoin doesn't exist, we create it
	# if there is no corresponding file, we copy it
	# otherwise we assume that there's an existing local modification
	# and we leave it alone.
	if [ ! -f "$2/$1" ]; then
		_error "can't find source file:" "$2/$1"
	fi
	if [ ! -d "$TARGET/$3" ]; then
		mkdir -p "$TARGET/$3" || _error "can't mkdir:" "$TARGET/$3"
	fi
	if [ -f "$TARGET/$3/$1" ]; then
		_verbose "target file exists, reusing:" "$TARGET/$3/$1"
	else
		_verbose "creating file:" "$TARGET/$3/$1"
		cp -p "$2/$1" "$TARGET/$3" || _error "can't copy:" "$2/$1" "to:" "$TARGET/$3/$1"
	fi
}

if [ ! -d "${TARGET}" ]; then
	_error "can't find target directory:" "$TARGET"
fi

# copy the files
_copyfile settings.js "$PDIR" .
_copyfile evb "$PDIR" lib/flows

# if there's are arguments, start node-red 
if [ $# -ne 0 ]; then
	_verbose "start:" "$@"
	exec "$@" || _error "can't exec:" "$@"
fi

exit 0

#### end of start-node-red.sh ####
