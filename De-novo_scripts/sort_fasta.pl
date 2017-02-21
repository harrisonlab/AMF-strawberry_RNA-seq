#! /usr/bin/perl -w -s
use List::Util qw<first>;
use FileHandle;
 
 
#################################################
#
# Sorts input sequences by length (longest first)
#
#################################################
 
my @seqs;

my $header="";
my $h1="";
my $seq="";
my $output;

while (<>) {
	chomp;
	if ($_=~/\>/) {
		$h1=$_;
		push @seqs,([$header, $seq, length($seq)]);
		#push @seqs,([length($seq),$header, $seq ]);
		$seq="";		
	} else{
		$header=$h1;
		$seq.=$_;
	}
}

push @seqs,([$header,$seq,length($seq)]) if $seq ne "";
#push @seqs,([length($seq),$header, $seq ]);

shift @seqs;

my @sorted = sort { $b->[2] <=> $a->[2] } @seqs;

#my @sorted = sort @seqs;
#@sorted = reverse @sorted;

my $counter=1;
foreach(@sorted) {
	$output.= sprintf "%s\n%s\n",@{$_};
}
		
syswrite STDOUT, $output;
