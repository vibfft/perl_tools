#!/usr/bin/env perl

my @arry = qw( one two three four five );

my $ref = \@arry;
# square brackets are anonymous array and it creats scalar not array
# parens are literal array/list
print "$_\n" foreach @{$ref};

my $ref_two = [ qw( one two three four five six ) ];
print "$_\n" foreach @{$ref_two};

my $ref_three = [ 1, 2, 3, 4, 5 ];  # square brackets create scalar
$ref_three->[2] = "three";
print "$_\n" foreach @{$ref_three};

my @arry_two = ( 1, 2, 3, 4 );
my $ref_four = \@arry_two;
$ref_four->[3] = "four";
print "$_\n" foreach @{$ref_four};