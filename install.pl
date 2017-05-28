#!/usr/bin/perl
use v5.22;
use strict;
use warnings;
use autodie;
use version; our $VERSION = qv('0.0.1');

use feature 'signatures';
no warnings 'experimental::signatures';

use File::Basename qw[dirname basename];
use Cwd qw[realpath];
BEGIN {
    require lib;
    lib->import(realpath dirname($0) . '/../lib');
}

use POSIX 'strftime';
use File::Find;
use File::Compare;
use File::Copy;
use File::Path 'make_path';
use Carp;
use Getopt::Long;

my ($source_dir, $dest_dir, $backup_dir);

sub dest_from_source($source) {
    state $source_re;
    unless ($source_re) {
        $source_re = '^' . quotemeta $source_dir;
        $source_re = qr/$source_re/;
    }
    
    my $dest = $source;
    if ($dest !~ s/$source_re/$dest_dir/) {
        croak "$source not within $source_dir";
    }
    
    return $dest;
}

sub backup($source) {
    # Backup does not end with '/'.
    state $backup;
    unless ($backup) {
        $backup = $backup_dir . strftime('%FT%H%M', localtime);
    }
    
    my $dest = $backup . $source;
    make_path dirname $dest;
    copy $source, $dest or die "Backup of $source to $dest failed: $!";
}

sub update {
    my $source = $File::Find::name;
    return if -d $source;
    
    my $dest = dest_from_source($source);
    
    if (-e $dest and compare($dest, $source) != 0) {
        backup $dest;
    }
    else {
        make_path dirname $dest;
    }
    
    copy $source, $dest or die "Copy from $source to $dest failed: $!";
}

my ($help, $ok, $default_source, $default_dest, $default_backup);

$source_dir = $default_source = realpath dirname($0) . '/home';
$dest_dir   = $default_dest   = $ENV{HOME};
$backup_dir = $default_backup = realpath dirname($0) . '/backup';

$ok = GetOptions(
    'source=s' => \$source_dir,
    'dest=s' => \$dest_dir,
    'backup=s' => \$backup_dir,
    'help!' => \$help,
);

if ($help or not $ok) {
    my $name = basename($0);
    print << "HELP";
$name - Install unix profile files into profile

Usage: $name [options]

Options
    --source <dir>  Source directory.
                    Default: $default_source
    --dest <dir>    Destination directory.
                    Default: $default_dest
    --backup <dir>  Directory for file backups.
                    Default: $default_backup
    --help          This message.
HELP
    exit 1;
}

for ($source_dir, $dest_dir, $backup_dir) {
    $_ .= '/' unless m{/$};
}

find({ wanted => \&update, no_chdir => 1 }, $source_dir);
