#!/usr/local/bin/perl

use strict;
use warnings;

use HTML::Parser;
use Data::Dumper;

if(@ARGV < 1) {
  usage();
}

my @links;
my $basedir = $ARGV[0];
my $parser = HTML::Parser->new(
  api_version => 3,
  start_h     => [
    sub {
      my ($tagname, $attr) = @_;
      if($tagname eq 'a' && defined($attr->{'href'})) {
        push @links, $attr->{'href'};
      }
    }, "tagname, attr"]),;

foreach my $file (list_files($basedir, '')) {
  @links = ();
  $parser->parse_file("$basedir/$file");
  foreach my $link (@links) {
    next if $link =~ /^https?:/;
    next if -f "$basedir/$link";
    next if $link =~ /\/$/ && -f "$basedir/${link}index.html";
    print "$basedir/$file: $link\n";
  }
}

sub list_files {
  my ($basedir, $dir) = @_;
  my @files = ();

  opendir my $dh, "$basedir/$dir" or die "Can't open directory $basedir/$dir: $!";
  while(my $file = readdir $dh) {
    next if $file =~ /^\./;
    if(-f "$basedir/$dir/$file") {
      push @files, ($dir ne '' ? "$dir/" : '') . $file;
    }
    if(-d "$basedir/$dir/$file") {
      push @files, list_files($basedir, ($dir ne '' ? "$dir/" : '') . $file);
    }
  }

  return @files;
}

sub usage {
  print "usage : linkchecker base-directory\n";
  exit;
}