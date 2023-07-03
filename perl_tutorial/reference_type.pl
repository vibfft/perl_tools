#!/usr/bin/env perl

use strict;
use warnings;

my $ref_one = [ 1, 2, 3, 4 ];
my $ref_two = { one => 1, two => 2, three => 3, four => 4 };

sub show_ref {
    my $r = shift || '';
    
    if (ref($r) eq 'ARRAY') {
        print "$r is an array\n";
    } elsif (ref($r) eq 'HASH') {
        print "$r is a hash\n";
    }
}

show_ref($ref_one);
show_ref($ref_two);