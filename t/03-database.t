#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 18;
use Test::Warnings ':all';
use Test::Deep;

use MP3::DB::Database;

# connection
my %defaults = (host => 'localhost', port => 27017, database => 'mp3test', collname => 'mp3coll');
my $db = MP3::DB::Database->new(%defaults);
isa_ok($db, 'MP3::DB::Database');

can_ok($db, 'validate_dbname', 'validate_collname', 'dbconnect', 'save', 'select_all');

ok($db->dbconnect, "database connection");

# save
my %sample = (Artist => "Blur", Album => "Parklife", Year => 1992);
ok($db->save(\%sample), "save data in the database");

# find
# everything

ok($db->select_all, "get all data in the collection");

# dbnames

my $warn_dbname = "Illegal database name";
like( warning { $db->validate_dbname('with.dots.'); }, qr/$warn_dbname/, 'database names with . are detected as invalid');

like( warning { $db->validate_dbname('with/slash'); }, qr/$warn_dbname/, 'database names with / are detected as invalid');

like( warning { $db->validate_dbname('with\\backslash'); }, qr/$warn_dbname/, 'database names with \\ are detected as invalid');

like( warning { $db->validate_dbname('with spaces'); }, qr/$warn_dbname/, 'database names with spaces are detected as invalid');

like( warning { $db->validate_dbname(''); }, qr/$warn_dbname/, 'database names that are empty are detected as invalid');

# collection names

my $warn_collname = "Illegal collection name";
like( warning { $db->validate_collname('with_a_$'); }, qr/$warn_collname/, 'collection names with $ are detected as invalid');

like( warning { $db->validate_collname('system.thing'); }, qr/$warn_collname/, 'collection names starting with system. are detected as invalid');

like( warning { $db->validate_collname(''); }, qr/$warn_collname/, 'collection names that are empty are detected as invalid');

# connection warnings
my $warn_resource = 'Failed to connect to the MongoDB resource';
my %wrong_params = %defaults;
$wrong_params{host} = 'non_existant';
my $db_warn = MP3::DB::Database->new(%wrong_params);
like ( warning { $db_warn->dbconnect; }, qr/$warn_resource/, 'cluck if given a wrong host');

%wrong_params = %defaults;
$wrong_params{port} = 1111;
$db_warn = MP3::DB::Database->new(%wrong_params);
like ( warning { $db_warn->dbconnect; }, qr/$warn_resource/, 'cluck if given a wrong port');

%wrong_params = %defaults;
$wrong_params{database} = 'wrong database';
$db_warn = MP3::DB::Database->new(%wrong_params);
my @expected = (re($warn_resource), re($warn_dbname));
my $w = warning { $db_warn->dbconnect; };
cmp_bag( $w, \@expected, 'cluck if database cannot be created') or diag 'got warning(s): ', explain($w);

%wrong_params = %defaults;
$wrong_params{collname} = 'wrong$collection';
$db_warn = MP3::DB::Database->new(%wrong_params);
@expected = (re($warn_resource), re($warn_collname));
$w = warning { $db_warn->dbconnect; };
cmp_bag( $w, \@expected, 'cluck if collection cannot be created') or diag 'got warning(s): ', explain($w);

