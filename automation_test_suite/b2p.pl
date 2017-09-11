#!/usr/bin/env perl
#
#Copyright (c) 2009, Perforce Software, Inc.  All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1.  Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# 
# 2.  Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL PERFORCE SOFTWARE, INC. BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#*******************************************************************************
#
#Author: Stephen Moon
#Date: 4/7/2011
#Last Modified Date: 4/15/2011
#Summary: This generates a perl script for a plain text
#         input file
#
#         Run the program without any argument
#         and it will display help for usage and how
#         to format the input file.
#*******************************************************************************

use strict;
use warnings;
use FileHandle;
use Fatal qw/ open close /;

#############################################################
##### main() starts here ####################################
sub main() {

  my $argc = @ARGV;
  my ($echo_str,$cmd_str,$touch_str) = ("","","");
  
  if($argc < 1 || $argc > 2) { 
  
    &mainHelp();  
    exit 1;
  
  } elsif($argc == 2) {

    if($ARGV[1] eq "g") {

      &generatedScript();
    } elsif($ARGV[1] eq "o") {

      &outputFromScript();
    } elsif($ARGV[1] eq "i") {
     
      &generateInputFile();
    } else {

      print "Invalid option\n";
    }

    exit 1;
  }
  
  my $batchFile = $ARGV[0];
  my $perlOutFile = "$ARGV[0].pl";
  open(IN,$batchFile);
  
  my $fh = new FileHandle;
  
  $fh->open("> $perlOutFile");
  
  my $log = "$ARGV[0].log";

  &header($fh,$perlOutFile);  
  

  if($^O =~ /MSWin32/) {
    print $fh "system(\'cls\');";
  } else {
    print $fh "system(\'clear\');";
  }

  print $fh "\n&addDiagnostics(\"$log\");\n";

  while(<IN>) {
  
    if(/(^echo\s.*$)/) {
  
      $echo_str = $1;
      chomp($echo_str);
  
      print $fh "&cmdExecuted(\'$echo_str\',\"$log\");\n";
      print $fh "\`$echo_str\`;\n";
      print $fh "&writeBlankLine(\"$log\");\n";
  
    } elsif(/(^touch\s.*$)/) {
  
      $touch_str = $1;
      chomp($touch_str);
  
      print $fh "&cmdExecuted(\'$touch_str\',\"$log\");\n";
      print $fh "\`$touch_str\`;\n";
      print $fh "&writeBlankLine(\"$log\");\n";
  
    } elsif(/(^p4.*\s.*$)/) {
  
      $cmd_str = $1;
      chomp($cmd_str);
  
      print $fh "&cmdExecuted(\'$cmd_str\',\"$log\");\n";
      print $fh "\`$cmd_str >> $log 2>&1\`;\n";
      print $fh "&writeBlankLine(\"$log\");\n";
  
    } elsif(/(^mkdir\s.*$)/) {
  
      $cmd_str = $1;
      chomp($cmd_str);
  
      print $fh "&cmdExecuted(\'$cmd_str\',\"$log\");\n";
      print $fh "\`$cmd_str >> $log 2>&1\`;\n";
      print $fh "&writeBlankLine(\"$log\");\n";
  
    } elsif(/(^python\s.*$)/) {
  
      $cmd_str = $1;
      chomp($cmd_str);
  
      print $fh "&cmdExecuted(\'$cmd_str\',\"$log\");\n";
      print $fh "\`$cmd_str >> $log 2>&1\`;\n";
      print $fh "&writeBlankLine(\"$log\");\n";
  
    } elsif(/(^perl\s.*$)/) {
  
      $cmd_str = $1;
      chomp($cmd_str);
  
      print $fh "&cmdExecuted(\'$cmd_str\',\"$log\");\n";
      print $fh "\`$cmd_str >> $log 2>&1\`;\n";
      print $fh "&writeBlankLine(\"$log\");\n";
  
    } else {
  
      print $fh $_;
  
    }
  }
  
  if( -f $log) {
    unlink $log;
  }
 
  &whileLoop($fh,$log); 
  &addDiagnostics($fh,$log);
  &blankPrint($fh); 
  &cmdExecute($fh); 

  close(IN);
  close($fh);

$| = 1;
system("perl $perlOutFile");

}
##### main() ends here ######################################
#############################################################

