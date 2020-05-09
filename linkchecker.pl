#!/usr/local/bin/perl

use strict;
use warnings;

use Data::Dumper;

if(@ARGV < 1) {
  usage();
}
else {
  linkcheck($ARGV[0]);
}

sub linkcheck {
  my $basedir = shift;
  my @files = list_files($basedir, '');
}

sub list_files {
  my ($basedir, $dir) = @_;
  my @files = ();

  opendir my $dh, "$basedir/$dir" or die "Can't open directory $basedir/$dir: $!";
  while(my $file = readdir $dh) {
    next if $file =~ /^\./;
    if(-f "$basedir/$dir/$file") {
      push @files, "$dir/$file";
    }
    if(-d "$basedir/$dir/$file") {
      push @files, list_files($basedir, "$dir/$file");
    }
  }

  return @files;
}

sub usage {
  print "usage : linkchecker base-directory\n";
  exit;
}
