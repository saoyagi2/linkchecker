#!/usr/local/bin/perl

use strict;
use warnings;

if(@ARGV < 1) {
  usage();
}
else {
  linkcheck($ARGV[0]);
}

sub linkcheck {
  my $basedir = shift;
}

sub usage {
  print "usage : linkchecker base-directory\n";
  exit;
}
