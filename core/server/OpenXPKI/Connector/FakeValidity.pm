package OpenXPKI::Connector::FakeValidity;

use strict;
use warnings;
use English;
use Moose;
use DateTime;
use OpenXPKI::DateTime;
use OpenXPKI::Server::Context qw( CTX );

extends 'Connector';

has cut_wday => (
    is  => 'ro',
    isa => 'Str',
    default => 6,
    );
    
has cut_time => (
    is  => 'ro',
    isa => 'Str',    
    default => '17:00',
    );

sub get {
    my $self = shift;
    my $arg = shift;
    
    my $notafter = OpenXPKI::DateTime::get_validity({
        VALIDITY_FORMAT => 'detect',
        VALIDITY        => '+0006',# $self->LOCATION(),
    });
    
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime( $notafter->epoch() );          
    
    my $cut_wday = $self->cut_wday();
    my @cut_time = split /:/, $self->cut_time();
    
    # Jump a full week if its saturday but beyond the limit  
    $mday += 7 if ($wday == $cut_wday && $hour >= $cut_time[0] && $min > $cut_time[1]);
    
    my $diff_day = ($cut_wday - $wday);
    if ($diff_day < 0) { $diff_day+=7; }
    $mday += $diff_day;
    
    my $validity = DateTime->new( 
        year      => $year+1900,
        month     => $mon+1,
        day       => $mday,
        hour      => $cut_time[0],
        minute    => $cut_time[1],
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

=head1 NAME

OpenXPKI::Connector::FakeValidity;

=head1 DESCRIPTION

Connector to align a validity time spec to a fixed point in the week.

=head2 Configuration

=item cut_wday

The day of week as used by perl localtime, default is 6 (Saturday).
Note that Sunday is 0!

=item cut_time

The time of the day, given as hh:mm, default is 17:00.