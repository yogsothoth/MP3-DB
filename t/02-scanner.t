#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 8;
use Test::Warnings ':all';

use MP3::DB::Scanner;
use Path::Class;

my $scanner = MP3::DB::Scanner->new(database => undef);
isa_ok($scanner, 'MP3::DB::Scanner');

can_ok($scanner, 'scan', 'tagmp3', 'tags');

# ID3
my $testfile = file('testdata', 'test.mp3');
is_deeply($scanner->tags($testfile), { title => 'Only a test with a ID3v1 and ID3v2 tag', song => 'Only a test with a ID3v1 and ID3v2 tag', track => 10, artist => 'Artist', album => 'Album', year => 2000, comment => 'test', genre => 'Ska' }, "ID3 tags extraction");

my $wrong_file = "testdata/dummy.txt";
is($scanner->tagmp3($wrong_file), undef, "tagmp3 only deals with MP3 files");

my $directory = "testdata/dummydir.mp3";
is($scanner->tagmp3($directory), undef, "tagmp3 skips directories");

# warnings
my $illegal_arg = "Illegal argument given to subroutine tags";
like( warning { $scanner->tags(undef) }, qr/$illegal_arg/, 'proper warning when calling tags with an undef file path');

my $w = warning { $scanner->tags(32) };

like( $w, qr/$illegal_arg/, 'proper warning when calling tags with a parameter having the wrong type') or diag 'got warning(s): ', explain($w);
