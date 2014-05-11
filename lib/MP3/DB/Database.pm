use strict;
use warnings;
package MP3::DB::Database;

# ABSTRACT: provides an very simple interface to a database

use 5.012;

use MongoDB;
use Carp qw( carp cluck croak confess );
use Try::Tiny;

=head1 SYNOPSIS
        use MP3::DB::Database;

        my $database = MP3::DB::Database->new(host => 'localhost', port => 27017, database => 'mydb', collname => 'mycollection');
        $database->dbconnect;
        $database->save($hashref);
=cut

=method new

The C<new> constructor expects a hash with the following keys: C<host>, the host where MongoDB runs; C<port> the port MongoDB listens to; C<database> the database name.

=cut

sub new {
    my $class = shift;
    my $self = { @_ };
    $self->{collection} = undef;
    bless $self, $class;
    return $self;
}

=method dbconnect

This method uses the information given in the constuctor to connect to the database. The collection name is derived from the database name and takes the form: <dbname>_date (e.g. mydb_20140405T2203). This means a collection is never updated, successive scans create additional collections.
This methods returns the collection on success, and C<cluck>s and returns immediately in case an error is found while trying to interact with MongoDB.

=cut

sub dbconnect {
    my ($self) = @_;
    my $client;
    my $database;
    try {
        $client = MongoDB::MongoClient->new(host => $self->{host}, port => $self->{port});
        die unless $self->validate_dbname($self->{database});
        $database = $client->get_database($self->{database});

        die unless $self->validate_collname($self->{collname});
        $self->{collection} = $database->get_collection($self->{collname});
    } catch {
        cluck('Failed to connect to the MongoDB resource: ' . $_);
        return;
    };

    return $self->{collection}
}

=method validate_dbname
This method validates MongoDB database names according to the specification. Currently, a database name cannot contain the following characters: C<. / \> as well as spaces and tabs. In case at least one of these characters is present in the database name given in argument, the method C<cluck>s an error message and returns immediately. Otherwise, this method returns 1, to make it easy to it in an C<if> or C<unless> clause.
=cut

sub validate_dbname {
    my ($self, $dbname) = @_;
    return unless defined $dbname;

    my @chars = (".", "\\", "/", "\\s");
    my $warning = 'Illegal database name. Database names must not contain the following characters:' . join(' ', @chars);
    if( (! length $dbname) or
        ($dbname =~ /[.\\\/\s]/) ) {
        cluck $warning;
        return;
    }
    return 1;
}

=method validate_collname
This method validates MongoDB collection names according to the specification. Currently, a collection name cannot contain the following character: C<$> and cannot start with the string C<system.>. In case the wrong characters or strings are present in the collection name given in argument, the method C<cluck>s an error message and returns immediately. Otherwise, this method returns 1, to make it easy to it in an C<if> or C<unless> clause.
=cut

sub validate_collname {
    my ($self, $collname) = @_;
    return unless defined $collname;

    my $warning = "Illegal collection name. Collection names must not contain the following character: \$. Additionally, collection names must not be empty or start with th string 'system.'.";
    if( (! length $collname) or
        ($collname =~ /\$/) or
        ($collname =~ /^system\./ ) ) {
        cluck $warning;
        return;
    }
    return 1;
}

=method save

This method puts the tags given in argument in the current MongoDB collection, as a new document. The tags are expected to be the only argument given, and to be in the form of a hashref. It is inserted as is.
This method returns the id obtained from MongoDB on success, and C<cluck>s and returns immediately in case an error is encountered.

=cut

sub save {
    my ($self, $infos) = @_;
    my $id = $self->{collection}->insert($infos);
    cluck("Error while inserting data in MongoDB: " . $!) and return unless $id;
    say "Inserted with id $id";
    return $id;
}
=method select_all
This method returns all documents in the MongoDB collection the object is currently connected to.
=cut

sub select_all {
    my ($self) = @_;
    return $self->{collection}->find->all;
}
1;
