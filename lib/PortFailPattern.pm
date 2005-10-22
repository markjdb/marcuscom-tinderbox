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
# $MCom: portstools/tinderbox/lib/PortFailPattern.pm,v 1.1.2.1 2005/10/22 06:07:59 marcus Exp $
#

package PortFailPattern;

use strict;
use TinderObject;
use vars qw(@ISA);
@ISA = qw(TinderObject);

sub new {
        my $that        = shift;
        my $object_hash = {
                Port_Fail_Pattern_Id     => "",
                Port_Fail_Pattern_Expr   => "",
                Port_Fail_Pattern_Reason => "",
                Port_Fail_Pattern_Parent => "",
        };

        my @args = ();
        push @args, $object_hash, @_;

        my $self = $that->SUPER::new(@args);

        return $self;
}

sub getId {
        my $self = shift;

        return $self->{Port_Fail_Pattern_Id};
}

sub getExpr {
        my $self = shift;

        return $self->{Port_Fail_Pattern_Expr};
}

sub getReason {
        my $self = shift;

        return $self->{Port_Fail_Pattern_Reason};
}

sub getParent {
        my $self = shift;

        return $self->{Port_Fail_Pattern_Parent};
}

sub setId {
        my $self = shift;
        my $id   = shift;

        $self->{Port_Fail_Pattern_Id} = $id;
}

sub setExpr {
        my $self = shift;
        my $expr = shift;

        $self->{Port_Fail_Pattern_Expr} = $expr;
}

sub setReason {
        my $self   = shift;
        my $reason = shift;

        $self->{Port_Fail_Pattern_Reason} = $reason;
}

sub setParent {
        my $self   = shift;
        my $parent = shift;

        $self->{Port_Fail_Pattern_Parent} = $parent;
}

1;
