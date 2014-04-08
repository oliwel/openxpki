package OpenXPKI::Connector::FakeValidity;

use strict;
use warnings;
use English;
use Moose;
use DateTime;
use OpenXPKI::DateTime;
use OpenXPKI::Server::Context qw( CTX );

extends 'Connector';

sub get {
    my $self = shift;
    my $arg = shift;
    
    my $notafter = OpenXPKI::DateTime::get_validity({
        VALIDITY_FORMAT => 'detect',
        VALIDITY        => $self->LOCATION(),
    });
    
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime( $notafter->epoch() );          
    
    # Jump a full week if its saturday but beyond the limit  
    $wday = -1 if ($wday == 6 && $hour >= 17);    
    $mday += (6 - $wday);
    
    my $validity = DateTime->new( 
        year      => $year+1900,
        month     => $mon,
        day       => $mday,
        hour      => $isdst ? '15' : '16',
        minute    => 0,
        second    => 0,
    );

    CTX('log')->log(
       MESSAGE => "certificate validity adjusted from ". $notafter ." to ". $validity,
       PRIORITY => 'debug',
       FACILITY => [ 'application', ],
    );
    
    return $validity->strftime("%Y%m%d%H%M%S");
}

sub get_meta {
    
    my $self = shift;
    return {TYPE  => "scalar" };    
}   

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