sub addDiagnostics {

my $fh = shift;
my $log = shift;

print $fh <<DIAG;

sub addDiagnostics {

  my \$log = shift;

  &writeBlankLine(\"$log\");
  open(LOG,\">>\$log\");
  #print LOG grep(/^Rev./,`p4d -V`);
  print LOG grep(/^Rev./,`p4 -V`);
  &writeBlankLine(\"$log\");

  open(LOG,\">>\$log\");
  print LOG `p4 info`; 
  &writeBlankLine(\"$log\");

}

DIAG

}

sub whileLoop {

my $fh = shift;
my $log = shift;

print $fh <<WLOOP;
  
open(LOG,\"$log\");
  
while(<LOG>) {
  print;
}
close(LOG);
  
WLOOP

}
  

sub blankPrint {

my $fh = shift;

print $fh <<'BLANK';
sub writeBlankLine {
  
  my $log = shift;
  
  open(LOG,">>$log");
  print LOG "\n";
  
  close(LOG);
  
}
  
BLANK

}

sub cmdExecute {

my $fh = shift;

print $fh <<'CMD';
sub cmdExecuted {
    
  my $str = shift; 
  my $log = shift;
 
  open(LOG,">>$log");
  
  print LOG "CMD: $str\n";
  
  close(LOG);
}
  
CMD

}
  
sub header {

my $fh = shift;
my $perlOutFile = shift;

print $fh <<HEADER;
#!/usr/bin/env perl
#
#Name of file: $perlOutFile

use strict;
use warnings;  
use Fatal qw/ open /;
HEADER

}

#############################################################
##### Help subroutines start here ###########################

sub mainHelp {

    print <<'HELP';
  
    =================================================================
    Usage: b2p.pl 1_tc.txt [g | o | i]

    g: generated script
    o: output from generated script
    i: creates a sample input file 
 
    *Please note that the integer prefix of the input filename will
     be incremented whenever you run "clean.up". 

    *Use a dummy file name to display additional help or to create
     an input file.
    =================================================================
    Typical content of an input file (Windows*):
 
    mkdir main 
    echo "add file" > main\\a
    p4 add main\\a
    p4 submit -d "a added"
    p4 edit -t ctext main\\a
    p4 integ -o main\\a rel\\e
    p4 submit -d "integ from a to b"

    *On Unix/Linux platforms, you do not need to escape "\" 
  
    =================================================================
    Currently, only three commands are
    supported:
  
    i.e.  "echo", "mkdir", "p4*"
 
    Might be adding more constructs
    in future
  
HELP

}

sub generateInputFile {

open(IN,"> 1_tc.txt");

print IN <<'SAMPLE';
mkdir main 
echo "add file" > main/a
p4 add main/a
p4 submit -d "a added"
p4 edit -t ctext main/a
p4 integ -o main/a rel/e
p4 submit -d "integ from a to b"

SAMPLE

close(IN);

}

sub generatedScript {

print <<'HELP1';

  =================================================================
  Typical look of the generated perl script:

  #!/usr/bin/env perl
  #
  #Name of file: b1.pl
  
  use Fatal qw/ open /;
  
  system('cls')
  &cmdExecuted('echo "add file" > a',"b1.log");
  system('echo "add file" > a');
  &writeBlankLine("b1.log");
  &cmdExecuted('p4 add a',"b1.log");
  `p4 add a >> b1.log 2>&1`;
  &writeBlankLine("b1.log");
  &cmdExecuted('p4 submit -d "a added"',"b1.log");
  `p4 submit -d "a added" >> b1.log 2>&1`;
  &writeBlankLine("b1.log");
  &cmdExecuted('p4 edit -t ctext a',"b1.log");
  `p4 edit -t ctext a >> b1.log 2>&1`;
  &writeBlankLine("b1.log");
  &cmdExecuted('p4 integ -o a b',"b1.log");
  `p4 integ -o a b >> b1.log 2>&1`;
  &writeBlankLine("b1.log");
  &cmdExecuted('p4 submit -d "integ from a to b"',"b1.log");
  `p4 submit -d "integ from a to b" >> b1.log 2>&1`;
  &writeBlankLine("b1.log");
  
  open(LOG,"b1.log");
  
  while(<LOG>) {
    print;
  }
  close(LOG);
  
  sub writeBlankLine {
  
    my $log = shift;
  
    open(LOG,">>$log");
    print LOG "\n";
  
    close(LOG);

  }
  
  sub cmdExecuted {
  
    my $str = shift;
    my $log = shift;
  
    open(LOG,">>$log");
 
    print LOG "CMD: $str\n";
  
    close(LOG);
  }

HELP1

}

sub outputFromScript { 
  
print <<'HELP2';

  =================================================================
  Typical look of the output when the auto-generated script is run:

  CMD: echo "add file" > a

  CMD: p4 add a
  //depot/tc1/bat/a#1 - opened for add

  CMD: p4 submit -d "a added"
  Submitting change 2988.
  Locking 1 files ...
  add //depot/tc1/bat/a#1
  Change 2988 submitted.

  CMD: p4 edit -t ctext a
  //depot/tc1/bat/a#1 - opened for edit

  CMD: p4 integ -o a b
  //depot/tc1/bat/b#1 - branch/sync from //depot/tc1/bat/a#1

  CMD: p4 submit -d "integ from a to b"
  Submitting change 2989.
  Locking 2 files ...
  edit //depot/tc1/bat/a#2
  branch //depot/tc1/bat/b#1
  Change 2989 submitted.

HELP2

}

&main();
