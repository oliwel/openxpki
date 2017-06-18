# OpenXPKI::Server::Workflow::Condition::ValidCSRSerialPresent.pm
# Written by Alexander Klink for the OpenXPKI project 2006
# Copyright (c) 2006 by The OpenXPKI Project
package OpenXPKI::Server::Workflow::Condition::ValidCSRSerialPresent;

use strict;
use warnings;
use base qw( Workflow::Condition );
use Workflow::Exception qw( condition_error configuration_error );
use OpenXPKI::Server::Context qw( CTX );
use OpenXPKI::Debug;
use English;

use Data::Dumper;

sub evaluate {
    ##! 16: 'start'
    my ( $self, $workflow ) = @_;
    my $context  = $workflow->context();
    ##! 64: 'context: ' . Dumper($context)
    my $csr_serial = $context->param('csr_serial');

    if (not defined $csr_serial) {
        condition_error('I18N_OPENXPKI_SERVER_WORKFLOW_CONDITION_VALIDCSRSERIALPRESENT_NO_CSR_SERIAL_PRESENT');
    }

=cut LOGMIGRATE
    CTX('log')->log(
        MESSAGE => "Testing for CSR serial $csr_serial",
        PRIORITY => 'debug',
        FACILITY => [ 'application' ],
    );
=cut LOGMIGRATE
    CTX('log')->application()->debug("Testing for CSR serial $csr_serial");
    #LOGMIGRATE 

    CTX('dbi')->select_one(
        from => 'csr',
        columns => ['req_key'],
        where => { req_key => $csr_serial },
    )
    or condition_error('I18N_OPENXPKI_SERVER_WORKFLOW_CONDITION_VALIDCSRSERIALPRESENT_CSR_SERIAL_FROM_CONTEXT_NOT_IN_DATABASE');

   return 1;
    ##! 16: 'end'
}

1;

__END__

=head1 NAME

OpenXPKI::Server::Workflow::Condition::ValidCSRSerialPresent

=head1 SYNOPSIS

<action name="do_something">
  <condition name="valid_csr_serial_present">
             class="OpenXPKI::Server::Workflow::Condition::ValidCSRSerialPresent">
  </condition>
</action>

=head1 DESCRIPTION

This condition checks whether a valid CSR serial is present in the
workflow context param 'csr_serial'.
