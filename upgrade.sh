#!/bin/sh
#-
# Copyright (c) 2004-2005 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
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
# $MCom: portstools/tinderbox/upgrade.sh,v 1.11 2005/09/08 14:41:39 marcus Exp $
#

pb=$0
[ -z "$(echo "${pb}" | sed 's![^/]!!g')" ] && \
pb=$(type "$pb" | sed 's/^.* //g')
pb=$(realpath $(dirname $pb))
pb=${pb%%/scripts}

VERSION="2.1.0"

# DB_MIGRATION_PATH contains all versions where upgrade SQLs are existing for
# if DB_MIGRATION_PATH is for example "1.X 2.0.0 2.0.1 2.1.0" then there are
# scripts for 1.X->2.0.0, 2.0.0->2.0.1, 2.0.1->2.1.0 so even a user with 1.X
# could easily upgrade to the latest version and none needs to maintain
# 1.X->2.0.0, 1.X->2.0.1, 1.X->2.1.0 and so on scripts.
DB_MIGRATION_PATH="1.X ${VERSION}"

RAWENV_HEADER="## rawenv TB v2 -- DO NOT EDIT"
REMOVE_FILES="Build.pm BuildPortsQueue.pm Host.pm Jail.pm MakeCache.pm Port.pm PortsTree.pm TBConfig.pm TinderObject.pm TinderboxDS.pm User.pm setup_shlib.sh tinderbox_shlib.sh tinderlib.pl create_new_build create_new_jail create_new_portstree list_jails"
TINDERBOX_URL="http://tinderbox.marcuscom.com/"

. ${pb}/scripts/upgrade/mig_shlib.sh
. ${pb}/scripts/lib/tinderbox_shlib.sh

clear

tinder_echo "Welcome to the Tinderbox Upgrade and Migration script.  This script will guide you through an upgrade to Tinderbox ${VERSION}."
echo ""

read -p "Hit <ENTER> to get started: " i

# Check if the current Datasource Version is ascertainable
if ${pb}/scripts/tc dsversion >/dev/null 2>&1 ; then
	DSVERSION=$(${pb}/scripts/tc dsversion)
else
    tinder_exit "ERROR: Database migration failed!  Consult the output above for more information." $?
fi

# First, migrate the database, if needed.
echo ""
db_host=""
db_name=""
db_admin=""
do_load=0
db_driver=$(get_dbdriver)
dbinfo=$(get_dbinfo ${db_driver})
if [ $? = 0 ]; then
    db_admin_host=${dbinfo%:*}
    db_name=${dbinfo##*:}
    db_admin=${db_admin_host%:*}
    db_host=${db_admin_host#*:}
    do_load=1
fi

set -- $DB_MIGRATION_PATH
while [ -n "${1}" -a -n "${2}" ] ; do
    MIG_VERSION_FROM=${1}
    MIG_VERSION_TO=${2}

    if [ ${MIG_VERSION_FROM} = ${DSVERSION} ] ; then
        mig_db ${do_load} ${db_driver} ${db_admin} ${db_host} ${db_name}
        case $? in
            2)    tinder_exit "ERROR: Database migration failed!  Consult the output above for more information." 2
                  ;;
            1)    tinder_exit "ERROR: No Migration Script available to migrate ${MIG_VERSION_FROM} to ${MIG_VERSION_TO}" 1
                  ;;
            0)    DSVERSION=${MIG_VERSION_TO}
                  ;;
        esac
    fi
    shift 1
done

if [ ${do_load} = 0 ]; then
    tinder_echo "WARN: Database migration was not done.  If you proceed, you may encounter errors.  It is recommended you manually load any necessary schema updates, then re-run this script.  If you have already loaded the database schema, type 'y' or 'yes' to continue the migration."
    echo ""
    read -p "Do you wish to continue? (y/n)" i
    case ${i} in
	[Yy]|[Yy][Ee][Ss])
	    # continue
	    ;;
	*)
	   tinder_exit "INFO: Upgrade aborted by user."
	   ;;
    esac
fi

# Now migrate rawenv if needed.
echo ""
if ! mig_rawenv ${pb}/scripts/rawenv ; then
    tinder_exit "ERROR: Rawenv migration failed!  Consult the output above for more information." 1
fi

# Finally, migrate any remaining file data.
echo ""
if ! mig_files ${pb}/scripts/rawenv ; then
    tinder_exit "ERROR: Files migration failed!  Consult the output above for more information." 1
fi

echo ""
tinder_exit "Congratulations!  Tinderbox migration is complete.  Please refer to ${TINDERBOX_URL} for a list of what is new in this version as well as general Tinderbox documentation." 0