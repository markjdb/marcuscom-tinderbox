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
# $MCom: portstools/tinderbox/lib/PortFailReason.pm,v 1.1.2.1 2005/10/22 06:07:59 marcus Exp $
#

package PortFailReason;

use strict;
use TinderObject;
use vars qw(@ISA %TYPE_HASH);
@ISA = qw(TinderObject);

%TYPE_HASH = (
        COMMON    => 0,
        RARE      => 1,
        TRANSIENT => 2,
);

sub new {
        my $that        = shift;
        my $object_hash = {
                Port_Fail_Reason_Tag   => "",
                Port_Fail_Reason_Descr => "",
                Port_Fail_Reason_Type  => "",
        };

        my @args = ();
        push @args, $object_hash, @_;

        my $self = $that->SUPER::new(@args);

        return $self;
}

sub getTag {
        my $self = shift;

        return $self->{Port_Fail_Reason_Tag};
}

sub getDescr {
        my $self = shift;

        return $self->{Port_Fail_Reason_Descr};
}

sub getType {
        my $self = shift;

        return $self->{Port_Fail_Reason_Type};
}

sub setTag {
        my $self = shift;
        my $tag  = shift;

        $self->{Port_Fail_Reason_Tag} = $tag;
}

sub setDescr {
        my $self  = shift;
        my $descr = shift;

        $self->{Port_Fail_Reason_Descr} = $descr;
}

sub setType {
        my $self = shift;
        my $type = shift;

        if (defined($TYPE_HASH{$type})) {
                $self->{Port_Fail_Reason_Type} = $type;
        }
}

1;
