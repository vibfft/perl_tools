#!/usr/bin/env perl 

###############################################################################
#Author: Stephen Moon
#Date: Jan. 26, 2011
#Last Modified Date: Jan. 28, 2011
#Program Summary:
#This is a performance test suite for Windows as well as Non-Windows
#Environment.  You will not need the metadata to run this test
#because the metadata is self-generated.
#
#Requirement: P4Perl needs to be installed beforehand.
#
#The program was updated to accept the inputs from the command line
#instead of hard-coding it in the program
#
#The program either can "run" or "clean".
#
#When it runs, it requires five arguments:
#
# run, <user>, <port>, <number of threads>, <number of loops executed by each
# thread>
#
# e.g.: perf_test.pl run smoon 20102 100 100
#
#When the program cleans, it requires three arguments
#
# clean, <user>, <port>
#
# e.g.: perf_test.pl clean smoon 20102 
#
#Please do not run the program where you have P4CONFIG file
#in the directory pointing at server.perforce.com:1666
#Try to disable P4CONFIG file before running the tool against
#the local server for the test.
#
#In future, I will try to make the program to work with the existing
#metadata or incorporate some kind of repetitive testing scheme.
#
#Let me know if you have any ideas to improve the tool.
###############################################################################

use warnings;
use strict;
use diagnostics;
use threads;
use threads::shared;
use FileHandle;
use Getopt::Long;
use Data::Dumper;
use File::Path;
use Cwd;
use Fatal qw/ mkdir open chdir /;
use P4;

my ($error_log, $lockstat_log) = ("error_log.txt","lockstat_log.txt");

###############################################################################
sub main() {

  #Command line parameter check
  my $argc = @ARGV;
  
  if($argc < 1) {
  
    &getHelp(); exit(1);
  
  } elsif($ARGV[0] eq "clean") {
  
    if($argc != 3) { &getHelp(); exit(1); }
  
  } elsif($ARGV[0] eq "run") {
  
    if($argc != 5) { &getHelp(); exit(1); }
  
  } else {
  
    &getHelp(); exit(1);
  
  }
  
  #SSL Check
  my @ports = split(/:/,$ARGV[2]);
  
  foreach(@ports) {
  
    if($ports[0] =~ /ssl.*/) {
      open my $h,"|p4 -p $ARGV[2] trust -f";
      print $h "yes\n";
      close $h;
  
      last;
  
    } else {
      print "This is not an SSL server\n";
    }
  }
  
  my $subDepot = "stress";
  
  my ($user,$port,$thread_nums,$loop_nums) = 
     ($ARGV[1],$ARGV[2],0,0);
  
  my $home = &getCwdPath($user);
  
  if($ARGV[3]) { #if "run" is entered 
    $thread_nums = $ARGV[3];
  }
  
  if($ARGV[4]) { #if "run" is entered
    $loop_nums = $ARGV[4];
  }
  
  if($ARGV[0] eq "clean") {
  
    my $p4 = "p4 -p $port -u $user";
  
    &delDirs($home);
    &delClients($p4);
    &obliterate($p4,$subDepot); 
  
  } elsif($ARGV[0] eq "run") {
  
    if( -f $error_log) {
      unlink $error_log;
    } 
  
    &createClient($thread_nums,$home,$user,$port,$subDepot);
  
    my @threads;
    for ( my $count = 0; $count < $thread_nums; $count++) {
      my $t = threads->new(\&createThread, $count, $user, $port, $home, $subDepot, $loop_nums);
      push(@threads,$t);
    }
  
    foreach (@threads) {
      my $num = $_->join;
      print "done with $num\n";
    }

    print "End of main program\n";
  
  } else {
  
    print "\n\nYou have entered invalid input(s)\n";
    &getHelp();
    exit(1);
  }

} #end of main

###############################################################################
sub getHelp() {

  my @argArry = qw/ run clean user port threads_num loop_nums /;

  print "\nUsage: " . $0 . " " . $argArry[0] . " <user> <port> ";
  print "<thread_nums> <loop_nums> | " . $argArry[1] . " <user> <port>\n"; 
  printf("\t%12s: Runs the test\n",$argArry[0]); 
  printf("\t%12s: Cleans the generated output\n",$argArry[1]); 
  printf("\t%12s: Perforce username\n",$argArry[2]); 
  printf("\t%12s: Perforce server host and/or port number\n",$argArry[3]); 
  printf("\t%12s: Number of Perforce client threads you want to create\n",$argArry[4]); 
  printf("\t%12s: Number of loops for each client thread\n\n",$argArry[5]); 

}

