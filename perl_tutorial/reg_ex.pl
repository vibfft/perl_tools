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
my $re_s = qr/t.m/s;
print "$_\n" foreach $str_two =~ /t.m/sg;
print $str_two =~ $re_s ? 'True':'False';

# m modifier allows for a multiple line match
print "\n\nUsage of 'm' modifier\n";
my $str_two = "This is a line of text\nmore text\nmore text\n";
my $re_m = qr/^m/m;
print "$_\n" foreach $str_two =~ /^m/mg;
print $str_two =~ $re_m ? 'True':'False';