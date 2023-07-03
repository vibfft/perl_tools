#!/usr/bin/env perl

use strict;
use warnings;

$| = 1; # autoflush on
# -e $filename, file exists?
# -r $filename, file readable?
# -w $filename, file writable?
# -z $filename, file zero length?
# -s $filename, file none zero, empty?
# -f $filename, plain file?
# -d $filename, is it a directory?

# $!, displays error message
# $! + 0, error number
# %ENV
# print $0, prints the full path name of your script
# print $^O, operating system
# print $^V, version
# my $choice = 0 || 57, assigns 57 since 0 is false

print "$0\n";
print "$^O\n";
print "$^V\n";

print q(Hello, "World");     # single quote
print "\n";
print qq(Hello,\n "World"\n);  # double quotes

my @array = qw( this is a list of words );
foreach (@array) {
    print "$_\n";
}

print "$_ " foreach @array;

