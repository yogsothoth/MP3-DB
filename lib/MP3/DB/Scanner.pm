use strict;
use warnings;
package MP3::DB::Scanner;

use 5.012;

use Path::Class qw( file dir );
use Carp qw( carp cluck );
use Scalar::Util qw( blessed );
use MP3::Tag;
use File::Find;

# ABSTRACT: find MP3 files and save their metadata
$MP3::DB::Scanner::VERSION = '0.001';

=head1 SYNOPSIS

        use MP3::DB::Database;
        use MP3::DB::Scanner;
        use File::Path qw( dir );

        my $db = MP3::DB::Database->new();
        my $scanner = new MP3::DB::Scanner->new($db);
        my $dir = File::Path::dir("~/mp3");
        $scanner->scan($dir);

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

=method scan

This method is the heart of this class. Scan recursively explores the directory for MP3 files, extracting tags and importing them into the MongoDB database. C<scan> relies on C<find> to do this (see L<File::Find>), passing the usual C<wanted> function to do the hard work. In order for C<wanted> to have access to instance variables, C<scan> actually passes an anonymous sub reference to C<find>, acting as a closure capturing the context.
This method takes only one argument, C<dir>, which is the directory to explore and must be an instance of L<Path::Class::Dir>. C<scan> C<cluck>s and returns immediately in case an illegal argument is passed.
This method returns the result of C<find>, which is nothing as of today.

=cut

sub scan {
    my ($self, $dir) = @_;
    if(! defined $dir or "Path::Class::Dir" ne blessed $dir) {
        cluck("Illegal argument given to subroutine scan: $dir");
        return;
    }

    my $wanted = sub { my $file = $_; $self->tagmp3($file); };

    return find($wanted, $dir);
}

=method tagmp3

This method is called by C<scan>, as it browses its directory, for each file or directory found. This method acts as the traditional C<wanted> function fed to C<find> (see L<File::Find>). This means it is called with a single argument, the filesystem item found. In case this is a directory, C<tagmp3> returns immediately. In case the file doesn't end with either C<.mp3> or C<.MP3>, it returns immediately as well. Finally, if the file has such an extension, C<tagmp3> calls C<tags> to extract the information from the audio file, and save it to the database, calling L<MP3::DB::Database::save> with the hashref returned by C<tags>.
This method does not return anything.

=cut

sub tagmp3 {
    my ($self, $file) = @_;
    return unless -f $file;
    return unless $file =~ /\.mp3$/i;
    say "Processing $file";
    my $infos = $self->tags(file($file));
    for my $key (keys $infos) {
        say "$key: " . $infos->{$key};
    }
    $self->{database}->save($infos);
}

=method tags

This method (surprise, surprise!) extracts tags from an MP3 file. The file given in argument must be an instance of C<Path::Class::File> (see L<Path::Class::File>). The tags are extracted trying ID3v2 first, then ID3v1, then from a CDDB file, then from an inf file and, as a last resort, from the file name itself. This is all handled by L<MP3::Tag>.
This method returns a hashref containing the following keys: C<artist>, C<song>, C<title>, C<album>, C<year> (if found), C<comment> (if found).

=cut

sub tags {
    my ($self, $file) = @_;
    if((! defined $file) or
        (! defined blessed $file) or
        ("Path::Class::File" ne blessed $file)) {
        cluck("Illegal argument given to subroutine tags");
        return;
    }

    my $mp3 = MP3::Tag->new($file->stringify);
    my $infos = $mp3->autoinfo;
    return $infos;
}
1;
