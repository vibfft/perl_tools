#!/usr/bin/env perl

use warnings;
use strict;
use FileHandle;
use Text::Diff;
use List::Util qw / shuffle /;
#use IO::Handle;
use Cwd;
use autodie;


sub compare_ckp {

  my $len_a_ref = shift;
  my $len_b_ref = shift;
  my $exclude_list_ref = shift;
  my $fd_lines = shift;
  my $fd_tx = shift;
  my $fd_diff = shift;

  #either pass file names or reference to the records.  In this case, that would be a string
  my @diffs = split(/\n/, diff( $len_a_ref, $len_b_ref, { STYLE => "OldStyle" } ));

  foreach my $each_line (@diffs) {

    if($each_line =~ /^(\d+.*)$/ or $each_line =~ /^---.*$/) { print $fd_lines "$each_line\n"; } 
    elsif   ($each_line =~ /^(\>|\<)\s($exclude_list_ref->[0].*)$/) { print $fd_tx "$each_line\n"; } 
    elsif   ($each_line =~ /^(\>|\<)\s($exclude_list_ref->[1].*)$/) { print $fd_tx "$each_line\n"; } 
    elsif   ($each_line =~ /^(\>|\<)\s($exclude_list_ref->[2].*)$/) { print $fd_tx "$each_line\n"; } 
    else                                                     { print $fd_diff "$each_line\n"; }
   
  }

}

sub shuffle_ckp {

  my $ckp_two = shift;
  my $ckp_shuffle = shift;

  my @file_names = ( 'single.txt', 'multi.txt' ); 

  my %table_record = 	(
			#multiline means 1, otherwise it's 0
			'db.archive' => 0,
			'db.archmap' => 0,
			'db.boddate' => 1,
			'db.bodtext' => 1,
			'db.change' => 1,
			'db.changex' => 1,
			'db.config' => 0,
			'db.counters' => 0,
			'db.depot' => 1,
			'db.desc' => 1,
			'db.domain' => 1,
			'db.fix' => 0,
			'db.fixrev' => 0,
			'db.group' => 0,
			'db.have' => 0,
			'db.integ' => 0,
			'db.integed' => 0,
			'db.integtx' => 0,
			'db.ixdate' => 0,
			'db.ixtext' => 0,
			'db.job' => 0,
			'db.jobdesc' => 1,
			'db.jobpend' => 0,
			'db.label' => 0,
			'db.locks' => 0,
			'db.logger' => 0,
			'db.message' => 0,
			'db.monitor' => 1,
			'db.nameval' => 0,
			'db.property' => 0,
			'db.protect' => 1,
			'db.resolve' => 0,
			'db.resolvex' => 0,
			'db.rev' => 0,
			'db.revbx' => 0,
			'db.revcx' => 0,
			'db.revdx' => 0,
			'db.revhx' => 0,
			'db.review' => 0,
			'db.revpx' => 0,
			'db.revsh' => 0,
			'db.revsx' => 0,
			'db.revtx' => 0,
			'db.revux' => 0,
			'db.server' => 1,
			'db.stream' => 1,
			'db.svrview' => 1,
			'db.template' => 0,
			'db.traits' => 0,
			'db.trigger' => 1,
			'db.user' => 1,
			'db.view' => 1,
			'db.working' => 0,
			'db.workingx' => 0,
			'tiny.db' => 0,
			'rdb.lbr' => 0,
			);
			  
  foreach (@file_names) {
    unlink $_;
  }
  open my( $ckptwo_fh ), "$ckp_two";
  open my( $ckpthree_fh ), ">>$ckp_shuffle";
  open my( $ckp_single ), ">$file_names[0]";
  open my( $ckp_multi ), ">$file_names[1]";
  

  while(<$ckptwo_fh>) {

    if(/^\@pv\@ \d+ \@(db\.\w+)\@.*$/) {

      if ( $table_record{$1} == 1 ) {
        print $ckp_multi "$_";
      } else {
        print $ckp_single "$_";
      }

    } else {
      print $ckp_multi "$_";
    }

  }
  $ckp_single->flush;
  $ckp_multi->flush;
  close($ckp_single);
  close($ckp_multi);

  open $ckp_single , "$file_names[0]";
  open $ckp_multi  , "$file_names[1]";
  my @ckp_single = <$ckp_single>;

  while(<$ckp_multi>) { print $ckpthree_fh "$_"; }
  $ckpthree_fh->flush;

  print $ckpthree_fh shuffle(@ckp_single);
  $ckpthree_fh->flush;

  close($ckpthree_fh);
  close($ckptwo_fh);

}

sub main {

  my $argc = @ARGV;

  if ($argc != 2) { die "Usage: " . $0 . " <ckp_one> <ckp_two>\n"; }

  my @exclude_list = ( '@mx@', '@ex@', '@nx@' );
  my @files = ( 'line_count.txt', 'transaction_count.txt', 'real_diff.txt', 'shuffle.txt' );

  foreach (@files) {

    if( -f $_) {
      unlink $_;
    }
  }

  my ($ckp_a, $ckp_b) = ($ARGV[0], $ARGV[1]);
  my $fd_a = FileHandle->new($ckp_a,"r"); 
  my $fd_b = FileHandle->new($ckp_b,"r"); 
  my $fd_lines = FileHandle->new($files[0],"w");
  my $fd_tx = FileHandle->new($files[1],"w");
  my $fd_diff = FileHandle->new($files[2],"w");
 
  my $count = 0; 
  while(1) {

    $count += 1; 

    my ($chunk_a, $chunk_b);
    my $len_a = sysread($fd_a, $chunk_a, 100_000); 
    my $len_b = sysread($fd_b, $chunk_b, 100_000); 

    print "Chunk count#: $count: length identical\n" if $len_a == $len_b;

    last unless $len_a;

    &compare_ckp( \$chunk_a, \$chunk_b, \@exclude_list, $fd_lines, $fd_tx, $fd_diff );
    #&shuffle_ckp( $ARGV[1], 'shuffle.txt' );
  }

  $fd_a->close;
  $fd_b->close;
  $fd_lines->close;
  $fd_tx->close;

}

&main();
