#!/usr/local/bin/perl

use strict;
use warnings;

use Test::More('no_plan');

require_ok('./linkchecker.pl');

# get_files/get_ids
{
  my $files_ref = get_files('t/data1', '');
  is_deeply($files_ref, [
    'base.css',
    'dir/subpage.html',
    'img.jpg',
    'index.html',
    'page.html',
    'script.js'
  ], 'get_files(\'data1/\')');
  my $ids_ref = get_ids($files_ref, 't/data1');
  is_deeply($ids_ref, [
    'index.html#id1'
  ], 'get_ids(\'data1\')');
}

# normalize_path
{
  my $path;
  $path = normalize_path('/foo/bar');
  is($path, '/foo/bar', 'normalize_path(\'/foo/bar\')');
  $path = normalize_path('/foo/bar/');
  is($path, '/foo/bar', 'normalize_path(\'/foo/bar/\')');
  $path = normalize_path('/foo/bar/..');
  is($path, '/foo', 'normalize_path(\'/foo/bar/..\')');
  $path = normalize_path('/foo/bar/.');
  is($path, '/foo/bar', 'normalize_path(\'/foo/bar/.\')');
}

# get_directory
{
  my $dir;
  $dir = get_directory('/foo/bar', 'get_directory(\'/foo/bar\')');
  is($dir, '/foo/');
  $dir = get_directory('/foo/');
  is($dir, '/foo/', 'get_directory(\'/foo/\')');
}
