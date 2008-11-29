#!/usr/bin/perl
use Getopt::Long;
use Data::Dumper;
use Clone qw(clone);
use warnings;
use strict;
use lib ".";
use PatchIndexer;

my ($FH, $index);
open $FH,'<',"000_index.txt";
my @index = parseIndex($FH);
#print Dumper(@index);
print printIndex(\@index);


