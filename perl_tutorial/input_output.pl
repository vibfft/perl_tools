#!/usr/bin/env perl
# see perldoc.perl.org

use strict;
use warnings;
use IO::File;

my $input_file = "input.txt";
my $output_file = "output.txt";

# open(my $fh1, "< $input_file") or die "Cannot open file: $!";
# open(my $fh1, "> $output_file") or die "Cannot open file: $!";

# while (my $line = <$fh1>) {
#     print $fh2 $line;
# }

# close $fh1;
# close $fh2;

my $file = IO::File->new("< $input_file") or die "Cannot open file: $!";
my $file_two = IO::File->new("> $output_file") or die "Cannot open file: $!";
while ( my $line = $file->getline()) {
    $file_two->print($line);
}
$file->close();

