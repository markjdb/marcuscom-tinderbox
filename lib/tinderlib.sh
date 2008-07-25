#-
# Copyright (c) 2004-2005 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#	notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#	notice, this list of conditions and the following disclaimer in the
#	documentation and/or other materials provided with the distribution.
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
# $MCom: portstools/tinderbox/lib/tinderlib.sh,v 1.46 2008/07/25 05:56:25 marcus Exp $
#

tinderLocJail () {
    jail=$1
    dir=$2

    if [ -z "${HOST_WORKDIR}" ]; then
	echo "$(tinderLoc jail ${jail})/${dir}"
    else
	echo "${HOST_WORKDIR}/jails/${jail}/${dir}"
    fi
}

tinderLoc () {
    type=$1
    what=$2

    case "${type}" in

    "buildroot")	if [ -z "${HOST_WORKDIR}" ]; then
			    echo "${pb}/${what}"
			else
			    echo "${HOST_WORKDIR}/builds/${what}"
			fi
			;;
    "builddata")	echo "${pb}/builds/${what}";;
    "buildports")	echo "$(tinderLoc buildroot ${what})/a/ports";;
    "buildsrc")		echo "$(tinderLoc buildroot ${what})/usr/src";;
    "buildccache")	echo "$(tinderLoc buildroot ${what})/ccache";;
    "buildoptions")	echo "$(tinderLoc buildroot ${what})/var/db/ports";;
    "builddistcache")	echo "$(tinderLoc buildroot ${what})/distcache";;
    "builderrors")	echo "${pb}/errors/${what}";;
    "buildlogs")	echo "${pb}/logs/${what}";;
    "buildworkdir")	echo "${pb}/wrkdirs/${what}";;
    "ccache")		if [ -z "${HOST_WORKDIR}" ]; then
			    echo "${pb}/${CCACHE_DIR}/${what}"
			else
			    echo "${HOST_WORKDIR}/ccache/${what}"
			fi
			;;
    "options")		if [ -z "${HOST_WORKDIR}" ]; then
    			    echo "${pb}/${OPTIONS_DIR}/${what}"
			else
			    echo "${HOST_WORKDIR}/options/${what}"
			fi
			;;
    "jail")		echo "${pb}/jails/${what}";;
    "jailobj")		echo "$(tinderLocJail ${what} obj)";;
    "jailsrc")		echo "$(tinderLocJail ${what} src)";;
    "jailtmp")		echo "$(tinderLocJail ${what} tmp)";;
    "jailtarball")	echo "$(tinderLoc jail ${what})/${what}.tar";;
    "packages")		echo "${pb}/packages/${what}";;
    "portstree")	echo "${pb}/portstrees/${what}";;
    "scripts")		echo "${pb}/scripts/${what}";;
    *)			echo "/nonexistent/tinderbox/${type}/${what}";;

    esac
}	

tinderEcho () {
    echo "$1" | /usr/bin/fmt 75 79
}

tinderExit () {
    tinderEcho "$1"

    if [ -n "$2" ] ; then
	exit $2
    else
	exit 255
    fi
}

cleanDirs () {
    id=$1; shift; dirs="$*"

    for dir in $*
    do
	echo "${id}: cleaning out ${dir}"
	# perform the first remove
	rm -rf ${dir} >/dev/null 2>&1

	# this may not have succeeded if there are schg files around
	if [ -d ${dir} ]; then
	    chflags -R noschg ${dir} >/dev/null 2>&1
	    rm -rf ${dir} >/dev/null 2>&1
	    if [ $? != 0 ]; then
		echo "*** FAILED (rm ${dir})"
		exit 1 
	    fi
	fi

	# now recreate the directory
	mkdir -p ${dir} >/dev/null 2>&1
	if [ $? != 0 ]; then
	    echo "***FAILED (mkdir ${dir})"
	    exit 1
	fi
    done
}

