#!/usr/bin/perl
#use Data::Dumper;
use warnings;
use strict;
use lib ".";
use PatchIndexer;
use Carp;

unless($ARGV[0] and length($ARGV[0]) > 0 and $ARGV[1] and length($ARGV[1]) > 0) {
	printf STDERR "Must give PN and PV arguments\n";
	exit 1;
}

# Show patches for a given PN/PV
my $PN = $ARGV[0];
chomp $PN;
my $PV = $ARGV[1];
chomp $PV;

my ($FH, $index);
open $FH,'<',"0000_index.txt";
my @index = parseIndex($FH);
my @newindex = selectPatches(\@index, $PN, $PV);
#print Dumper(@index);
print printIndex(\@newindex);
