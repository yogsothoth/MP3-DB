use strict;
use warnings;
package MP3::DB::App::Command::group;

# ABSTRACT: group data from one MP3 collection into another
use MP3::DB::App -command;

$MP3::DB::App::Command::group::VERSION = '0.001';

use 5.012;

use Carp qw( carp cluck );
use Scalar::Util qw( blessed );
use Path::Class qw( file dir );
use MP3::DB::Grouper;
use MP3::DB::Database;
use MP3::DB::DatabaseHelper qw( generate_collname );

=head1 SYNOPSIS

   mp3db group --database mydb --host myhost --port 2345 --collection mycollection
   mp3db group -d mydb -h myhost -p 2345 -c mycollection

   This command fetches data from the MongoDB collection given in argument, which is expected to contain an separate document for each song in the collection, and copies i t into a new collection, one document per album.

=cut

sub opt_spec {
    return (
        ["database|d=s", "database name", { default => 'mp3db' }],
        ["host|h=s", "host name for the MongoDB server", { default => 'localhost' }],
        ["port|p=s", "port number for the MongoDB server", { default => 27017 }],
        ["collection|c=s", "collection to be used as a source for data", { }],
        );
}

=head1 OPTIONS

=head2 -d, --database

The name of the MongoDB database where the collection and the documents will be fetched from. If no database name is provided, it defaults to 'mp3db'.

=head2 -h, --host

The host where MongoDB is running. It can be an IP address or a hostname. If no host is provided, the default value 'localhost' is used.

=head2 -p, --port

The port where MongoDB is reachable. If no port is given, the default value 27017 is used.

=head2 -c, --collection

The collection where the source documents can be found. Is must be provided by the user, since there is no default value for this option.

=cut

sub description { "group data from one MP3 collection into another" }

sub abstract { "group data from one MP3 collection into another" }

sub usage_desc { return "mp3db %o"; }

=method validate_args

This method calls C<usage_error> in case the arguments provided on the command line are incorrect.

=cut

sub validate_args {
    my ($self, $opt, $args) = @_;
    $self->usage_error("%o takes no argument") if @$args != 0 ;
    $self->usage_error("%o requires the collection name") unless defined $opt->collection;
}

=method execute

This method is where everything happens. The host, port, database and collection information provided on the command line are used to connect to the MongoDB instance. The new collection is created in the same database, under a name having the form <dbname>_group_album_<datetime>, e.g. mydb_group_album_20140420T151032.

=cut

sub execute {
    my ($self, $opt, $args) = @_;
    my $collname = generate_collname($opt->database . "_group_album");
    my $source_db = MP3::DB::Database->new(host => $opt->host, port => $opt->port, database => $opt->database, collname => $opt->collection);
    $source_db->dbconnect;

    my $target_collection = MP3::DB::DatabaseHelper::generate_collname($opt->database . "_group_album");
    my $dest_db = MP3::DB::Database->new(host => $opt->host, port => $opt->port, database => $opt->database, collname => $target_collection);
    $dest_db->dbconnect;

    my $grouper = MP3::DB::Grouper->new(source => $source_db, destination => $dest_db);
    $grouper->group;

}

1;
