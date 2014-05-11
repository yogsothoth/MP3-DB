use strict;
use warnings;
package MP3::DB::App::Command::extract;

# ABSTRACT: extract music information from mongodb databases
use MP3::DB::App -command;

$MP3::DB::App::Command::extract::VERSION = '0.001';

use 5.012;

use Carp qw( carp cluck );
use Scalar::Util qw( blessed );
use Path::Class qw( file dir );
use MP3::DB::Extractor;
use MP3::DB::Database;

=head1 SYNOPSIS

   mp3db extract --database mydb --host myhost --port 2345 --collection mycollection --format jsonp output.jsonp
   mp3db extract -d mydb -h myhost -p 2345 -c mycollection -f jsonp output.jsonp

   This command extracts all MP3 metadata from the MongoDB collection specified by the user and write it to the output file given as argument, in the format specified.

=cut

sub opt_spec {
    return (
        ["database|d=s", "database name", { default => 'mp3db' }],
        ["host|h=s", "host name for the MongoDB server", { default => 'localhost' }],
        ["port|p=s", "port number for the MongoDB server", { default => 27017 }],
        ["collection|c=s", "collection where the data can be found", { }],
        ["format|f=s", "format for the output", { default => "jsonp" }],
        );
}

=head1 OPTIONS

=head2 -d, --database

The name of the target MongoDB database where the collection and the documents can be found. If no database name is provided, it defaults to 'mp3db'.

=head2 -h, --host

The host where MongoDB is running. It can be an IP address or a hostname. If no host is provided, the default value 'localhost' is used.

=head2 -p, --port

The port where MongoDB is reachable. If no port is given, the default value 27017 is used.

=head2 -c, --collection

The collection where the data can be found. There is no default for this option, the collection must be specified by the user.

=head2 -f, --format

The format for writing the output file. For now, only JSONP is supported. The default value is C<jsonp>.

=cut

sub description { "extract MP3 information from collections stored in mongodb databases" }

sub abstract { "extract MP3 information from collections stored in mongodb databases" }

sub usage_desc { return "mp3db %o [file]"; }

sub validate_args {
    my ($self, $opt, $args) = @_;
    $self->usage_error("%o takes up to one argument") if @$args > 1;
    $self->usage_error("%o requires the collection to be provided on the command line") unless defined $opt->collection;
}

sub execute {
    my ($self, $opt, $args) = @_;
    my $file = $args->[0] ? $args->[0] : $opt->database . "_" . $opt->collection . ".jsonp";
    say "host " . $opt->host . " port " . $opt->port . " database " . $opt->database . " collection " . $opt->collection;

    my $db = MP3::DB::Database->new(host => $opt->host, port => $opt->port, database => $opt->database, collname => $opt->collection);
    $db->dbconnect;

    my $extractor = MP3::DB::Extractor->new(database => $db);

    $extractor->extract(format => "jsonp", file => $file);
}

1;
