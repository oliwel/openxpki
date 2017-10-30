## OpenXPKI::Crypto::Tool::SCEP::Command::get_getcert_serial
## Written 2015 by Gideon Knocke for the OpenXPKI project
## (C) Copyright 20015 by The OpenXPKI Project
package OpenXPKI::Crypto::Tool::SCEP::Command::get_getcert_serial;

use strict;
use warnings;

use Class::Std;

use OpenXPKI::Debug;
use Crypt::LibSCEP;

my %pkcs7_of   :ATTR;

sub START {
    my ($self, $ident, $arg_ref) = @_;
    $pkcs7_of {$ident} = $arg_ref->{PKCS7};
}

sub get_result
{
    my $self = shift;
    my $ident = ident $self;
    my $serial;
    eval {
        $serial = Crypt::LibSCEP::get_getcert_serial($pkcs7_of{$ident});
    };
    if ($@) {
        OpenXPKI::Exception->throw(
            message => $@,
        );
    }
    return $serial;
}

sub cleanup {
    my $self = shift;
    my $ident = ident $self;

    $ENV{pwd} = '';
    $fu_of{$ident}->cleanup();
}

1;
__END__


=head1 Name

OpenXPKI::Crypto::Tool::SCEP::Command::get_getcert_serial

=head1 Description

This function takes a SCEP handle and returns the
certificate serial number