###############################################################################
sub getCwdPath {

  my $user = shift;
  my $home;

  if($^O =~ /MSWin32/) {
    print "currentDir: " . getcwd() . "\n";
    if(! -d getcwd() . "\\" . $user . "_ws\\") {
      mkdir(getcwd() . "\\" . $user . "_ws\\"); 
    }
    $home = getcwd() . "\\" . $user . "_ws\\";
  
  } else {
    print "currentDir: " . getcwd() . "\n";
    if(! -d getcwd() . "/" . $user . "_ws/") {
      mkdir(getcwd() . "/" . $user . "_ws/");
    }
    $home = getcwd() . "/" . $user . "_ws/";
  }
  
  return $home;

} #end of getHomePath

###############################################################################
sub createClient {

  my $p4 = new P4;
  my $thread_nums = shift;
  my $home = shift;
  my $user = shift;
  my $port = shift;
  my $subDepot = shift;
  my $client;
 
  $| = 1;

  for(0..$thread_nums) {
  
    $p4->SetClient("client" . $_);
    $p4->SetUser($user);
    $p4->SetPort($port);
    $p4->Connect() or die("Was not able to connect\n");
  
    if(! -d $home . $_) {
      mkdir($home . $_);
    }
  
    sleep 1;
  
    $client = $p4->Run('client','-o');
  
    $client->[0]->{'Client'} = "client" . $_;
    $client->[0]->{'Root'} = $home . $_;
    $client->[0]->{'View'} = ["//depot/$subDepot/... //client$_/..."];
 
    sleep 1; 
    $p4->SaveClient($client); 
  
    $p4->Disconnect();
  
  }

} #end of createClient


