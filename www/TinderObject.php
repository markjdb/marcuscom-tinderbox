<?php
#-
# Copyright (c) 2004 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
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
# $Id: TinderObject.php,v 1.4 2004/03/03 16:39:21 pav Exp $
#

    class TinderObject {
	var $_object_hash = array();

	function TinderObject($object_hash, $attrs = array()) {
	    $this->_object_hash = $object_hash;

	    foreach ($attrs as $key => $value) {
		if (isset($this->_object_hash[$key])) {
		    $this->$key = $value;
		}
	    }
	}

	function toHashRef() {
	    $hashref = array();

	    foreach ($this->_object_hash as $key => $value) {
		$hashref[$key] = $value;
	    }

	    return $hashref;
	}

	function prettyDatetime($input) {
		if (ereg("[0-9]{14}", $input)) {
			/* timestamp */
			return substr($input,0,4)."-".substr($input,4,2)."-".substr($input,6,2)." ".substr($input,8,2).":".substr($input,10,2).":".substr($input,12,2);
		} elseif (ereg("[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}", $input)) {
			/* datetime */
			if ($input == "0000-00-00 00:00:00") {
				return "";
			} else {
				return $input;
			}
		} else {
			return $input;
		}
	}

	function prettyEmail($input) {
		return str_replace("@FreeBSD.org", "", $input);
	}

    }
?>