#!/usr/bin/perl
# Created on 5/06/2017 by Steve Piner
use v5.22;
use strict;
use warnings;
use utf8;
use autodie;
use version; our $VERSION = qv('0.0.1');

use File::Basename qw[dirname basename];
use Cwd qw[realpath];

my $dir = dirname($0) . '/home';
my $dh;
opendir $dh, $dir;

while (my $file = readdir $dh) {
    next if $file =~ /^\.\.?$/;
    my @args = ('diff', @ARGV, "$ENV{HOME}/$file", "$dir/$file");
    say "@args";
    system @args;
}
closedir $dh;
