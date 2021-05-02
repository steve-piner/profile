#!/usr/bin/perl
use v5.20;
use strict;
use warnings;

my @active = grep { -d $_ }
    exists $ENV{DIR_MATCH_DIRS}
        ? split ':', $ENV{DIR_MATCH_DIRS} 
        : ($ENV{HOME}, '/');

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
    elsif ($term =~ m{(/\d+)$}) {
        # "foo/2" "bar" to become "foo" "/2" "bar"
        unshift @ARGV, $1;
        substr($term, -length($1)) = '';
    }

    my $term_re = '^' . join('.*?', map {quotemeta} split //, $term);
    $term_re = qr/$term_re/i;

    for my $current (@current) {
        my $dh;
        my @entries;

        eval {
            opendir $dh, $current or die 'opendir failed';
            @entries = sort grep { !/^\.\.?$/ && /$term_re/ && -d "$current/$_" } readdir $dh;
            closedir $dh or die 'closedir failed';
        };
        if ($@) {
            die $@ unless $@ =~ /^opendir/;
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
