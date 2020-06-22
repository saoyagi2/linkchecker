#!/usr/local/bin/perl

use strict;
use warnings;

use HTML::Parser;
use Getopt::Long;
use Data::Dumper;

my $opt_verbose;

if($0 eq __FILE__) {
  usage() if(!GetOptions(
    'verbose|v' => \$opt_verbose
  ));
  usage() if(@ARGV < 1);

  my $basedir = $ARGV[0];
  my $files_ref = get_files($basedir, '');
  my $ids_ref = get_ids($files_ref, $basedir);
  foreach my $file (@$files_ref) {
    linkcheck($file, $basedir, $files_ref, $ids_ref);
  }
}

# リンクチェック
# @param $file 対象ファイル
# @param $basedir 基準ディレクトリ
# @param $files_ref ファイル一覧のリファレンス
# @param $ids_ref id一覧のリファレンス
sub linkcheck {
  my($file, $basedir, $files_ref, $ids_ref) = @_;
  my @links = ();
  my $parser = HTML::Parser->new(
    api_version => 3,
    start_h     => [
      sub {
        my ($tagname, $attr, $line) = @_;
        if($tagname eq 'a' && defined $attr->{'href'}) {
          push @links, {'link'=>$attr->{'href'}, 'line'=>$line};
        }
        if($tagname eq 'img' && defined $attr->{'src'}) {
          push @links, {'link'=>$attr->{'src'}, 'line'=>$line};
        }
        if($tagname eq 'link' && defined $attr->{'href'}) {
          push @links, {'link'=>$attr->{'href'}, 'line'=>$line};
        }
        if($tagname eq 'script' && defined $attr->{'src'}) {
          push @links, {'link'=>$attr->{'src'}, 'line'=>$line};
        }
      }, "tagname, attr, line"]),;
  $parser->parse_file("$basedir/$file");
  return if(@links == 0);
  print "target: $file\n" if($opt_verbose);

  foreach my $link (@links) {
    print "link: $link->{'link'}\n" if($opt_verbose);
    next if $link->{'link'} =~ /^(http|https|mailto):/ || index($link->{'link'}, '//') == 0 ;
    my $target;
    if($link->{'link'} =~ /^#/) {
      $target = $file . $link->{'link'};
    }
    else {
      $target = get_directory($file) . $link->{'link'};
      $target .= $target =~ /\/$/ ? 'index.html' : '';
      $target = normalize_path($target);
    }
    next if grep {$_ eq $target} @$files_ref;
    next if grep {$_ eq $target} @$ids_ref;
    next if $link->{'link'} =~ /\/$/ && -f "$basedir/$file/$link->{'link'}index.html";
    printf("%s:%d: %s not found.\n", ($basedir ne '.' ? $basedir : '') . $file, $link->{'line'}, $link->{'link'});
  }
}

# ファイル一覧取得
# @param $basedir 基準ディレクトリ
# @param $dir 探索中サブディレクトリ
# @return ファイル一覧のリファレンス
sub get_files {
  my ($basedir, $dir) = @_;
  my @files = ();

  opendir my $dh, "$basedir/$dir" or die "Can't open directory $basedir/$dir";
  foreach my $file (sort readdir $dh) {
    next if $file =~ /^\./;
    if(-f "$basedir/$dir/$file") {
      push @files, ($dir ne '' ? "$dir/$file" : $file);
    }
    if(-d "$basedir/$dir/$file") {
      push @files, @{get_files($basedir, ($dir ne '' ? "$dir/$file" : $file))};
    }
  }

  return \@files;
}

# id一覧を取得
# @param $files_ref ファイル一覧のリファレンス
# @param $basedir 基準ディレクトリ
# @return id一覧のリファレンス
sub get_ids {
  my($files_ref, $basedir) = @_;
  my @ids;
  foreach my $file (@$files_ref) {
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
  return \@ids;
}

# パス文字列の正規化(..を整理する)
# @param $path パス文字列
# @return 正規化パス文字列
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

# パス文字列からディレクトリ部分を抽出
# @param $path パス文字列
# @return ディレクトリ文字列
sub get_directory {
  my $path = shift;
  if($path !~ /\/$/) {
    $path =~ s/[^\/]+$//;
  }
  return $path;
}

sub usage {
  print <<'MSG';
Usage: linkchecker [OPTION]... base-directory

  -V, --verbose  display verbose message.
MSG
  exit;
}

1;
