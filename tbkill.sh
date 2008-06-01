#!/bin/sh
#-
# Copyright (c) 2008 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $MCom: portstools/tinderbox/tbkill.sh,v 1.1.2.1 2008/06/01 23:55:34 marcus Exp $
#

usage () {
    echo "usage: $0 -b BUILD [-s SIGNAL]"
}

build=""
sig=15

# argument handling
while getopts b:s: arg >/dev/null 2>&1
do
    case "${arg}" in

        b)	build="${OPTARG}";;
	s)	sig="${OPTARG}";;
	?)	usage; exit 1;;

    esac
done

if [ -z "${build}" ]; then
    usage
    exit 1
fi

tbpid=$(pgrep -f -f "/bin/sh.*tinderbuild.*${build}")
if [ -z "${tbpid}" ]; then
    exit 0
fi

makepid=$(pgrep -f -f -P ${tbpid} "make")
makechild=$(pgrep -P ${makepid})
pbpid=$(pgrep -f -f "/bin/sh.*/portbuild")

kill -${sig} ${pbpid} ${makechild} ${makepid} ${tbpid}
