#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 3;
use Test::Warnings ':all';

use MP3::DB::Grouper;
use Path::Class;

my $grouper = MP3::DB::Grouper->new(source => undef, destination => undef);
isa_ok($grouper, 'MP3::DB::Grouper');

can_ok($grouper, 'group', 'filter');
