## OpenXPKI::Server::Session.pm
##
## Written 2006 by Michael Bell for the OpenXPKI project
## (C) Copyright 2006 by The OpenXPKI Project

package OpenXPKI::Server::Session;

use strict;
use warnings;
use utf8;

use English;

use OpenXPKI::Exception;
use OpenXPKI::i18n;
use OpenXPKI::Serialization::Simple;
use OpenXPKI::Server::Context qw( CTX );

## switch off IP checks
use CGI::Session qw/-ip-match/;
use Digest::SHA qw( sha1_hex );;

## constructor and destructor stuff

sub new {
    my $that = shift;
    my $class = ref($that) || $that;

    my $self = {};

    bless $self, $class;

    my $keys = shift;

    if (exists $keys->{LIFETIME} and $keys->{LIFETIME} > 0)
    {
        $self->{LIFETIME} = $keys->{LIFETIME};
    }
    else
    {
        OpenXPKI::Exception->throw (
            message => "I18N_OPENXPKI_SERVER_SESSION_NEW_MISSING_LIFETIME");
    }

    if (not exists $keys->{DIRECTORY})
    {
        OpenXPKI::Exception->throw (
            message => "I18N_OPENXPKI_SERVER_SESSION_NEW_MISSING_DIRECTORY");
    }
    if (not -d $keys->{DIRECTORY})
    {
        OpenXPKI::Exception->throw (
            message => "I18N_OPENXPKI_SERVER_SESSION_NEW_DIRECTORY_DOES_NOT_EXIST",
            params  => {DIRECTORY => $keys->{DIRECTORY}});
    }
    $self->{DIRECTORY} = $keys->{DIRECTORY};

    if (exists $keys->{ID})
    {
        $self->{ID} = $keys->{ID};
        $self->{session} = new CGI::Session(
                                   undef,
                                   $self->{ID},
                                   {Directory=>$self->{DIRECTORY}});
        if (not $self->{session} or
            $self->{ID} ne $self->{session}->id())
        {
            $self->{session}->delete() if ($self->{session});
            OpenXPKI::Exception->throw (
                message => "I18N_OPENXPKI_SERVER_SESSION_NEW_LOAD_SESSION_FAILED",
                params  => {ID        => $self->{ID},
                            DIRECTORY => $self->{DIRECTORY}});
        }
        ##! 4: "set language if it is configured in the session"
        if ($self->get_language())
        {
            ##! 8: "setting language to ".$self->get_language()
            OpenXPKI::i18n::set_language ($self->get_language());
        }
    }
    else
    {
        $self->{session} = new CGI::Session(
                                   undef,
                                   undef,
                                   {Directory=>$self->{DIRECTORY}});
        if (not $self->{session})
        {
            OpenXPKI::Exception->throw (
                message => "I18N_OPENXPKI_SERVER_SESSION_NEW_CREATE_SESSION_FAILED",
                params  => {ID        => $self->{ID},
                            DIRECTORY => $self->{DIRECTORY}});
        }
        $self->{session}->param ("status" => "invalid");

    }
    $self->{session}->expire($self->{LIFETIME});
    $self->{session}->flush();

    return $self;
}

sub export_serialized_info{
    my $self = shift;
    my %info;
    my @import_keys = $self->_get_persitence_keys();
    foreach my $key (@import_keys){
        $info{$key} = $self->{session}->param($key);
    }
    return $self->_get_serializer()->serialize(\%info);
}

sub import_serialized_info {
    my $self = shift;
    my $serialized_string = shift;
    my $args = shift;

    unless($serialized_string){
        OpenXPKI::Exception->throw (
                message => "I18N_OPENXPKI_SERVER_SESSION_IMPORT_SERIALIZED_STRING_CAN_NOT_BE_EMPTY"
                );
    }
    my $info = $self->_get_serializer()->deserialize($serialized_string);

    unless(ref $info eq 'HASH'){
        OpenXPKI::Exception->throw (
                message => "I18N_OPENXPKI_SERVER_SESSION_IMPORT_SERIALIZED_STRING_MUST_BE_HASH",
                params  => {INPUT       => $serialized_string,OUTPUT => $info}
                );
    }
    my @import_keys = $self->_get_persitence_keys();

    foreach my $key (@import_keys) {
        # We use the setter as there might be extra actions!
        if (defined $info->{$key} && !$args->{'skip_'.$key}) {
            my $call = "set_".$key;
            $self->$call( $info->{$key} );
        }
    }
}

sub parse_serialized_info {

    my $self = shift;
    my $serialized_string = shift;
    return unless ($serialized_string);

    return $self->_get_serializer()->deserialize($serialized_string);
}

sub _get_serializer{
    return OpenXPKI::Serialization::Simple->new();
}

sub _get_persitence_keys{
    return qw(user role);
}


sub delete
{
    my $self = shift;
    $self->{session}->delete();
    delete $self->{session};
}

sub DESTROY
{
    my $self = shift;
    if (exists $self->{session} and ref $self->{session})
    {
        $self->{session}->expire($self->{LIFETIME});
        $self->{session}->flush();
    }
}

## authentication support / status of session

sub start_authentication
{
    my $self = shift;
    $self->{session}->param ("status" => "auth");
    $self->{session}->flush();
}

sub make_valid
{
    my $self = shift;
    $self->{session}->param ("status" => "valid");
    $self->{session}->flush();
}

