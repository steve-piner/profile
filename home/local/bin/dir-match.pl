#!/usr/bin/perl
use v5.20;
use strict;
use warnings;
use autodie;

my @active = grep { -d $_ }
    qw[
          /home/steve
          /home/webspace
          /home/library/video
          /home
          /
    ];

# One dot - relative to the current directory.
# Two dots - relative to the parent directory.
# Three dots - relative to the parent of the parent directory.
# etc.
if (@ARGV and $ARGV[0] =~ /^\.+$/) {
    my $dots = shift;

    if ($dots eq '.') {
        @active = ('.');
    }
    else {
        @active = (join '/', ('..') x (length($dots) - 1));
    }
}

while (@ARGV) {
    my @current = @active;
    @active = ();

    my $term = shift;

    if ($term =~ m{^/(\d+)$}) {
        if ($1 > 0 and $1 <= @current) {
            @active = ($current[$1 - 1]);
            next;
        }
        # Out of range - exit, no change.
        last;
    }

    my $term_re = '^' . join('.*?', map {quotemeta} split //, $term);
    $term_re = qr/$term_re/i;

    for my $current (@current) {
        my $dh;
        my @entries;

        eval {
            opendir $dh, $current;
            @entries = sort grep { !/^\.\.?$/ && /$term_re/ && -d "$current/$_" } readdir $dh;
            closedir $dh;
        };
        if ($@ and $@->isa('autodie::exception')) {
            die $@ unless $@->matches('opendir');
        }

        # Avoid '//' at the start of paths.
        $current = '' if $current eq '/';

        for (@entries) {
            push @active, "$current/$_";
        }
    }
}

my $width = length($#active + 1);
printf STDERR "  %${width}d. %s\n",  $_ + 1, $active[$_] for 0..$#active;

say $active[0] if @active;
