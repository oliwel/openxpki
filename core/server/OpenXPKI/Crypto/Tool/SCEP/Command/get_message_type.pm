## OpenXPKI::Crypto::Tool::SCEP::Command::get_message_type
## Written 2015 by Gideon Knocke for the OpenXPKI project
## (C) Copyright 20015 by The OpenXPKI Project
package OpenXPKI::Crypto::Tool::SCEP::Command::get_message_type;

use strict;
use warnings;

use Class::Std;

use OpenXPKI::Debug;
use Crypt::LibSCEP;

my %pkcs7_of   :ATTR;

sub START {
    my ($self, $ident, $arg_ref) = @_;
    $pkcs7_of{$ident} = $arg_ref->{PKCS7};
}

sub get_result
{
    my $self = shift;
    my $ident = ident $self;
    my $message_type;
    eval {
        $message_type = Crypt::LibSCEP::get_message_type($pkcs7_of{$ident});
    };
    if ($@) {
        OpenXPKI::Exception->throw(
            message => $@,
        );
    }
    return $message_type;
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

OpenXPKI::Crypto::Tool::SCEP::Command::get_message_type

=head1 Description

This function takes a SCEP handle and returns a string indicating
the message type.
