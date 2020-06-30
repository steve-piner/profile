#!/usr/bin/perl
use v5.20;
use strict;
use warnings;
use autodie;

use File::Basename 'basename', 'dirname';
use Cwd 'getcwd', 'abs_path';
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

eval {
    open my $fh, '<', $servers_file;
    @servers = map {chomp} <$fh>;
    close $fh;
};
my %already_saved = map {$_ => 1} @servers;

if ($list) {
    say for @servers;
    exit;
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



sub transfer {
    my ($server) = @_;
    state %seen;

    return if $seen{$_};
    $seen{$_} = 1;

    say "Transfer to $_";

    my $status = system qw[rsync -av ./],
        "$_:unix-profile",
        qw[--exclude=/.git    --exclude=/backup --exclude=/servers.txt --delete];
    return $status == 0;
}
