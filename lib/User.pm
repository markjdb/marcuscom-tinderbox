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
# $MCom: portstools/tinderbox/lib/User.pm,v 1.6 2005/08/22 00:50:44 marcus Exp $
#

package User;

use strict;
use TinderObject;
use vars qw(@ISA);
@ISA = qw(TinderObject);

use constant USER_ID_FIELD => 'User_Id';

sub new {
        my $that        = shift;
        my $object_hash = {
                User_Id          => "",
                User_Name        => "",
                User_Email       => "",
                User_Password    => "",
                User_Www_Enabled => "",
        };

        my @args = ();
        push @args, $object_hash, @_;

        my $self = $that->SUPER::new(@args);
        $self->{'_id_field'} = USER_ID_FIELD;

        return $self;
}

sub getId {
        my $self = shift;

        return $self->{User_Id};
}

sub getName {
        my $self = shift;

        return $self->{User_Name};
}

sub getEmail {
        my $self = shift;

        return $self->{User_Email};
}

sub getPassword {
        my $self = shift;

        return $self->{User_Password};
}

sub getWwwEnabled {
        my $self = shift;

        return $self->{User_Www_Enabled};
}

sub setName {
        my $self = shift;
        my $name = shift;

        $self->{User_Name} = $name;
}

sub setEmail {
        my $self  = shift;
        my $email = shift;

        $self->{User_Email} = $email;
}

sub setPassword {
        my $self     = shift;
        my $password = shift;

        $self->{User_Password} = $password;
}

sub setWwwEnabled {
        my $self       = shift;
        my $wwwenabled = shift;

        $self->{User_Www_Enabled} = $wwwenabled;
}

1;