###############################################################################
sub createThread {

  my $p4 = new P4;
  my $num = shift;
  my $user = shift;
  my $port = shift;
  my $home = shift;
  my $subDepot = shift;
  my $loop_nums = shift;

  my ($lock, $lockc, $lockC) = ("","","");
 
  #open(OUT,">$lock_state");
  #$| = 1; 
  $p4->SetClient("client" . $num);
  $p4->SetUser($user);
  $p4->SetPort($port);
  $p4->Connect() or die("Was not able to connect\n");
  
  if($^O =~ /MSWin32/) {
    print "PATH: $home" . "$num\\$num.txt\n";
    &createFile("win",0,$home,$num,"create");
  
  } else {
    &createFile("nonwin",0,$home,$num,"create");
  }
  
  $p4->Run("add","-t","ktext","//depot/$subDepot/$num.txt");
  &errorPrint($p4->Errors(),"add");
  
  $p4->Run("submit","-d","$num added");
  &errorPrint($p4->Errors(),"submit");
  
  my $i = 0;
  
  while($loop_nums > 0) {
  
    $i++;
    print "$loop_nums\n";
  
    $p4->Run("sync","//depot/$subDepot/...");
    &errorPrint($p4->Errors(),"sync \@run=$i");
    
    $lock = $p4->Run("lockstat");
    &errorPrint($p4->Errors(),"lockstat \@run=$i");
    $lockC = $p4->Run("lockstat","-C");
    &errorPrint($p4->Errors(),"lockstat -C \@run=$i");
    $lockc = $p4->Run("lockstat","-c client$i");
    &errorPrint($p4->Errors(),"lockstat -c client$i \@run=$i");

    &lockStat($lock,$lockC,$lockc,$i);
 
    $p4->Run("print","//depot/$subDepot/...");
    &errorPrint($p4->Errors(),"print \@run=$i");
  
    $p4->Run("grep","-e","XX","//depot/$subDepot/...");
    &errorPrint($p4->Errors(),"grep \@run=$i");
  
    $p4->Run("grep","-e","XX","//...");
    &errorPrint($p4->Errors(),"grep \@run=$i");
  
    if($i % 2) {
      $p4->Run("edit","-t","ctext","//depot/$subDepot/$num.txt");
      &errorPrint($p4->Errors(),"edit ctext \@run=$i");
  
    } else {
      $p4->Run("edit","-t","ktext","//depot/$subDepot/$num.txt");
      &errorPrint($p4->Errors(),"edit ktext \@run=$i");
    }
  
    &errorPrint($p4->Errors(),"resolve -at \@run=$i");

    &lockStat($lock,$lockC,$lockc,$i);
  
    $p4->Run("submit","-d","$num added \@run=$i");
    &errorPrint($p4->Errors(),"submit \@run=$i");
 

    if($i % 2) { 
      $p4->Run("integ","-o","//depot/$subDepot/$num.txt","//depot/$subDepot/a$num/$num.txt");
      &errorPrint($p4->Errors(),"integ \@run=$i");

      &lockStat($lock,$lockC,$lockc,$i);
  
      $p4->Run("resolve","-at");
      &errorPrint($p4->Errors(),"resolve -at \@run=$i");
    } else {
      $p4->Run("copy","//depot/$subDepot/$num.txt","//depot/$subDepot/a$num/$num.txt");
      &errorPrint($p4->Errors(),"copy \@run=$i");

      &lockStat($lock,$lockC,$lockc,$i);
  
      $p4->Run("resolve","-at");
      &errorPrint($p4->Errors(),"resolve -at \@run=$i");
    }

  
    $p4->Run("submit","-d","$num added \@run=$i");
    &errorPrint($p4->Errors(),"submit \@run=$i");
  
    $p4->Run("edit","-t","kxtext","//depot/$subDepot/$num.txt"); 
    &errorPrint($p4->Errors(),"edit kxtext \@run=$i");

    $p4->Run("move","//depot/$subDepot/$num.txt","//depot/$subDepot/m$num.txt"); 
    &errorPrint($p4->Errors(),"move $num.txt to m$num.txt \@run=$i");

    $p4->Run("submit","-d","$num moved to m$num \@run=$i");
    &errorPrint($p4->Errors(),"submit \@run=$i");

    if($i % 2) { 
      $p4->Run("copy","//depot/$subDepot/m$num.txt","//depot/$subDepot/a$num/$num.txt");
      &errorPrint($p4->Errors(),"copy \@run=$i");

      &lockStat($lock,$lockC,$lockc,$i);
  
      $p4->Run("resolve","-ay");
      &errorPrint($p4->Errors(),"resolve -ay \@run=$i");
    } else {
      $p4->Run("merge","//depot/$subDepot/m$num.txt","//depot/$subDepot/a$num/$num.txt");
      &errorPrint($p4->Errors(),"merge \@run=$i");

      &lockStat($lock,$lockC,$lockc,$i);
  
      $p4->Run("resolve","-ay");
      &errorPrint($p4->Errors(),"resolve -ay \@run=$i");
    }
    $p4->Run("submit","-d","$num added \@run=$i");
    &errorPrint($p4->Errors(),"submit \@run=$i");

    $p4->Run("edit","-t","ktext","//depot/$subDepot/m$num.txt"); 
    &errorPrint($p4->Errors(),"edit ktext \@run=$i");

    $p4->Run("move","//depot/$subDepot/m$num.txt","//depot/$subDepot/$num.txt"); 
    &errorPrint($p4->Errors(),"move m$num.txt to $num.txt \@run=$i");

    $p4->Run("submit","-d","m$num moved to $num \@run=$i");
    &errorPrint($p4->Errors(),"submit \@run=$i");


    if($i % 2) { 
      $p4->Run("copy","//depot/$subDepot/$num.txt","//depot/$subDepot/a$num/$num.txt");
      &errorPrint($p4->Errors(),"copy \@run=$i");

      &lockStat($lock,$lockC,$lockc,$i);
  
      $p4->Run("resolve","-at");
      &errorPrint($p4->Errors(),"resolve -at \@run=$i");
    } else {
      $p4->Run("merge","//depot/$subDepot/$num.txt","//depot/$subDepot/a$num/$num.txt");
      &errorPrint($p4->Errors(),"merge \@run=$i");

      &lockStat($lock,$lockC,$lockc,$i);
  
      $p4->Run("resolve","-at");
      &errorPrint($p4->Errors(),"resolve -at \@run=$i");
    }
    $p4->Run("submit","-d","$num added \@run=$i");
    &errorPrint($p4->Errors(),"submit \@run=$i");

    $loop_nums--;
  
    print "Loop number for Thread $num: $i\n";
  }

  #needs to comment this out since job058934 is not fixed in 12.2
  #$p4->Run("verify","-q","//...");
 
  $p4->Disconnect();
  
  $p4 = undef; 
  
  return $num;

} #end of createThread

