#!/usr/bin/env perl
#*******************************************************************************
#
#Author: Stephen Moon
#Last Update: 2011/07/05
#Program Summary: Cleans up the test case after the generation
#
#
#*******************************************************************************

use strict;
use warnings;
use Cwd;
use File::Basename;
use File::Copy;
use File::Path;
use Data::Dumper;
use Fatal qw / copy mkdir /; 

my $debug = 0; #set to 1 for verbose mode
my $cwd = getcwd();

my $tcDir = "tc"; #topmost test case directory
my $p4config="";

foreach(`p4 set`) {
  print "set: $_\n" if $debug == 1;
  if(/^P4CONFIG\=(\S+).*$/) {
    print "first: $1\n" if $debug == 1;
    $p4config = $1;
  }
}

#log file after each run is saved under result dir
#test case file is saved under scenario dir
my @tc_dirs = qw/ result scenario scripts /; 

`p4 revert //...`; 
`p4 sync ./...#none`;
`p4 obliterate -y ./...`;

if(! -d $tcDir) { mkdir($tcDir); }
foreach(@tc_dirs) {
  if($^O =~ /MSWin32/ && ! -d "$tcDir\\$_") {
    mkdir("$tcDir\\$_");
  } elsif(! -d "$tcDir/$_") {
    mkdir("$tcDir/$_");
  }
}

my @files = glob($cwd . "/*");
my ($file,$ext) = ("","");

foreach(@files) {

  if(/.*log/) { 
    copy($_,$cwd . "/$tcDir/$tc_dirs[0]");
  }
  
  if(/\d+_tc\.txt$/) {
    copy($_,$cwd . "/$tcDir/$tc_dirs[1]");
  }

  print "base: " . basename($_) . "\n" if $debug == 1;

  if(basename($_) !~ /$p4config/) {

    unlink $_;
    
    if($debug) {
      print  $_ . " deleted\n";
    }

  }

  if(-d $_ && $_ !~ /tc/) {

    rmtree($_);
    
    if($debug) {
      print $_ . " and its sub-files deleted recursively\n\n";
    }
    
  }
}

my @tc_files = glob($cwd . "/$tcDir/$tc_dirs[1]/" . "*");

if($debug) {
  #print Dump(@tc_files);
}

my $max = 1;
foreach(@tc_files) {
  ($file,$ext) = split(/\./,$_);

  if(/(\d+)_tc/) {

    if($max < $1) {
      $max = $1;
    }
  } 
  
  if($debug) {
    print "file w/o extension: " . $file . "\n";
    print "extension: " . $ext . "\n";
  }
}

if($debug) {
  print "maxfile: " . $max . "_tc.txt\n";
  print "src: " . $cwd . "/$tcDir/$tc_dirs[1]/$max" . "_tc.txt\n";
  print "dest: " . $cwd . "/" . ($max + 1) . "_tc.txt\n";
}

copy($cwd . "/$tcDir/$tc_dirs[1]/$max" . "_tc.txt",$cwd . "/" . ($max + 1) . "_tc.txt");
