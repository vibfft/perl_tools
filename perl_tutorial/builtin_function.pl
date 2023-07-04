#!/usr/bin/env perl

my @arry = qw( one two three four five);

print "$_\n" foreach grep  { /t/ } @arry;

my @num_array = (1, 2, 3, 4, 5);

print "$_\n" foreach map { $_ * 7 } @num_array;

print join ':', @arry;

my $unknown = 10; # define it
undef $unknown;
print "\n";
if (defined $unknown) {
    print "unknown is $unknown\n";
} else {
    print "unknown is not defined\n";
}