sub lockStat() {

  my $lock = shift;
  my $lockC = shift;
  my $lockc = shift;
  my $i = shift;

  $| = 1; #flush the print statement 

  open(LOCK_OUT,">>$lockstat_log");

  print LOCK_OUT scalar(localtime());
  print LOCK_OUT "BEGIN LOCKSTAT after copy: run=$i ";
  print LOCK_OUT Dumper($lock);
  print LOCK_OUT scalar(localtime());
  print LOCK_OUT "END LOCKSTAT after copy: run=$i\n";

  print LOCK_OUT scalar(localtime());
  print LOCK_OUT "BEGIN LOCKSTAT C after copy: run=$i ";
  print LOCK_OUT Dumper($lockC);
  print LOCK_OUT scalar(localtime());
  print LOCK_OUT "END LOCKSTAT C after copy: run=$i\n";

  print LOCK_OUT scalar(localtime());
  print LOCK_OUT "BEGIN LOCKSTAT -c client$i after copy: run=$i ";
  print LOCK_OUT Dumper($lockc);
  print LOCK_OUT scalar(localtime());
  print LOCK_OUT "END LOCKSTAT -c client$i after copy: run=$i\n";
  
  close(LOCK_OUT);

}

###############################################################################
sub createFile() {

  my $fh = new FileHandle;
  my $OS = shift;
  my $i = shift;
  my $home = shift;
  my $num = shift;
  my $mode = shift;

  if($mode eq "create") {
    if($OS eq "nonwin") {
      $fh->open(">$home" . "$num/$num.txt");

    } elsif($OS eq "win") {
      $fh->open(">$home" . "$num\\$num.txt");

    }
  } elsif($mode eq "append") {
    if($OS eq "nonwin") {
      $fh->open(">>$home" . "$num/$num.txt");

    } elsif($OS eq "win") {
      $fh->open(">>$home" . "$num\\$num.txt");

    }
  }

  $| = 1; #flush the print statement 

  print $fh "The first string of the file $i.txt\n";
  print $fh '$File: //depot/dev/smoon/performance/perf_test.pl $' . "\n";
  print $fh 'File ID: $Id: //depot/dev/smoon/performance/perf_test.pl#26 $' . "\n";
  print $fh 'File Header: $Header: //depot/dev/smoon/performance/perf_test.pl#26 $' . "\n";
  print $fh 'File Author: $Author: smoon $' . "\n";
  print $fh 'File Date: $Date: 2013/07/10 $' . "\n";
  print $fh 'File DateTime: $DateTime: 2013/07/10 14:29:04 $' . "\n";
  print $fh 'File Change: $Change: 669494 $' . "\n";
  print $fh 'File File: $File: //depot/dev/smoon/performance/perf_test.pl $' . "\n";
  print $fh 'File Revision: $Revision: #26 $' . "\n";
  print $fh "This is a test for $num/$num.txt\n";

  $fh->close();
}

###############################################################################
sub errorPrint() {

  my @error = shift;
  my $op = shift;

  open(ERROR_OUT,">>$error_log");

  if(!@error) {

    print ERROR_OUT scalar(localtime());
    print ERROR_OUT Dumper(@error);
  } else {
  
    if(!defined($op)) {
      print ERROR_OUT scalar(localtime());
      print ERROR_OUT Dumper(@error);
    } else {
      print ERROR_OUT scalar(localtime())." $op\n";
      print ERROR_OUT Dumper(@error);
    }
  }

  close(ERROR_OUT);

} #end of errorPrint

###############################################################################
sub obliterate() {

  my $filename = "";
  my @oblit = ();
  my $p4 = shift;
  my $subDepot = shift;

  `$p4 obliterate -y //depot/$subDepot/...`;

} #end of obliterate

###############################################################################
sub delDirs() {

  my $home = shift;
  
  chdir($home);
  my @files = <*>;
  foreach(@files) {
    if(/^\d+$/) {
      rmtree($_);
    }
  } 
} #end of delDirs

###############################################################################
sub delClients() {
  my $p4 = shift;
  
  foreach(`$p4 clients`) {
    if(/^Client\s(client\d+).*$/) {
      `$p4 client -d -f $1`;
    }
  }
} #end of delClients

###############################################################################
&main();
