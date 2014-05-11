#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 4;

use Path::Class;

use MP3::DB::App::Command::scan;

can_ok("MP3::DB::App::Command::scan", 'description', 'abstract', 'usage_desc', 'validate_args', 'execute');

my @options = MP3::DB::App::Command::scan::opt_spec;
is_deeply(\@options, [["database|d=s", "database name", { default => 'mp3db'}], ["host|h=s", "host name for the MongoDB server", { default => 'localhost'}], ["port|p=s", "port number for the MongoDB server", { default => 27017}]], "option specification");
is(MP3::DB::App::Command::scan::description, "scan and index MP3 collections into mongodb databases", "command description");
is(MP3::DB::App::Command::scan::usage_desc, "mp3db %o directory", "usage description");

