use strict;
use warnings;
package MP3::DB;
# ABSTRACT: scans, index, transform and publish MP3 collections in mongodb databases

=head1 SYNOPSIS
   # MP3::DB comes with a set of command-line tools
   mp3db scan --database mydb --host localhost --port 27017
   mp3db group --database mydb --host myhost --port 2345 --collection mycollection
   mp3db extract --database mydb --host myhost --port 2345 --collection mycollection --format jsonp output.jsonp

   # MP3::DB can also be used as a library
   use MP3::DB::Database;
   use MP3::DB::Scanner;
   use MP3::DB::Grouper;
   use MP3::DB::Extractor;
   use File::Path qw( dir );

   # create a database instance
   my $db = MP3::DB::Database->new;

   #scan
   my $scanner = new MP3::DB::Scanner->new($db);
   my $dir = File::Path::dir("~/mp3");
   $scanner->scan($dir);

   # transform
   my $dest_db = MP3::DB::Database->new;
   my $grouper = new MP3::DB::Grouper->new(source=> $db, destination_db => $dest_db);
   $grouper->group;

   #extract
   my $extractor = new MP3::DB::Extractor->new($db);
   $extractor->extract; #output goes by default to extract.jsonp


=head1 DESCRIPTION

MP3::DB is both a set of tools and a library for working with MP3 metadata. MP3 files collections residing on a local or distant hard disk can be scanned and indexed into MongoDB databases, as dedicated collections. At that point, the data can be enriched, reworked and transformed at will. Eventually, the resulting MP3 metadata can be exported in a selection of formats typically suitable for web usage.

=head1 COMMANDS

=head2 scan

The C<scan> command is responsible for browsing MP3 collections and indexing the metadata in MongoDB databases. Note that each run produces a new collection in the database; i.e. successive runs of the C<scan> command will not update and spoil existing data. For more information on this command, see L<MP3::DB::App::Command::scan>.

=head2 group

The C<group> command is a transformation command. Like all transformation commands, it works with a dataset available in a source MongoDB collection and stores the resulting, transformed data into a new collection. The group command filters an MP3 collection to retain album information only. For more information on this command, see L<MP3::DB::App::Command::group>.

=head2 extract

The C<extract> command is responsible for publishing the data from a MongoDB collection to a format suitable for web usage (e.g. JSON, JSONP). For more information on this command, see L<MP3::DB::App::Command::extract>.

=cut

1;
