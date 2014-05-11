use strict;
use warnings;
package MP3::DB::Grouper;

use 5.012;

use Carp qw( carp cluck );
use Path::Class qw( file dir );
use Scalar::Util qw( blessed );
use MongoDB;

# ABSTRACT: groups MP3 metadata from one database collection into another
$MP3::DB::Grouper::VERSION = '0.001';

=head1 SYNOPSIS

        use MP3::DB::Database;
        use MP3::DB::Grouper;

        my $db = MP3::DB::Database->new;
        my $dest_db = MP3::DB::Database->new;

        my $grouper = new MP3::DB::Grouper->new(source=> $db, destination_db => $dest_db);
        $grouper->group;

=cut

=method new

C<new> expects a hash containing two database interface objects, one for the source database, the other for the destination. The database parameters must be instances of L<MP3::DB::Database>.

=cut

sub new {
    my $class = shift;
    my $self = { @_ };
    bless $self, $class;
    return $self;
}

=method group

This method is the heart of this class. C<group> opens the source database and fetches all data. It then opens the target database, and insert one document per album found in the source data.
It returns an array containing all the ids obtained upon saving the data.

=cut

sub group {
    my $self = shift;

    my %data;
    my @results = $self->{source}->select_all;

    my @albums = $self->filter(\@results);

    my @ids;
    foreach my $album (@albums) {
        my $id = $self->{destination}->save($album);
        push @ids, $id;
    }

    return @ids;
}

sub filter {
    my ($self, $data) = @_;
    my %seen;
    my @albums;

    foreach my $song (@$data) {
        my $key = $song->{artist} . "-" . $song->{album};
        push @albums, { artist => $song->{artist},
                        album => $song->{album},
                        year => $song->{year} }
                    unless exists $seen{ $key };
        $seen{$key}=1;
    }

    return @albums;
}
1;
