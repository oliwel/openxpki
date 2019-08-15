# OpenXPKI::Server::Workflow::Activity::Tools::Datapool::ModifyEntry
# Written by Martin Bartosch for the OpenXPKI project 2010
# Copyright (c) 2010 by The OpenXPKI Project

package OpenXPKI::Server::Workflow::Activity::Tools::Datapool::ModifyEntry;

use strict;
use English;
use base qw( OpenXPKI::Server::Workflow::Activity );

use OpenXPKI::Server::Context qw( CTX );
use OpenXPKI::Exception;
use OpenXPKI::Debug;
use OpenXPKI::DateTime;
use DateTime;
use Template;

use Data::Dumper;

sub execute {
    ##! 1: 'start'
    my $self       = shift;
    my $workflow   = shift;
    my $context    = $workflow->context();

    my $params     = {
        pki_realm => CTX('api2')->get_pki_realm(),
        namespace => $self->param('namespace'),
        key => $self->param('key'),
    };

    if (!$params->{namespace}) {
        configuration_error('Datapool::GetEntry requires the namespace parameter');
    }
    if (!$params->{key}) {
        configuration_error('Datapool::GetEntry requires the key parameter');
    }

    if (my $newkey = $self->param('newkey')) {
        $params->{newkey} = $newkey;
    }

    my $expiration_date = $self->param('expiration_date');
    if ($expiration_date) {
        my $then = OpenXPKI::DateTime::get_validity({
            REFERENCEDATE  => DateTime->now(),
            VALIDITY       => $expiration_date,
            VALIDITYFORMAT => 'relativedate',
        });
        $params->{expiration_date} = $then->epoch();
    } elsif (defined $expiration_date) {
        $params->{expiration_date} = undef;
    }


    ##! 16: 'modify_data_pool_entry params: ' . Dumper $params
    CTX('api2')->modify_data_pool_entry($params);

    return 1;
}

1;
__END__

=head1 Name

OpenXPKI::Server::Workflow::Activity::Tools::Datapool::ModifyEntry

=head1 Description

This class modifies the key and/or expiration date of a datapool entry.
It does NOT change the value of a datapool entry.

=head1 Configuration

=head2 Parameters

In the activity definition, the following parameters must be set.
See the example that follows.

=over 8

=item namespace

The namespace to use.

=item key

Key within the namespace to access.

=item newkey

New key for the entry.

=item force

Causes the set action to overwrite an existing entry.

=item expiration_date

Sets expiration date of the datapool entry to the specified value.
The value should be a relative time specification (such as '+000001',
which means one day). See OpenXPKI::DateTime::get_validity, section
'relativedate' for details.

If the expiration date is an emptry string, the expiration date is interpreted
as NULL.

=back

