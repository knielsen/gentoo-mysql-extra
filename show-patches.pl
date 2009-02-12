#!/usr/bin/perl
#use Data::Dumper;
use warnings;
use strict;
use lib ".";
use PatchIndexer;

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
