use strict;
use warnings;
package MP3::DB::DatabaseHelper;

# ABSTRACT: provides some handy functions to interact with MongoDB

use 5.012;

use MongoDB;
use Carp qw( carp cluck croak confess );
use Try::Tiny;
use DateTime;

use Exporter qw( import );

our @EXPORT = ();
our @EXPORT_OK = qw ( generate_collname );
our %EXPORT_TAGS = (
    all => [ @EXPORT, @EXPORT_OK ],);

=head1 SYNOPSIS

    use MP3::DB::DatabaseHelper qw( generate_collname );
    # or
    # use MP3::DB::DatabaseHelper ':all';

    my $collection_name = generate_collname("mydb");
    say $collection_name;
    # prints something like mydb_20140420T103528

=cut

=method generate_collname

This function generates names for MongoDB collections. It takes a radix as a string and returns the collection name accordingly. The names generated follow the pattern <radix>_YYYYMMDDTHHMMSS, that is the radix followed by an C<'_'> and the current date and time, formatted for easy sorting.

It C<cluck>s an error message and returns immediately in case an undefined or empty radix is given in argument.

=cut

sub generate_collname {
    my ($radix) = @_;

    cluck "Illegal argument passed to sub generate_collname. The database name cannot be undef or empty." and return unless ((defined $radix) and (length $radix));

    my $now = DateTime->now;

    return $radix . "_" . $now->ymd('') . "T" . $now->hms('');
}

1;
