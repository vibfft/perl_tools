 #!/usr/bin/env perl

 # /pattern/modifiers, use forward slash when there is no preceding "m"
 # m|pattern|modifiers, when you have "m" prefix, you don't need to use "/" all the time
 # s|pattern|replacement|modifiers, search and replace
 # qr/pattern/modifiers, pre-compile when using the pattern repeatedly
 # $var =~ m/pattern/modifiers;               returns scalar
 # $var =~ s/pattern/replacement/modifiers;   returns scalar
 # $var !~ m/pattern/modifiers;               returns scalar
 # @arry = $var =~ m/pattern/modifiers;       returns array
 # 
 # period   (.) matches any single character
 # asterisk (*) matches zero or more characters, /wa*sh/ matches 'wsh'
 # plus     (+) matches one or more characters,  /wa+sh/ does not match 'wsh'

use strict;
use warnings;

my $s = "This is a Line of text";

# scalar context
my $re = qr/line/i;
print $s =~ $re ? 'True':'False';
print "\n";

# list context
print "\nWith no modifiers\n";
my $re_i = qr/i/;
print "$_\n" foreach $s =~ /i/;
print $s =~ $re_i ? 'True':'False';

print "\n\nUsage of global modifier\n";
my $re_g = qr/i/;
print "$_\n" foreach $s =~ /i/g;
print $s =~ $re_g ? 'True':'False';

# s modifier treats the string as a single line
print "\n\nUsage of 's' modifier\n";
my $str_two = "This is a line of text\nmore text\nmore text\n";
#                                   match      match
my $re_s = qr/t.m/s;
print "$_\n" foreach $str_two =~ /t.m/sg;
print $str_two =~ $re_s ? 'True':'False';

# m modifier allows for a multiple line match
print "\n\nUsage of 'm' modifier\n";
$str_two = "This is a line of text\nmore text\nmore text\n";
#                                   match      match
my $re_m = qr/^m/m;
print "$_\n" foreach $str_two =~ /^m/mg;
print $str_two =~ $re_m ? 'True':'False';

# extracting matches
my $str_three = "This is a line of text";
#                1st       2nd  3rd
if ( $str_three =~ /(..is).*(..ne).(..)/ ) {
    print "\n\n";
    print "1st match: $1\n";
    print "2nd match: $2\n";
    print "3rd match: $3\n";
} else {
    print "There was no match";
}

# getting list of matches
print "\n\nGetting a list of matches\n";
my @arry = $str_three =~ /i(.)/g;
print "$_\n" foreach @arry;

# $s =~ /a{3,}/ at least match 3 'a'

# greedy example
print "\n\nGreedy example\n";
print $str_three =~ /(lin.*e)/;

print "\n\nNon-Greedy example\n";
print $str_three =~ /(lin.*?e)/;

# '\s' matches white spaces, '\S' matches non-white spaces
print "\n\nUsage of '\S':\n";
my @arry_one = $str_three =~ /(\S+)/g;
print "$_\n" foreach @arry_one;

print "\n\nUsage of '\S' without parenthesis:\n";
my @arry_one = $str_three =~ /\S+/g;
print "$_\n" foreach @arry_one;

# special characters to escape for regex
# { } [ ] ( ) ^ $ . | * + ? \

print "\n\nSplit a string:\n";
print "$_\n" foreach split(/\s+/, $str_three);