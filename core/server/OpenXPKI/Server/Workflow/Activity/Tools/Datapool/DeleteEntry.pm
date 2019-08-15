# OpenXPKI::Server::Workflow::Activity::Tools::Datapool::SetEntry
# Written by Scott Hardin for the OpenXPKI project 2010
# Copyright (c) 2010 by The OpenXPKI Project

package OpenXPKI::Server::Workflow::Activity::Tools::Datapool::DeleteEntry;

use strict;
use English;
use base qw( OpenXPKI::Server::Workflow::Activity );

use OpenXPKI::Server::Context qw( CTX );
use OpenXPKI::Exception;
use OpenXPKI::Debug;
use OpenXPKI::Serialization::Simple;
use OpenXPKI::DateTime;
use DateTime;
use Template;

use Data::Dumper;

sub execute {
    ##! 1: 'start'
    my $self       = shift;
    my $workflow   = shift;
    my $context    = $workflow->context();
    my $serializer = OpenXPKI::Serialization::Simple->new();
    my $params     = { PKI_REALM => CTX('api2')->get_pki_realm(), };

    CTX('api2')->delete_data_pool_entry(
        namespace => $self->param('namespace'),
        key => $self->param('key')
    );

    CTX('log')->application()->info('Remove datapool entry for key '.$self->param('key').' in namespace '.$self->param('namespace'));



    return 1;
}

1;
__END__

=head1 Name

OpenXPKI::Server::Workflow::Activity::Tools::Datapool::DeleteEntry

=head1 Description

This class deletes an entry from the Datapool, defined by namespace and key.

=head1 Configuration

=head2 Activity Paramaters

=over

=item namespace

=item key

=back
