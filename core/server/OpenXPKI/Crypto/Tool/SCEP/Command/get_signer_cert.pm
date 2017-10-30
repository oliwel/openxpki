## OpenXPKI::Crypto::Tool::SCEP::Command::get_signer_cert
## Written 2015 by Gideon Knocke for the OpenXPKI project
## (C) Copyright 20015 by The OpenXPKI Project
package OpenXPKI::Crypto::Tool::SCEP::Command::get_signer_cert;

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
    my $signerCert;
    eval {
        $signerCert = Crypt::LibSCEP::get_signer_cert($pkcs7_of{$ident});
    };
    if ($@) {
        OpenXPKI::Exception->throw(
            message => $@,
        );
    }
    return $signerCert;
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

OpenXPKI::Crypto::Tool::SCEP::Command::get_signer_cert

=head1 Description

This function takes a SCEP handle and returns the
signer certificate from it