sub is_valid
{
    my $self = shift;
    if ($self->{session}->param ("status") eq "valid")
    {
        return 1;
    } else {
        return 0;
    }
}

sub set_challenge
{
    my $self = shift;
    $self->{session}->param ("challenge" => shift);
    $self->{session}->flush();
}

sub get_challenge
{
    my $self = shift;
    $self->{session}->param ("challenge");
}

## fully public getter and setter function

sub set_user
{
    my $self = shift;
    $self->{session}->param ("user" => shift);
    $self->{session}->flush();
}

sub get_user
{
    my $self = shift;
    return $self->{session}->param ("user");
}

sub set_role
{
    my $self = shift;
    $self->{session}->param ("role" => shift);
    $self->{session}->flush();
}

sub get_role
{
    my $self = shift;
    return $self->{session}->param ("role");
}

sub set_pki_realm
{
    my $self = shift;
    $self->{session}->param ("pki_realm" => shift);
    $self->{session}->flush();
}

sub get_pki_realm
{
    my $self = shift;
    return $self->{session}->param ("pki_realm");
}

sub set_authentication_stack
{
    my $self = shift;
    $self->{session}->param ("authentication_stack" => shift);
    $self->{session}->flush();
}

sub get_authentication_stack
{
    my $self = shift;
    return $self->{session}->param ("authentication_stack");
}

sub set_language
{
    my $self = shift;
    $self->{session}->param ("language" => shift);
    $self->{session}->flush();
}

sub get_language
{
    my $self = shift;
    return $self->{session}->param ("language");
}

sub get_id
{
    my $self = shift;
    return $self->{session}->id();
}

sub set_secret
{
    my $self   = shift;
    my $args   = shift;
    my $group  = $args->{GROUP} || '';
    my $secret = $args->{SECRET};
    my $name   = "secret_".sha1_hex($group);
    $self->{session}->param ($name => $secret);
    $self->{session}->flush();
}

sub get_secret
{
    my $self  = shift;
    my $group = shift || '';
    my $name  = "secret_".sha1_hex($group);
    return $self->{session}->param ($name);
}

sub clear_secret
{
    my $self  = shift;
    my $group = shift || '';
    my $name  = "secret_".sha1_hex($group);
    $self->{session}->clear ($name);
    $self->{session}->flush();
}

sub set_state
{
    my $self = shift;
    $self->{session}->param ("state" => shift);
    $self->{session}->flush();
}

sub get_state
{
    my $self = shift;
    return $self->{session}->param ("state");
}

# For SCEP - FIXME - move whole Session to Moose
sub set_profile {
    my $self = shift;
    $self->{profile} = shift;
}

sub get_profile {
    my $self = shift;
    return $self->{profile};
}

sub set_server {
    my $self = shift;
    $self->{server} = shift;
}

sub get_server {
    my $self = shift;
    return $self->{server};
}

sub set_enc_alg {
    my $self = shift;
    $self->{enc_alg} = shift;
}

sub get_enc_alg {
    my $self = shift;
    return $self->{enc_alg};
}

sub set_hash_alg {
    my $self = shift;
    $self->{hash_alg} = shift;
}

sub get_hash_alg {
    my $self = shift;
    return $self->{hash_alg};
}


1;
__END__

=head1 Name

OpenXPKI::Server::Session

=head1 Description

This module implements the complete session mechanism for the
OpenXPKI core code. This include some mechanisms to support the
authentication phase which means that it is possible to operate
a session in a mode which is not valid.

=head1 Function

=head2 Constructor/Destructor

=head3 new

This function creates a new or load an already existing session.
It supports the following parameters:

=over

=item * LIFETIME [seconds]

=item * DIRECTORY [path to "cookie" area]

=item * ID [session ID]

=back

=head3 delete

This function is called without any argument and simply removes
the session. This is required on failed authentications. Please
note that the behaviour of an object refrence after a call to
delete is completeley undefined. Simply drop any references
to a session object after you call delete on it.

=head2 Status Management (authentication support)

=head3 start_authentication

sets the status of the session to authentication mode.

=head3 make_valid

sets the status of the session to valid.

=head3 is_valid

returns 1 if it is a valid session and 0 if the session is not valid.

=head3 set_challenge

sets a challenge string. This is useful for authentication tasks
if the session is not valid.

=head3 get_challenge

returns a challenge string if such a string was set in the past.

=head2 Session persistence

The session module supports persistence across the lifetime of the
originating process. You can use C<export_serialized_info> to get a hash
representing the current state of the session and  C<import_serialized_info>
to make a new session impersonate those state.
You can define what keys are persisted in C<_get_persitence_keys>.

=head3 _get_persitence_keys
Returns the keys that should be used when persisting the session.
Currently the fields are user role

=head3 export_serialized_info
Return a key/value hash with the keys named in _get_persitence_keys.

=head3 import_serialized_info

Pass a string with the serialized info as obtained by export_serialized_info.
The parameters overwrite the current session settings. You can add a hash a
second parameter with I<skip_variable_name =\> 1> to skip certain values.

=head3 parse_serialized_info

Parse a serialized session blob and return as hash.

=head2 Set/Get functions

=over

=item * set_user

=item * get_user

=item * set_role

=item * get_role

=item * set_pki_realm

=item * get_pki_realm

=item * get_id

=item * get_language

=item * set_language

=item * get_secret

=item * set_secret

=item * get_state

=item * set_state

=item * delete_secret

=back
