use strict;
use warnings;
package MP3::DB::Extractor;

use 5.012;

use Carp qw( carp cluck );
use Path::Class qw( file dir );
use Scalar::Util qw( blessed );
use MongoDB;
use JSON;

# ABSTRACT: extract MP3 metadata from database as JSONP
$MP3::DB::Extractor::VERSION = '0.001';

=head1 SYNOPSIS

        use MP3::DB::Database;
        use MP3::DB::Extactor;

        my $db = MP3::DB::Database->new();
        my $extractor = new MP3::DB::Extractor->new($db);
        $extractor->extract; #output goes by default to extract.jsonp

=cut

=method new

C<new> expects a hash containing the database interface object. The database parameter must be an instance of L<MP3::DB::Database>.

=cut

sub new {
    my $class = shift;
    my $self = { @_ };
    bless $self, $class;
    return $self;
}

=method extract

This method is the heart of this class. C<extract> opens the database and dumps all data in the format given in argument, and in the file given in argument. By default, the format is JSONP, and the output goes to a file named extract.jsonp.
This method accepts a hash expected to contain the following keys: C<format>: the output format, which can be one of ... and defaults to JSONP; C<file>: the output file, with a default name of extract.<format>.
This method returns the result of C<Path::Class::File::spew>, which is used internally for writing the file.

=cut

sub extract {
    my $self = shift;
    my $params = { @_ };
    my $format = defined $params->{'format'} ? lc $params->{'format'} : 'jsonp';
    my $output = defined $params->{'file'} ? lc $params->{'file'} : "extract.$format";

    my $output_file = file($output);
    my %data;
    my @results = $self->{'database'}->select_all;

    my @timeline_results = map { $self->to_timeline($_); } @results;

    $data{timeline}{headline} = "Timeline headline";
    $data{timeline}{type} = "default";
    $data{timeline}{text} = "Timeline text";
    $data{timeline}{startDate} = "2001,01,01";
    $data{timeline}{date} = \@timeline_results;
    my $json = JSON->new->convert_blessed;
    my $jsonp_data = "storyjs_jsonp_data = " . $json->encode(\%data);
    return $output_file->spew($jsonp_data);
}

=method to_timeline

This method takes a hash reference with MP3 metadata, like a document record from a MongoDB collection, and returns a hash reference suitable for use with knightlab's TimeLine. Since MP3 do not contain complete release dates for tracks, the start date is set to C<01/01/<YEAR>> and the end date to C<01/02/<YEAR>>, where C<<YEAR>> is the year field as found in the record. The C<headline> field is set to the string "<artist> - <album>", these fields being taken again from the record. The C<text> field is set to the same string as the headline, and the asset is left empty.

=cut

sub to_timeline {
    my ($self, $data) = @_;

    my %tl;
    $tl{startDate} = ($data->{year} || "2000") . ",01,01";
    $tl{endDate} = ($data->{year} || "2000") . ",01,02";
    $tl{headline} = $data->{artist} . " - " . $data->{album};
    $tl{text} = $tl{headline};
    $tl{asset} = {};

    return \%tl;
}
1;
