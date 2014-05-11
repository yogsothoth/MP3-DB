use strict;
use warnings;
package MP3::DB::App::Command::scan;
# ABSTRACT: scan and index MP3 collections into mongodb databases
use MP3::DB::App -command;

$MP3::DB::App::Command::scan::VERSION = '0.001';

use 5.012;

use Carp qw( carp cluck );
use Scalar::Util qw( blessed );
use Path::Class qw( file dir );
use MP3::DB::Scanner;
use MP3::DB::Database;
use MP3::DB::DatabaseHelper qw( generate_collname );

=head1 SYNOPSIS

   mp3db scan --database mydb --host myhost --port 2345 ~/mp3
   mp3db scan -d mydb -h myhost -p 2345 ~/mp3
 This command scans the directory given in argument for mp3 files, extracts their ID3 tags and insert the result in a MongoDB database. Each mp3 file get its own document in the collection, with all its tags.

=cut

sub opt_spec {
    return (
        ["database|d=s", "database name", { default => 'mp3db' }],
        ["host|h=s", "host name for the MongoDB server", { default => 'localhost' }],
        ["port|p=s", "port number for the MongoDB server", { default => 27017 }],
        );
}

=head1 OPTIONS

=head2 -d, --database

The name of the target MongoDB database where the collection and the documents will be created. If no database name is provided, it defaults to 'mp3db'.

=head2 -h, --host

The host where MongoDB is running. It can be an IP address or a hostname. If no host is provided, the default value 'localhost' is used.

=head2 -p, --port

The port where MongoDB is reachable. If no port is given, the default value 27017 is used.

=cut

sub description { "scan and index MP3 collections into mongodb databases" }

sub abstract { "scan and index MP3 collections into mongodb databases" }

sub usage_desc { return "mp3db %o directory"; }

sub validate_args {
    my ($self, $opt, $args) = @_;
    $self->usage_error("%o takes exactly one argument") if @$args != 1;
}
=method execute

This method is where everything happens. The host, port and database information provided on the command line are used to connect to the MongoDB instance. The database name is also used for generating a collection name. The collection name is derived from the database name and takes the form: <dbname>_date (e.g. mydb_20140405T2203). This means a collection is never updated, successive scans create additional collections. This method relies on L<MP3::DB::DatabaseHelper::generate_collname> to do that.

=cut

sub execute {
    my ($self, $opt, $args) = @_;
    my $collname = generate_collname($opt->database);
    my $db = MP3::DB::Database->new(host => $opt->host, port => $opt->port, database => $opt->database, collname => $collname);
    $db->dbconnect;
    my $directory = dir($args->[0]);
    my $scanner = MP3::DB::Scanner->new(database => $db);
    $scanner->scan($directory);
}
1;