killMountProcesses () {
    dir=$1

    pids="XXX"
    while [ ! -z "${pids}" ]; do
	pids=$(fstat -f "${dir}" | tail +2 | awk '{print $3}' | sort -u)

	if [ ! -z "${pids}" ]; then
	    echo "Killing off pids in ${dir}"
	    ps -p ${pids}
	    kill -KILL ${pids} 2> /dev/null
	    sleep 2
	fi
    done
}

cleanupMounts () {
    # set up defaults
    _build=""
    _jail=""
    _portstree=""
    _type=""
    _dstloc=""

    # argument processing
    while getopts b:d:j:p:t: arg
    do
	case ${arg} in

	b)	_build=${OPTARG};;
	d)	_dstloc=${OPTARG};;
	j)	_jail=${OPTARG};;
	p)	_portstree=${OPTARG};;
	t)	_type=${OPTARG};;
	?)	return 1;;

	esac
    done

    tc=$(tinderLoc scripts tc)

    case ${_type} in

    buildports|buildsrc|buildccache|builddistcache|buildoptions)
	if [ -z "${_build}" ]; then
	    echo "cleanupMounts: ${_type}: missing build"
	    return 1
	fi
	_dstloc=${_dstloc:-$(tinderLoc ${_type} ${_build})}
	;;

    jail)
	if [ -z "${_jail}" ]; then
	    echo "cleanupMounts: ${_type}: missing jail"
	    return 
	fi
	_dstloc=${_dstloc:-$(tinderLoc jail ${_jail})/src}
	;;

    portstree)
	if [ -z "${_portstree}" ]; then
	    echo "cleanupMounts: ${_type}: missing portstree"
	    return 1
	fi
	_dstloc=${_dstloc:-$(tinderLoc portstree ${_portstree})/ports}
	;;

    *)
	echo "cleanupMounts: ${_type}: unknown type"
	return 1
	;;

    esac

    if [ -n "${_dstloc}" ]; then
	mtpt=$(df | awk '$NF == mtpt { print $NF }' mtpt=${_dstloc})
    fi

    if [ -n "${mtpt}" ]; then
	killMountProcesses ${mtpt}
	if ! umount ${mtpt}; then
	    echo "cleanupMounts: ${chroot}${mtpt} failed"
	    return 1
	fi
    fi

    return 0
}

