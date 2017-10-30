## OpenXPKI::Crypto::Tool::SCEP::Command::create_nextca_reply
## Written 2015 by Gideon Knocke for the OpenXPKI project
## (C) Copyright 20015 by The OpenXPKI Project
package OpenXPKI::Crypto::Tool::SCEP::Command::create_nextca_reply;

use strict;
use warnings;

use Class::Std;

use OpenXPKI::Debug;
use Crypt::LibSCEP;
use MIME::Base64;

my %chain_of   :ATTR;
my %engine_of  :ATTR;
my %hash_alg_of  :ATTR;
my %fu_of      :ATTR;

sub START {
    my ($self, $ident, $arg_ref) = @_;

    $fu_of{$ident} = OpenXPKI::FileUtils->new();
    $engine_of{$ident} = $arg_ref->{ENGINE};
    $chain_of {$ident} = $arg_ref->{CHAIN};
    $hash_alg_of {$ident} = $arg_ref->{HASH_ALG};
}

sub get_result
{
    my $self = shift;
    my $ident = ident $self;

     if (! defined $engine_of{$ident}) {
        OpenXPKI::Exception->throw(
            message => 'I18N_OPENXPKI_CRYPTO_TOOL_SCEP_COMMAND_CREATE_NEXTCA_REPLY_NO_ENGINE',
        );
    }
    ##! 64: 'engine: ' . Dumper($engine_of{$ident})
    my $keyfile  = $engine_of{$ident}->get_keyfile();
    if (! defined $keyfile || $keyfile eq '') {
        OpenXPKI::Exception->throw(
            message => 'I18N_OPENXPKI_CRYPTO_TOOL_SCEP_COMMAND_CREATE_NEXTCA_REPLY_KEYFILE_MISSING',
        );
    }
    my $certfile = $engine_of{$ident}->get_certfile();
    if (! defined $certfile || $certfile eq '') {
        OpenXPKI::Exception->throw(
            message => 'I18N_OPENXPKI_CRYPTO_TOOL_SCEP_COMMAND_CREATE_NEXTCA_REPLY_CERTFILE_MISSING',
        );
    }

    my $cert = $fu_of{$ident}->read_file($certfile);
    my $key = $fu_of{$ident}->read_file($keyfile);

    my $sigalg = $hash_alg_of{$ident};
    my $pwd    = $engine_of{$ident}->get_passwd();
    my $chain = $chain_of{$ident};
    my $nextca_reply;
    eval {
        $nextca_reply = Crypt::LibSCEP::create_nextca_reply({passin=>"pass", passwd=>$pwd, sigalg=>$sigalg}, $chain, $cert, $key);
    };
    if ($@) {
        OpenXPKI::Exception->throw(
            message => $@,
        );
    }
    $nextca_reply =~ s/\n?\z/\n/;
    $nextca_reply =~ s/^(?:.*\n){1,1}//;
    $nextca_reply =~ s/(?:.*\n){1,1}\z//;
    return decode_base64($nextca_reply);

}

sub hide_output
{
    return 0;
}

sub key_usage
{
    return 0;
}

sub get_result
{
    my $self = shift;
    my $ident = ident $self;

    my $pending_reply = $fu_of{$ident}->read_file($outfile_of{$ident});

    return $pending_reply;
}

sub cleanup {
    my $self = shift;
    my $ident = ident $self;

    $ENV{pwd} = '';
    $fu_of{$ident}->cleanup();
}

1;
__END__
