#!/usr/bin/perl
use v5.20;
use strict;
use warnings;
use utf8;
use autodie;
use version; our $VERSION = qv('0.0.1');

use File::Basename qw[dirname basename];
use Cwd qw[getcwd abs_path];
use Getopt::Long;

my ($ok, $help, $all, $list, $track);

$track = 1;

$ok = GetOptions(
    'all!' => \$all,
    'list!' => \$list,
    'track!' => $track,
    'help!' => \$help,
);

if ($help or not $ok) {
    my $name = basename($0);
    print <<"HELP";
$0 [options] <server> ... - Transfer unix-profile to server.

Transfer the unix-profile directory to servers, keeping track of the
names of the servers it is transferred to. The profile is not
installed by this script.

Options
  --all       Push the profile to all servers that the profile had
              already been transferred to.
  --track     (default) Track which servers the profile has been
              transferred to.
  --no-track  Do not keep track of the servers this time
  --list      List all servers the profile has been transferred to
              then exit
  --help      This message.
HELP
    exit;
}

my $dir = abs_path(getcwd . '/' . dirname $0);
my $servers_file = $dir . '/servers.txt';
my @servers;
my $installed;

eval {
    open my $fh, '<', $servers_file;
    @servers = map {chomp; $_} <$fh>;
    close $fh;
};
my %already_saved = map {$_ => 1} @servers;

if ($list) {
    say for @servers;
    exit;
}

# If already installed, move the flag to a temporary location to avoid
# marking all targets as already installed...
$installed = -f '.installed';
if ($installed) {
    system qw[mv .installed backup];
}

if ($all) {
    transfer($_) for @servers;
}

my $fh;
if ($track) {
    open $fh, '>>', $servers_file;
}

for (@ARGV) {
    my $transferred = transfer($_);
    say {$fh} $_ if $track && $transferred && !$already_saved{$_};
}

if ($track) {
    close $fh;
}

if ($installed) {
    system qw[mv backup/.installed .];
}


sub transfer {
    my ($server) = @_;
    state %seen;

    return if $seen{$_};
    $seen{$_} = 1;

    say "Transfer to $_";

    my $status = system qw[rsync -av ./],
        "$_:unix-profile",
        qw[--exclude=/.git --exclude=/backup --exclude=/servers.txt --delete];
    return $status == 0;
}


__END__

# A different version, that looks better, but is not tested...

BEGIN {
    require lib;
    lib->import(realpath dirname($0) . '/../lib');
}

use constant SERVERS_FILE => $ENV{HOME} . '/local/var/unix-profile/servers';
use constant FILES_FILE   => $ENV{HOME} . '/local/var/unix-profile/files';

use Getopt::Long 'GetOptions';
use File::Copy 'copy';

my (
    $ok,           $help,    $server,  $save,
    $push_all,     $include, $exclude, $exclude_server,
    $list_servers, $list_files
);

$save = 1;

$ok = GetOptions(
    'help!'            => \$help,
    'server=s'         => \$server,
    'exclude-server=s' => \$exclude_server,
    'list-servers'     => \$list_servers,
    'save!'            => \$save,
    'all!'             => \$push_all,
    'include=s'        => \$include,
    'exclude=s'        => \$exclude,
    'list-files=s'     => \$list_files,
);

if (not $ok or @ARGV > 1) {
    $help = 1;
}

# This could be a server, but only treat it as one if it's unambiguous.
if (@ARGV and @ARGV == 1) {
    my @blockers = (
        $server, $exclude_server, $list_servers, $push_all, $include, $exclude,
        $list_files, $help
    );

    my $blocked = grep { defined $_ } @blockers;

    if ($blocked) {
        $help = 1;
    }
    else {
        $server = shift;
    }
}

if ($help) {
    my $name = basename $0;
    print << "HELP";
$name - Transfer unix-profile to server. Does not install it.

Usage
  $name [options]
  $name [--no-save] <server>

Options
  --server <server>          Where to transfer the unix-profile directory to.
  --no-save                  Do not add this server to the server list.
  --all                      Push the unix-profile directory and all files in
                             the file list to all servers in the server list.
  
  --exclude-server <server>  Remove this server from the server list.
  --list-servers             Display the server list.

  --include <file>           Add file to file list.
  --exclude <file>           Remove file from the file list.
  --list-files               Display the file list.

  --help                     This help text.
HELP
    exit 1;
}

