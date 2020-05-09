#!/usr/local/bin/perl

use strict;
use warnings;

use HTML::Parser;
use Data::Dumper;

if(@ARGV < 1) {
  usage();
}

my $basedir = $ARGV[0];
my @links;
my @ids;
my @files = list_files($basedir, '');

foreach my $file (@files) {
  my $parser = HTML::Parser->new(
    api_version => 3,
    start_h     => [
      sub {
        my ($attr) = @_;
        if(defined $attr->{'id'}) {
          push @ids, "$file#$attr->{'id'}";
        }
      }, "attr"]),;
  $parser->parse_file("$basedir/$file");
}

foreach my $file (@files) {
  @links = ();
  my $parser = HTML::Parser->new(
    api_version => 3,
    start_h     => [
      sub {
        my ($tagname, $attr) = @_;
        if($tagname eq 'a' && defined $attr->{'href'}) {
          push @links, $attr->{'href'};
        }
        if($tagname eq 'img' && defined $attr->{'src'}) {
          push @links, $attr->{'src'};
        }
      }, "tagname, attr"]),;
  $parser->parse_file("$basedir/$file");

  foreach my $link (@links) {
    next if $link =~ /^(http|https|mailto):/;
    my $target;
    if($link =~ /^#/) {
      $target = $file . $link;
    }
    else {
      $target = get_directory($file) . $link;
      $target .= $target =~ /\/$/ ? 'index.html' : '';
      $target = normalize_path($target);
    }
    next if grep {$_ eq $target} @files;
    next if grep {$_ eq $target} @ids;
    next if $link =~ /\/$/ && -f "$basedir/$file/${link}index.html";
    print (($basedir ne '.' ? $basedir : '') . "$file: $link\n");
  }
}

sub list_files {
  my ($basedir, $dir) = @_;
  my @files = ();

  opendir my $dh, "$basedir/$dir" or die "Can't open directory $basedir/$dir";
  while(my $file = readdir $dh) {
    next if $file =~ /^\./;
    if(-f "$basedir/$dir/$file") {
      push @files, ($dir ne '' ? "$dir/$file" : $file);
    }
    if(-d "$basedir/$dir/$file") {
      push @files, list_files($basedir, ($dir ne '' ? "$dir/$file" : $file));
    }
  }

  return @files;
}

sub normalize_path {
  my $path = shift;
  my @pieces = ();
  foreach my $piece (split('/', $path)) {
    next if($piece eq '' || $piece eq '.');
    if($piece eq '..') {
      pop(@pieces);
      next
    }
    push(@pieces, $piece);
  }
  return ($path =~ /^\// ? '/' : '') . join('/', @pieces);
}

sub get_directory {
  my $path = shift;
  if($path !~ /\/$/) {
    $path =~ s/[^\/]+$//;
  }
  return $path;
}

sub usage {
  print "usage : linkchecker base-directory\n";
  exit;
}
