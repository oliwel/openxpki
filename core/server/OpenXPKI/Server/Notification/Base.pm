## OpenXPKI::Server::Notification::Base
## Base class for all notification interfaces
##
## Written 2013 by Oliver Welter for the OpenXPKI project
## (C) Copyright 2013 by The OpenXPKI Project

=head1 Name

OpenXPKI::Server::Notification::SMTP - Notification via SMTP

=head1 Description

Base class for all notifications handlers.
 
=cut

package OpenXPKI::Server::Notification::Base;

use strict;
use warnings;
use English;

use DateTime;
use OpenXPKI::Server::Context qw( CTX );
use OpenXPKI::Exception;
use OpenXPKI::Debug;
use OpenXPKI::FileUtils;
use OpenXPKI::Serialization::Simple;
use OpenXPKI::Template;

use Moose;

# Attribute Setup

# The path-string for calling the connector
has 'config' => (
    is  => 'rw',
    isa => 'Str', 
);

has 'failed' => (
    is  => 'rw',
    isa => 'ArrayRef',
);

=head1 Functions

=head2 notify({ MESSAGE, VARS, TOKEN })

Public method to be called to send out a notification.
must be implemented in the parent class, expects
the name of the message and a hashref to the template vars.
TOKEN is optional and exchanges persisted information for this
handler with the workflow.
If the method returns a non-empty value, it is persisted back 
into the workflow.

=cut
sub notify {
    
    OpenXPKI::Exception->throw(
        message => 'I18N_OPENXPKI_SERVER_NOTIFICATION_BASE_NOTIFY_UNIMPLEMENTED',
        log => {
            priority => 'error',
            facility => 'system',
        },        
    );
    
}

=head2 _render_template_file( FILENAME, VARS )

Read template form filename and render using TT.
Expects full path to the template and hashref to the vars.
returns the template with vars inserted as string.

=cut
sub _render_template_file {
        
    ##! 4: 'start'
    my $self = shift;
    my $filename = shift;
    my $vars = shift;
    
    ##! 16: 'Load template: ' . $filename
    if (! -e $filename  ) {
=cut LOGMIGRATE
        CTX('log')->log(
            MESSAGE  => "Template file missing $filename  ",
            PRIORITY => "warn",
            FACILITY => "system",
        );
=cut LOGMIGRATE
        CTX('log')->system()->warn("Template file missing $filename  ");
        #LOGMIGRATE 
        return undef;
    }
    
    my $template = OpenXPKI::FileUtils->read_file( $filename );
    # Parse using TT
    my $output;
    
    my $tt = OpenXPKI::Template->new();    
    if (!$tt->process(\$template, $vars, \$output)) {
=cut LOGMIGRATE
        CTX('log')->log(
            MESSAGE  => "Error parsing templatefile ($filename): " . $tt->error(),
            PRIORITY => "error",
            FACILITY => "system",
        );
=cut LOGMIGRATE
        CTX('log')->system()->error("Error parsing templatefile ($filename): " . $tt->error());
        #LOGMIGRATE 
        return; 
    }
    
    return $output;
    
}

=head2 _render_template ( TEMPLATE, VARS )

Render a template using TT.
Expects template string and hashref to the vars.
returns the template with vars inserted as string.

=cut
sub _render_template {
        
    ##! 4: 'start'
    my $self = shift;
    my $template = shift;
    my $vars = shift;
    
    # Parse using TT
    my $output;
    
    my $tt = OpenXPKI::Template->new();        
    if (!$tt->process(\$template, $vars, \$output)) {
=cut LOGMIGRATE
        CTX('log')->log(
            MESSAGE  => "Error parsing template ($template): " . $tt->error(),
            PRIORITY => "error",
            FACILITY => "system",
        );
=cut LOGMIGRATE
        CTX('log')->system()->error("Error parsing template ($template): " . $tt->error());
        #LOGMIGRATE 
        return; 
    }
    
    return $output;
    
}


1;

__END__

 