my $servers = Profile::List->new(SERVERS_FILE);
my $files   = Profile::List->new(FILES_FILE);

$servers->can_save($save);
$files->can_save($save);

if ($include) {
    $files->add(collapse_file_names($include));
}

if ($exclude) {
    $files->remove(collapse_file_names($exclude));
}

if ($list_files) {
    say for $files->list;
}

my @targets;

if ($server) {
    $servers->add($server);
}

if ($push_all) {
    @targets = $servers->list;
}
elsif ($server) {
    @targets = $server;
}

if ($exclude_server) {
    $servers->remove($exclude_server);
}

if ($list_servers) {
    say for $servers->list;
}

if (@targets) {
    chdir(dirname $0);

    if (-d 'transfer') {
        unlink glob('transfer/*');
    }
    else {
        mkdir 'transfer';
    }

    open my $fh, '>', 'transfer/file-list';
    for ($files->list) {
        my $count = 0;
        my $base  = basename $_;
        my $name  = $base;
        while (-e $name) {
            $name = $base . '.' . ++$count;
        }
        copy(expand_file_names($_), 'transfer/' . $name)
            or die "Copy '$_' to '$name' failed: $!";

        say {$fh} "$name\t$_";
    }
    close $fh;

    for (@targets) {
        say "Push to $_";
        system('rsync', '-av', './', $_ . ':unix-profile',
            '--exclude=/.git', '--exclude=/backup', '--delete');
    }
}

$servers = undef;
$files   = undef;

exit;

sub expand_file_names {
    my (@file) = @_;
    for (@file) {
        s{^~/}{$ENV{HOME}/};
    }
    return @file if wantarray;
    return $file[0];
}

sub collapse_file_names {
    state $prefix = $ENV{HOME} . '/';
    my (@file) = @_;
    for (@file) {
        if (substr($_, 0, length($prefix)) eq $prefix) {
            $_ = '~/' . substr($_, length($prefix));
        }
    }
    return @file if wantarray;
    return $file[0];
}

package Profile::List;
use autodie;
use File::Basename qw[dirname];

sub new {
    my ($package, $file) = @_;
    return bless {file => $file}, $package;
}

sub can_save {
    my ($self, $can_save) = @_;
    $self->{can_save} = $can_save;
    return;
}

sub load {
    my ($self) = @_;
    if (-f $self->{file}) {
        open my $fh, '<', $self->{file};
        $self->{items} = [map { chomp; $_ } <$fh>];
        close $fh;
    }
    else {
        $self->{items} = [];
    }
    $self->{changed} = 0;
    return;
}

sub load_once {
    my ($self) = @_;
    unless (exists $self->{items}) {
        $self->load;
    }
    return;
}

sub list {
    my ($self) = @_;
    $self->load_once;

    return @{$self->{items}};
}

sub write {
    my ($self) = @_;
    if ($self->{can_save}) {
        mkdir dirname($self->{file}) unless -d dirname($self->{file});
        open my $fh, '>', $self->{file};
        print {$fh} map {"$_\n"} @{$self->{items}};
        close $fh;
    }
    return;
}

sub add {
    my ($self, $item) = @_;
    $self->load_once;
    unless (grep { $_ eq $item } @{$self->{items}}) {
        push @{$self->{items}}, $item;
        $self->{changed} = 1;
    }
    return;
}

sub remove {
    my ($self, $item) = @_;
    $self->load_once;
    for (0 .. $#{$self->{items}}) {
        if ($self->{items}[$_] eq $item) {
            splice @{$self->{items}}, $_, 1;
            $self->{changed} = 1;
            last;
        }
    }
    return;
}

sub DESTROY {
    my ($self) = @_;
    if ($self->{changed}) {
        $self->write();
    }
}
