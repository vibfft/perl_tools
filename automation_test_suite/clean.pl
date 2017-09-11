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
