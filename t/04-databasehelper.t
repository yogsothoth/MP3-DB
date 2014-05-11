#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 5;
use Test::Warnings ':all';
use Test::Deep;

use MP3::DB::DatabaseHelper;

can_ok("MP3::DB::DatabaseHelper", 'generate_collname');

like(MP3::DB::DatabaseHelper::generate_collname("mydb"), qr/^mydb_[\d]{8}T[\d]{6}$/, 'collection names follow the pattern <dbname>_YYYY-MM-DDTHH:MM:SS');

my $warn_collname_arg = "Illegal argument passed to sub generate_collname";
like( warning { MP3::DB::DatabaseHelper::generate_collname(undef); }, qr/$warn_collname_arg/, 'cluck when undef argument passed to generate_collname');

like( warning { MP3::DB::DatabaseHelper::generate_collname(''); }, qr/$warn_collname_arg/, 'cluck when empty argument passed to generate_collname');

