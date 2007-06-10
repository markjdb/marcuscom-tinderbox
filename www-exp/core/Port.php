<?php
#-
# Copyright (c) 2004-2007 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
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
# $MCom: portstools/tinderbox/www-exp/core/Port.php,v 1.2.2.2 2007/06/10 03:38:05 marcus Exp $
#

    require_once 'TinderObject.php';

    class Port extends TinderObject {

	function Port($argv = array()) {
	    $object_hash = array(
                'Build_Id' => '',
		'Port_Id' => '',
		'Port_Name' => '',
		'Port_Directory' => '',
		'Port_Comment' => '',
		'Port_Maintainer' => '',
		'Currently_Building' => '',
		'Last_Built' => '',
		'Last_Status' => '',
		'Last_Successful_Built' => '',
		'Last_Built_Version' => '',
		'Last_Failed_Dependency' => '',
		'Last_Run_Duration' => '',
		'Last_Fail_Reason' => ''
	    );

	    $this->TinderObject($object_hash, $argv);
	}

        function getBuildId() {
            return $this->Build_Id;
        }

	function getId() {
	    return $this->Port_Id;
	}

	function getName() {
	    return $this->Port_Name;
	}

	function getDirectory() {
	    return $this->Port_Directory;
	}

	function getComment() {
	    return $this->Port_Comment;
	}

	function getMaintainer() {
	    return $this->Port_Maintainer;
	}

	function getCurrentlyBuilding() {
	    return $this->_truth_array[$this->Currently_Building];
	}

	function getLastBuilt() {
	    return $this->Last_Built;
	}

	function getLastStatus() {
	    return $this->Last_Status;
	}

	function getLastSuccessfulBuilt() {
	    return $this->Last_Successful_Built;
	}

	function getLastBuiltVersion() {
	    return $this->Last_Built_Version;
	}

	function getLastFailReason() {
	    return $this->Last_Fail_Reason;
	}

	function getLastFailedDep() {
	    return $this->Last_Failed_Dependency;
	}

	function getLastRunDuration() {
	    return $this->Last_Run_Duration;
	}

	function getLogfileName() {
	    return $this->getLastBuiltVersion() . ".log";
	}

	function setName($name) {
	    $this->Port_Name = $name;
	}

	function setDirectory($dir) {
	    $this->Port_Directory = $dir;
	}

	function setComment($comment) {
	    $this->Port_Comment = $comment;
	}

	function setMaintainer($maintainer) {
	    $this->Port_Maintainer = $maintainer;
	}


    }
?>
