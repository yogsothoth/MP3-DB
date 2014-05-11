#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 2;
use Test::Warnings ':all';
use Test::Deep;

use MP3::DB::Database;
use MP3::DB::App::Command::group;


can_ok("MP3::DB::App::Command::group", 'abstract', 'description', 'opt_spec',
                'usage_desc', 'validate_args', 'execute');
