#!/usr/bin/env perl

use strict;
use warnings;

my $ref = \&func;
&{$ref}();

sub func {
    print "Function reference example";
}

my $ref_two = sub { print "\nI am an anoymous function!" };
$ref_two->();

# an example of closure
my $counter_one = make_counter(1);
my $counter_two = make_counter(2);

sub make_counter {
    my $count = shift || 1;

    return sub { return $count++ };
}

print $counter_one->() . "\n";
print $counter_one->() . "\n";
print $counter_one->() . "\n";

print $counter_two->() . "\n";
print $counter_two->() . "\n";
print $counter_two->() . "\n";
