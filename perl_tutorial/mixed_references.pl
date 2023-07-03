#!/usr/bin/env perl

use strict;
use warnings;

my $musicians = []; # anonymous array

push @{$musicians}, { name => 'Jimi Hendrix', instrument => 'Guitar', genre => 'Rock' };
push @{$musicians}, { name => 'Miles Davis', instrument => 'Trumpet', genre => 'Jazz' };
push @{$musicians}, { name => 'Yo-Yo Ma', instrument => 'Cello', genre => 'Classical' };
push @{$musicians}, { name => 'Elton John', instrument => [ 'Piano', 'Vocal' ], genre => 'Rock' };

foreach my $m ( @{$musicians} ) {
    my $inst = ref($m->{instrument}) eq 'ARRAY' ? join('/', @{$m->{instrument}}) : $m->{instrument};
    print "$m->{name}: $inst, $m->{genre}\n";
}
