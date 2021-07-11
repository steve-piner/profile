#!/usr/bin/perl
use v5.22;
use strict;
use warnings;
#use autodie;
#use version; our $VERSION = qv('0.0.1');

use feature 'signatures';
no warnings 'experimental::signatures';

use File::Basename qw[dirname basename];
use Cwd qw[realpath];

BEGIN {
    require lib;
    lib->import(realpath dirname($0) . '/../lib');
}

use POSIX 'strftime';
#use File::Find;
#use File::Compare;
#use File::Copy;
use File::Path 'make_path';
use Carp;
use Getopt::Long;

use constant BUFFER_SIZE => 1024 * 1024;
use constant DEBUG => 0;

sub bcopy;
sub backup;

my ($custom_dir, $source_dir, $dest_dir, $backup_dir);

my ($help, $ok, $default_custom, $default_source, $default_dest, $default_backup, $install_flag, $default_flag);

$custom_dir   = $default_custom = realpath dirname($0) . '/custom';
$source_dir   = $default_source = realpath dirname($0) . '/home';
$dest_dir     = $default_dest   = $ENV{HOME};
$backup_dir   = $default_backup = realpath dirname($0) . '/backup';
$install_flag = $default_flag   = realpath dirname($0) . '/.installed';

$ok = GetOptions(
    'custom=s' => \$custom_dir,
    'source=s' => \$source_dir,
    'dest=s'   => \$dest_dir,
    'backup=s' => \$backup_dir,
    'flag=s'   => \$install_flag,
    'help!'    => \$help,
);

if ($help or not $ok) {
    my $name = basename($0);
    print << "HELP";
$name - Install unix profile files into profile

Usage: $name [options]

Options
    --custom <dir>  Customised source directory.
                    Default: $default_custom
    --source <dir>  Source directory.
                    Default: $default_source
    --dest <dir>    Destination directory.
                    Default: $default_dest
    --backup <dir>  Directory for file backups.
                    Default: $default_backup
    --flag <file>   Installation flag file
                    Default: $default_flag
    --help          This message.
HELP
    exit 1;
}

for ($custom_dir, $source_dir, $dest_dir, $backup_dir) {
    $_ .= q[/] unless m{/$};
}

my %seen_file;
my @source_dirs = grep {-d $_} ($custom_dir, $source_dir);

for my $update_dir (@source_dirs) {
    my $update =  sub {
        my $source = $File::Find::name;
        return if -d $source;
    
        my $dest = $dest_dir . strip_dir($source, $update_dir);
    
        if ($seen_file{$dest}) {
            say STDERR "Overridden $source (found in $custom_dir)";
        }
        else {
            ++$seen_file{$dest};
            if (-e $dest and bcompare($dest, $source) != 0) {
                backup $dest;
            }
            else {
                make_path dirname $dest;
            }
        
            bcopy $source, $dest or die "Copy from $source to $dest failed: $!";
        }
        return;
    };

    #find({wanted => \&update, no_chdir => 1}, $source_dir);
    bfind($update, $update_dir);
}

# Absence of this file indicates an update on remote (push-ed)
# servers.
open my $fh, '>', $install_flag;
close $fh;

exit;

sub strip_dir($source, $dir) {
    if (substr($source, 0, length $dir) ne $dir) {
        croak "$source not within $dir";
    }
    
    my $dest = substr($source, length $dir);

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
    bcopy $source, $dest or die "Backup of $source to $dest failed: $!";
    return;
}

# Poor replacement for File::Find::find (not available in perl-base)
sub bfind($command, $base_dir) {
    DEBUG and say "bfind($command, $base_dir)";
    my $dh;
    my @dir_queue = ($base_dir =~ s{/$}{}r);
    while (@dir_queue) {
        my $dir = shift @dir_queue;
        DEBUG and say "bfind opening $dir";
        opendir $dh, $dir or carp "Couldn't opendir $dir: $!";
    
        while (my $file = readdir $dh) {
            next if $file eq '..' or $file eq '.';
            my $name = $dir . '/' . $file;
            push @dir_queue, $name if -d $name;
            $File::Find::name = $name;
            $command->();
        }
        closedir $dh;
    }
    return;
}

# Poor replacement for File::Copy::copy (not available in perl-base)
sub bcopy($source, $dest) {
    DEBUG and say "bcopy($source, $dest)";
    open my $sourcefh, '<', $source or return;
    binmode $sourcefh or return;
    open my $destfh, '>', $dest or return;
    binmode $destfh or return;
    
    my ($bytes, $buffer);
    while ($bytes = sysread($sourcefh, $buffer, BUFFER_SIZE)) {
        return unless defined $bytes;
        $bytes = syswrite($destfh, $buffer);
        return unless defined $bytes;
    }
    return unless defined $bytes;

    close $destfh or return;
    close $sourcefh or return;        
    
    return 1;
}

# Poor replacement for File::Compare::compare (not available in perl-base)
sub bcompare($a, $b) {
    DEBUG and say "bcompare($a, $b)";
    open my $afh, '<', $a or return -1;
    binmode $afh or return -1;
    open my $bfh, '<', $b or return -1;
    binmode $bfh or return -1;

    my ($bytes, $abuffer, $bbuffer);
    while (1) {
        $bytes = sysread($afh, $abuffer, BUFFER_SIZE);
        return -1 unless defined $bytes;
        $bytes = sysread($bfh, $bbuffer, BUFFER_SIZE);
        return -1 unless defined $bytes;
        if ($abuffer ne $bbuffer) {
            return 1;
        }
        last if $bytes == 0;
    }

    return 0;    
}
