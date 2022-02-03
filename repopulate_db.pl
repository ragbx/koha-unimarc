#!/usr/bin/perl

#cf https://git.koha-community.org/Koha-community/koha-misc4dev/src/branch/master/insert_data.pl

use Modern::Perl;
use Getopt::Long;
use Pod::Usage;
use File::Basename qw( dirname );
use Cwd 'abs_path';

use C4::Installer;
use C4::Context;
use Koha::AuthUtils qw( hash_password );

my $marcflavour = 'UIMARC';
my ( $help, $verbose );

GetOptions(
    'help|?'        => \$help,
    'verbose'       => \$verbose,
    'marcflavour=s' => \$marcflavour
);

pod2usage(1) if $help;

$marcflavour = uc($marcflavour);
my $lc_marcflavour = lc $marcflavour;
our $VERSION = get_version();

if (     $marcflavour ne 'MARC21'
     and $marcflavour ne 'UNIMARC' ) {
    say "Invalid MARC flavour '$marcflavour' passed.";
    pod2usage;
}

our $root      = C4::Context->config('intranetdir');
our $installer = C4::Installer->new;


@records_files = ( "biblio.sql", "biblioitems.sql", "items.sql", "auth_header.sql" );
push @records_files, "biblio_metadata.sql";
use Data::Dumper;warn Dumper \@records_files;

C4::Context->preference('VOID'); # FIXME master is broken because of 174769e382df - 16520
insert_records();

sub execute_sqlfile {
    my ($filepath) = @_;
    say "Inserting $filepath..."
        if $verbose;
    # FIXME There is something wrong here
    # load_sql does not return the error as expected
    my $error = $installer->load_sql($filepath);
    die $error if $error;
}

sub insert_records {
    say "Inserting records..."
        if $verbose;
    for my $file ( @records_files ) {
        execute_sqlfile( $file );
    }
}
