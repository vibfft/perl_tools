#!/usr/bin/env perl

# if you are using "state" variable before perl 5.16
# use feature 'state'

#func(), two parens are function call operator

use strict;
use warnings;

func('Fred', 'Barney', 'Wilma', 'Betty');

sub func {
    print "$_\n" foreach @_;
}

use subs qw( func ); # to do away with function call operator i.e. ()

func 'foo', 'bar', 'baz';

sub func {
    print "$_\n" foreach @_;
}
