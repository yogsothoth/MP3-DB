#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 5;

use Path::Class;

use MP3::DB::App::Command::extract;

can_ok("MP3::DB::App::Command::extract", 'opt_spec', 'validate_args', 'abstract', 'description', 'usage_desc', 'execute');

my @options = MP3::DB::App::Command::extract::opt_spec;
is_deeply(\@options, [["database|d=s", "database name", { default => 'mp3db'}],
                     ["host|h=s", "host name for the MongoDB server", { default => 'localhost'}],
                     ["port|p=s", "port number for the MongoDB server", { default => 27017}],
                     ["collection|c=s", "collection where the data can be found", { }],
                     ["format|f=s", "format for the output", { default => "jsonp"}]],
                 "option specification");

is(MP3::DB::App::Command::extract::description, "extract MP3 information from collections stored in mongodb databases", "command description");

is(MP3::DB::App::Command::extract::abstract, "extract MP3 information from collections stored in mongodb databases", "command abstract");

is(MP3::DB::App::Command::extract::usage_desc, "mp3db %o [file]", "usage description");
