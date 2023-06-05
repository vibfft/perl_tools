#!/usr/bin/env perl

use strict;
use warnings;

sub main() {

    my @inputArray = ("i want to say GoodBye to you all\n", 
                    "you want to say goodBye ?\n", 
                    "yes i do want to say goodBye\n", 
                    "Quit\n");
    
    my @array;

    print("Enter 'goodbye' for each line\nType 'q/quit' when done\n");
    # while (my $line = <STDIN>) {
    #     chomp $line;  # Remove newline character
    #     if ($line =~ /(q|quit)/i) {
    #         print("Bye for now!!!");
    #         last;
    #     } else {
    #         push(@array, $line)
    #     }
    # }
    foreach my $line (@inputArray) {
        
        chomp $line;
        if ($line =~ /(q|quit)/i) {
            print("Bye for now!!!");
            last;
        } else {
            push(@array, $line)
        }
        
    }

    print("\nConvert each instance of goodbye to hello for the given line!\n");
    foreach(@array) {
        if ($_ =~ s/goodbye/hello/i) {
            print("$_\n");
        }
    }
}

&main()