requestMount () {
    # set up defaults
    _type=""
    _srcloc=""
    _dstloc=""
    _nullfs=0
    _readonly=0
    _build=""
    _jail=""
    _portstree=""
    _fqsrcloc=0

    # argument processing
    while getopts b:d:j:np:rs:t: arg
    do
	case ${arg} in

	b)	_build=${OPTARG};;
	d)	_dstloc=${OPTARG};;
	j)	_jail=${OPTARG};;
	n)	_nullfs=1;;
	p)	_portstree=${OPTARG};;
	r)	_readonly=1;;
	s)	_srcloc=${OPTARG};;
	t)	_type=${OPTARG};;
	?)	return 1;;

	esac
    done

    tc=$(tinderLoc scripts tc)

    case ${_type} in

    buildports)
	if [ -z "${_build}" ] ; then
	    echo "requestMount: ${_type}: missing build"
	    return 1
	fi
	_portstree=$(${tc} getPortsTreeForBuild -b ${_build})
	_dstloc=${_dstloc:-$(tinderLoc buildports ${_build})}

	if [ -z "${_srcloc}" ] ; then
	    _srcloc=$(${tc} getPortsMount -p ${_portstree})
	    if [ -z "${_srcloc}" ] ; then
		_srcloc=${_srcloc:=$(tinderLoc portstree ${_portstree})/ports}
	    else
		_fqsrcloc=1
	    fi
	fi
	;;

    buildsrc)
	if [ -z "${_build}" ]; then
	    echo "requestMount: ${_type}: missing build"
	    return 1
	fi
	_jail=$(${tc} getJailForBuild -b ${_build})
	_dstloc=${_dstloc:-$(tinderLoc buildsrc ${_build})}

	if [ -z "${_srcloc}" ]; then
	    _srcloc=$(${tc} getSrcMount -j ${_jail})
	    if [ -z "${_srcloc}" ]; then
		_srcloc=${_srcloc:=$(tinderLoc jail ${_jail})/src}
	    else
		_fqsrcloc=1
	    fi
	fi
	;;

    buildccache)
	if [ -z "${_build}" ]; then
	    echo "requestMount: ${_type}: missing build"
	    return 1
	fi
	_dstloc=${_dstloc:-$(tinderLoc buildccache ${_build})}
	;;

    builddistcache)
	if [ -z "${_build}" ]; then
	    echo "requestMount: ${_type}: missing build"
	    return 1
	fi
	_dstloc=${_dstloc:-$(tinderLoc builddistcache ${_build})}
	_fqsrcloc=1
	;;

    buildoptions)
    	if [ -z "${_build}" ]; then
	    echo "requestMount: ${_type}: missing build"
	    return 1
	fi
	_dstloc=${_dstloc:-$(tinderLoc buildoptions ${_build})}
	;;

    jail)
	if [ -z "${_jail}" ]; then
	    echo "requestMount: ${_type}: missing jail"
	    return 1
	fi
	_dstloc=${_dstloc:-$(tinderLoc jail ${_jail})/src}
	_srcloc=${_srcloc:-$(${tc} getSrcMount -j ${_jail})}
	_fqsrcloc=1
	;;

    portstree)
	if [ -z "${_portstree}" ] ; then
	    echo "requestMount: ${_type}: missing portstree"
	    return 1
	fi
	_dstloc=${_dstloc:-$(tinderLoc portstree ${_portstree})/ports}
	_srcloc=${_srcloc:-$(${tc} getPortsMount -p ${_portstree})}
	_fqsrcloc=1
	;;

    *)
	echo "requestMount: ${_type}: unknown type"
	return 1
	;;

    esac

    if [ -z "${_srcloc}" ]; then
	# we assume that we're running strictly from a local filesystem
	# and that no mounts are required
	return 0
    fi
    if [ -z "${_dstloc}" ]; then
	echo "requestMount: ${_type}: missing destination location"
	return 1
    fi
    
    # is the filesystem already mounted?
    fsys=$(df ${_dstloc} 2>/dev/null | awk '{a=$1}  END {print a}')
    mtpt=$(df ${_dstloc} 2>/dev/null | awk '{a=$NF} END {print a}')

    if [ "${fsys}" = "${_srcloc}" -a "${mtpt}" = "${_dstloc}" ]; then
	return 0
    fi

    # is _nullfs mount specified?
    if [ ${_nullfs} -eq 1 -a ${_fqsrcloc} -ne 1 ] ; then
	_options="-t nullfs"
    else
	# it probably has to be a nfs mount then
	# lets check what kind of _srcloc we have. If it is allready in
	# a nfs format, we don't need to adjust anything
	case ${_srcloc} in

	[a-zA-Z0-9\.-_]*:/*)
		_options="-o nfsv3,intr,tcp"
		;;

	*)
		if [ ${_fqsrcloc} -eq 1 ] ; then
		    # some _srcloc's are full qualified sources, means
		    # don't try to detect sth. or fallback to localhost.
		    # The user wants exactly what he specified as _srcloc
		    # don't modify anything. If it's not a nfs mount, it has
		    # to be a nullfs mount.
		    _options="-t nullfs"
		else
		    _options="-o nfsv3,intr,tcp"

		    # find out the filesystem the requested source is in
		    fsys=$(df ${_srcloc} | awk '{a=$1}  END {print a}')
		    mtpt=$(df ${_srcloc} | awk '{a=$NF} END {print a}')
		    # determine if the filesystem the requested source
		    # is a nfs mount, or a local filesystem

		    case ${fsys} in

		    [a-zA-Z0-9\.-_]*:/*)
			# maybe our destination is a subdirectory of the
			# mountpoint and not the mountpoint itself.
			# if that is the case, add the subdir to the mountpoint
			_srcloc="${fsys}/$(echo $_srcloc | \
					sed 's|'${mtpt}'||')"
			;;

		    *)
			# not a nfs mount, nullfs not specified, so
			# mount it as nfs from localhost
			_srcloc="localhost:/${_srcloc}"
			;;

		    esac

		fi
		;;
	esac
    fi

    if [ ${_readonly} -eq 1 ] ; then
	_options="${_options} -o ro"
    fi

    # Sanity check, and make sure the destination directory exists
    if [ ! -d ${_dstloc} ]; then
	mkdir -p ${_dstloc}
    fi

    mount ${_options} ${_srcloc} ${_dstloc}
    return ${?}
}

buildenvlist () {
    jail=$1
    portstree=$2
    build=$3

    $(tinderLoc scripts tc) configGet

    cat $(tinderLoc scripts lib/tinderbox.env)

    envdir=$(tinderLoc scripts etc/env)

    if [ -f ${envdir}/GLOBAL ]; then
	cat ${envdir}/GLOBAL
    fi
    if [ -n "${jail}" -a -f ${envdir}/jail.${jail} ]; then
	cat ${envdir}/jail.${jail}
    fi
    if [ -n "${portstree}" -a -f ${envdir}/portstree.${portstree} ]; then
	cat ${envdir}/portstree.${portstree}
    fi
    if [ -n "${build}" -a -f ${envdir}/build.${build} ]; then
	cat ${envdir}/build.${build}
    fi
}

cleanenv () {
    SAFE_VARS="PATH EDITOR BLOCKSIZE PAGER ENV pb"
    old_IFS=${IFS}
    IFS='
'

    for i in $(env); do
	var=${i%%=*}
	if ! echo ${SAFE_VARS} | grep -qw ${var}; then
	    unset ${var}
	fi
    done
    IFS=${old_IFS}

    export USER="root"
}

buildenv () {
    jail=$1
    portstree=$2
    build=$3

    major_version=$(echo ${jail} | sed -E -e 's|(^[[:digit:]]+).*$|\1|')
    save_IFS=${IFS}
    IFS='
'
    # Allow SRCBASE to be overridden
    eval "export SRCBASE=${SRCBASE:-`realpath $(tinderLoc jail ${jail})/src`}" \
	>/dev/null 2>&1

    for _tb_var in $(buildenvlist "${jail}" "${portstree}" "${build}")
    do
	var=$(echo "${_tb_var}" | sed \
		-e "s|^#${major_version}||" \
		-E -e 's|\^\^([^\^]+)\^\^|${\1}|g' -e 's|^#.*$||')

	if [ -n "${var}" ]; then
	    eval "export ${var}" >/dev/null 2>&1
	fi
    done

    IFS=${save_IFS}
}

buildenvNoHost () {
    build=$1

    jail=$(${tc} getJailForBuild -b ${build})
    jailBase=$(tinderLoc jail ${jail})
    eval "export __MAKE_CONF=${jailBase}/make.conf" >/dev/null 2>&1
    eval "export LOCALBASE=/nonexistentlocal" >/dev/null 2>&1
    eval "export X11BASE=/nonexistentx" >/dev/null 2>&1
    eval "export PKG_DBDIR=/nonexistentdb" >/dev/null 2>&1
    if [ x"${OPTIONS_ENABLED}" != x"1" ]; then
        eval "export PORT_DBDIR=/nonexistentportdb" >/dev/null 2>&1
    else
	optionsDir=$(tinderLoc options ${build})

	eval "export PORT_DBDIR=${optionsDir}" >/dev/null 2>&1
    fi
    eval "export LINUXBASE=/nonexistentlinux" >/dev/null 2>&1
    eval "unset DISPLAY" >/dev/null 2>&1
}

getDbDriver () {
    db_drivers="mysql pgsql"
    finished=0
    db_driver=""

    while [ ${finished} != 1 ]; do
        read -p "Enter database driver (${db_drivers}): " db_driver

	if echo ${db_drivers} | grep -qw "${db_driver}"; then
	    finished=1
	else
	    echo 1>&2 "Invalid database driver, ${db_driver}."
	fi
    done

    echo ${db_driver}
}

getDbInfo () {
    db_driver=$1

    db_host=""
    db_name=""
    db_admin=""

    read -p "Does this host have access to connect to the Tinderbox database as a database administrator? (y/n)" option

    finished=0
    while [ ${finished} != 1 ]; do
        case "${option}" in
            [Yy]|[Yy][Ee][Ss])
	        read -p "Enter database admin user [root]: " db_admin
                read -p "Enter database host [localhost]: " db_host
	        read -p "Enter database name [tinderbox]: " db_name
	        ;;
            *)
	        return 1
	        ;;
        esac

	db_admin=${db_admin:-"root"}
	db_host=${db_host:-"localhost"}
	db_name=${db_name:-"tinderbox"}

	echo 1>&2 "Are these settings corrrect:"
	echo 1>&2 "    Database Administrative User : ${db_admin}"
	echo 1>&2 "    Database Host                : ${db_host}"
	echo 1>&2 "    Database Name                : ${db_name}"
	read -p "(y/n)" option

	case "${option}" in
	    [Yy]|[Yy][Ee][Ss])
	        finished=1
		;;
        esac
	option="YES"
    done

    echo "${db_admin}:${db_host}:${db_name}"

    return 0
}

loadSchema () {
    schema_file=$1
    db_driver=$2
    db_admin=$3
    db_host=$4
    db_name=$5

    MYSQL_LOAD='/usr/local/bin/mysql -u${db_admin} -p -h ${db_host} ${db_name} < "${schema_file}"'
    MYSQL_LOAD_PROMPT='echo "The next prompt will be for ${db_admin}'"'"'s password to the ${db_name} database." | /usr/bin/fmt 75 79'

    PGSQL_LOAD='/usr/local/bin/psql -U ${db_admin} -W -h ${db_host} -d ${db_name} < "${schema_file}"'
    PGSQL_LOAD_PROMPT='echo "The next prompt will be for ${db_admin}'"'"'s password to the ${db_name} database." | /usr/bin/fmt 75 79'

    if [ ! -f ${schema_file} ]; then
	tinderEcho "ERROR: Schema file ${schema_file} does not exist."
	return 1
    fi

    rc=0
    case "${db_driver}" in
	mysql)
	    eval ${MYSQL_LOAD_PROMPT}
	    eval ${MYSQL_LOAD}
	    rc=$?
	    ;;
	pgsql)
	    eval ${PGSQL_LOAD_PROMPT}
	    eval ${PGSQL_LOAD}
	    rc=$?
	    ;;
	*)
	    echo "Unsupported database driver: ${db_driver}"
	    return 1
	    ;;
    esac

    return ${rc}
}

checkPreReqs () {
    reqs="$@"
    error=0
    missing=""

    for r in ${reqs} ; do
	if [ -z $(pkg_info -Q -O ${r}) ]; then
	    missing="${missing} ${r}"
	    error=1
	fi
    done

    echo "${missing}"

    return ${error}
}

backupDb () {
    tmpfile=$1
    db_driver=$2
    db_admin=$3
    db_host=$4
    db_name=$5

    table_file=$(tinderLoc scripts upgrade/tables.lst)

    MYSQL_DUMP='/usr/local/bin/mysqldump --no-create-info --skip-opt -u${db_admin} -p -h ${db_host} ${db_name} %%TABLE%% >> ${tmpfile}'
    MYSQL_DUMP_PROMPT='echo "The next prompt will be for ${db_admin}'"'"'s password to the ${db_name} database." | /usr/bin/fmt 75 79'

    PGSQL_DUMP='/usr/local/bin/pg_dump -U ${db_admin} -W -h ${db_host} --data-only --inserts --table=%%TABLE%% ${db_name} >> ${tmpfile}'
    PGSQL_DUMP_PROMPT='echo "The next prompt will be for ${db_admin}'"'"'s password to the ${db_name} database." | /usr/bin/fmt 75 79'

    tables=$(cat ${table_file})

    for table in ${tables}; do
	cmd=""
	case "${db_driver}" in
	    mysql)
	        cmd=${MYSQL_DUMP}
		eval ${MYSQL_DUMP_PROMPT}
		;;
	    pgsql)
	        cmd=${PGSQL_DUMP}
		eval ${PGSQL_DUMP_PROMPT}
		;;
	    *)
	        echo "Unsupported database driver: ${db_driver}"
		return 1
		;;
	esac
	cmd=$(echo ${cmd} | sed -e "s|%%TABLE%%|${table}|")
	eval ${cmd}
	if [ $? != 0 ]; then
	    return $?
	fi
    done

    tc=$(tinderLoc scripts tc)
    hooks=$(${tc} listHooks | egrep '^(Name|Command)' 2>/dev/null)
    if [ $? != 0 ]; then
	return 0
    fi

    old_IFS=${IFS}
    IFS='
'
    hname=""
    for line in ${hooks}; do
	name=$(echo ${line} | awk -F'[[:space:]]+:[[:space:]]+' '{print $1}')
	value=$(echo ${line} | awk -F'[[:space:]]+:[[:space:]]+' '{print $2}')
	if [ "${name}" = "Name" ]; then
	    hname=${value}
	    continue
	fi

	if [ -n "${value}" ]; then
	    echo "UPDATE hooks SET hook_cmd='${value}' WHERE hook_name='${hname}'" >> ${tmpfile}
	fi
    done

    IFS=${old_IFS}

    return 0
}

dropDb () {
    db_driver=$1
    db_admin=$2
    db_host=$3
    db_name=$4

    MYSQL_DROP='/usr/local/bin/mysqladmin -u${db_admin} -p -h ${db_host} drop ${db_name}'
    MYSQL_DROP_PROMPT='echo "The next prompt will be for ${db_admin}'"'"'s password to the ${db_name} database." | /usr/bin/fmt 75 79'

    PGSQL_DROP='/usr/local/bin/dropdb -U ${db_admin} -h ${db_host} -W ${db_name}'
    PGSQL_DROP_PROMPT='echo "The next prompt will be for ${db_admin}'"'"'s password to the ${db_name} database." | /usr/bin/fmt 75 79'

    cmd=""
    case "${db_driver}" in
	mysql)
	    cmd=${MYSQL_DROP}
	    eval ${MYSQL_DROP_PROMPT}
	    ;;
	pgsql)
	    cmd=${PGSQL_DROP}
	    eval ${PGSQL_DROP_PROMPT}
	    ;;
	*)
	    echo "Unsupported database driver: ${db_driver}"
	    return 1
	    ;;
    esac
    eval ${cmd}

    # This may fail if the database has already been dropped.  Just return
    # true.
    return 0
}

createDb () {
    db_driver=$1
    db_admin=$2
    db_host=$3
    db_name=$4
    create_ds_ph=$5

    MYSQL_CHECK='/usr/local/bin/mysql -u${db_admin} -B -s -p -h ${db_host} -e "SELECT 0" ${db_name}'
    MYSQL_CREATE='/usr/local/bin/mysqladmin -u${db_admin} -p -h ${db_host} create ${db_name}'
    MYSQL_PROMPT='echo "The next prompt will be for ${db_admin}'"'"'s password to the ${db_name} database." | /usr/bin/fmt 75 79'
    MYSQL_GRANT='/usr/local/bin/mysql -u${db_admin} -p -h ${db_host} -e "GRANT SELECT, INSERT, UPDATE, DELETE ON ${db_name}.* TO '"'"'${db_user}'"'"'@'"'"'${grant_host}'"'"' IDENTIFIED BY '"'"'${db_pass}'"'"' ; FLUSH PRIVILEGES" mysql'
    MYSQL_MAN_PREREQS="databases/p5-DBD-mysql50 databases/mysql40-client"
    MYSQL_OPT_PREREQS="databases/php[45]-mysql"

    PGSQL_CHECK='/usr/local/bin/psql -U ${db_admin} -h ${db_host} -W -c "SELECT 0" ${db_name}'
    PGSQL_CREATE='/usr/local/bin/createdb -U ${db_admin} -h ${db_host} -W ${db_name}'
    PGSQL_PROMPT='echo "The next prompt will be for ${db_admin}'"'"'s password to the ${db_name} database." | /usr/bin/fmt 75 79'
    PGSQL_GRANT='echo "Please manually grant SELECT, INSERT, UPDATE, and DELETE privileges for ${db_user} to all tables in ${db_name}"'
    PGSQL_MAN_PREREQS="databases/p5-DBD-Pg databases/postgresql*-client"
    PGSQL_OPT_PREREQS="databases/php[45]-pgsql"

    prompt=""
    check=""
    create=""
    grant=""
    manprereqs=""
    optprereqs=""
    case "${db_driver}" in
	mysql)
	    prompt=${MYSQL_PROMPT}
	    check=${MYSQL_CHECK}
	    create=${MYSQL_CREATE}
	    grant=${MYSQL_GRANT}
	    manprereqs=${MYSQL_MAN_PREREQS}
	    optprereqs=${MYSQL_OPT_PREREQS}
	    ;;
	pgsql)
	    prompt=${PGSQL_PROMPT}
	    check=${PGSQL_CHECK}
	    create=${PGSQL_CREATE}
	    grant=${PGSQL_GRANT}
	    manprereqs=${PGSQL_MAN_PREREQS}
	    optprereqs=${PGSQL_OPT_PREREQS}
	    ;;
	*)
	    echo "Unsupported database driver: ${db_driver}"
	    return 1
	    ;;
    esac

    tinderEcho "INFO: Checking for prerequisites for ${db_driver} database driver ..."
    if [ -n "${manprereqs}" ]; then
	missing=$(checkPreReqs ${manprereqs})

	if [ $? = 1 ]; then
	    tinderEcho "ERROR: The following mandatory dependencies are missing.  These must be installed prior to creating the Tinderbox database."
	    tinderEcho "ERROR:     ${missing}"
	    return 1
	fi
    fi

    if [ -n "${optprereqs}" ]; then
	missing=$(checkPreReqs ${optprereqs})

	if [ $? = 1 ]; then
	    tinderEcho "WARN: The following option dependencies are missing.  These are required to use the Tinderbox web front-end."
	    tinderEcho "WARN:     ${missing}"
	fi
    fi
    tinderEcho "DONE."
    echo ""

    tinderEcho "INFO: Checking to see if database ${db_name} already exists on ${db_host} ..."
    eval ${prompt}
    eval ${check} 2>/dev/null
    if [ $? = 0 ]; then
	tinderEcho "WARN: A database with the name ${db_name} already exists on ${db_host}.  Do you want to use this database for Tinderbox (note: if you type 'n', database creation will abort)?"
	read -p "(y/n) " i
	case "${i}" in
	    [Yy]|[Yy][Ee][Ss])
	        # continue
		;;
	    *)
	        tinderEcho "INFO: Database creation aborted by user."
		return 1
		;;
	esac
    else
	tinderEcho "INFO: Database ${db_name} does not exist.  Creating ${db_name} on ${db_host} ..."
	eval ${prompt}
	eval ${create}
	if [ $? != 0 ]; then
	    return $?
	fi
    fi

    tinderEcho "INFO: Loading Tinderbox schema into ${db_name} ..."
    schema=$(tinderLoc scripts sql/tinderbox-${db_driver}.schema)
    genschema=$(tinderLoc scripts sql/genschema)
    ${genschema} ${db_driver} > ${schema}
    if [ ! -f ${schema} ]; then
	tinderEcho "ERROR: Schema file ${schema} does not exist."
	return 1
    fi

    loadSchema ${schema} ${db_driver} ${db_admin} ${db_host} ${db_name}
    rc=$?
    rm -f ${schema}

    if [ ${rc} != 0 ]; then
	tinderEcho "ERROR: Database schema load failed!  Consult the output above for more information."
	return 1
    fi

    finished=0
    while [ ${finished} != 1 ]; do
	read -p "Enter the desired username for the Tinderbox database : " db_user
	db_pass=""
	if [ "${db_driver}" = "mysql" ]; then
	    pwfinished=0
	    while [ ${pwfinished} != 1 ]; do
		stty -echo
		reap -p "Enter the desired password for ${db_user} : " db_pass
		stty echo
		echo ""
		stty -echo
		reap -p "Confirm password for ${db_user} : " confirm_pass
		stty echo
		echo ""
		if [ ${db_pass} = ${confirm_pass} ]; then
		    pwfinished=1
		else
		    echo "WARN: Passwords do not match!"
		fi
	    done
	fi
	echo "Are these the settings you want:"
	echo "    Database username      : ${db_user}"
	if [ -n "${db_pass}" ]; then
	    echo "    Database user password : ****"
	fi
	read -p "(y/n) " option

	case "${option}" in
	    [Yy]|[Yy][Ee][Ss])
	        finished=1
		;;
	esac
    done

    grant_host=""
    if [ ${db_host} = "localhost" ]; then
	grant_host="localhost"
    else
	grant_host=$(hostname)
    fi

    if [ "${db_driver}" != "pgsql" ]; then
        tinderEcho "INFO: Adding permissions to ${db_name} for ${db_user} ..."
        eval ${prompt}
    fi
    eval ${grant}

    if [ $? != 0 ]; then
	tinderEcho "ERROR: Database privilege configuration failed! Consult the output above for more information."
	return $?
    fi

    tinderEcho "DONE."
    echo ""

    if [ ${create_ds_ph} = 1 ]; then
	ds_ph=$(tinderLoc scripts ds.ph)
	db_type="database"
	if [ "${db_driver}" = "pgsql" ]; then
	    db_driver="Pg"
	    db_type="dbname"
	fi
	cat > ${ds_ph} << EOT
\$DB_DRIVER	= '${db_driver}';
\$DB_HOST	= '${db_host}';
\$DB_NAME	= '${db_name}';
\$DB_USER	= '${db_user}';
\$DB_PASS	= '${db_pass}';
\$DBI_TYPE	= '${db_type}';

1;
EOT
    fi

    return 0
}

migDb () {
    do_load=$1
    db_driver=$2
    db_admin=$3
    db_host=$4
    db_name=$5
    mig_file=$(tinderLoc scripts upgrade/mig_${db_driver}_tinderbox-${MIG_VERSION_FROM}_to_${MIG_VERSION_TO}.sql)

    if [ -s "${mig_file}" ]; then
	if [ ${do_load} = 1 ]; then
	    tinderEcho "INFO: Migrating database schema from ${MIG_VERSION_FROM} to ${MIG_VERSION_TO} ..."
	    if ! loadSchema "${mig_file}" ${db_driver} ${db_admin} ${db_host} ${db_name} ; then
	        tinderEcho "ERROR: Failed to load upgrade database schema."
	        return 2
	    fi
	    tinderEcho "DONE."
	else
	    tinderEcho "WARN: You must load ${mig_file} to complete your upgrade."
	fi
    else
	return 1
    fi

    return 0
}

execute_hook () {
    name=$1
    env=$2

    tc=$(tinderLoc scripts tc)
    hook_cmd=$(${tc} getHookCmd -h ${name})
    if [ -z "${hook_cmd}" ]; then
	return 0
    fi

    echo "execute_hook: Running ${hook_cmd} for ${name} with environment \"${env}\" from ${pb}/scripts."

    (
      cleanenv
      cd ${pb}/scripts
      eval "env ${env}" $(realpath ${hook_cmd})
      exit $?
    )

    rc=$?

    if [ ${rc} -ne 0 ]; then
	echo "execute_hook: Failed to run ${hook_cmd}, exited with ${rc}."
    fi

    return ${rc}
}
